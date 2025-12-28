import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_opencv/flutter_opencv.dart';

import 'models/filter_type.dart';
import 'pages/color_detection_page.dart';
import 'pages/document_scanner_page.dart';
import 'pages/photo_enhancement_page.dart';
import 'services/camera_service.dart';
import 'services/image_processing_service.dart';
import 'utils/logger.dart';
import 'utils/permission_service.dart';
import 'widgets/filter_selector.dart';
import 'widgets/image_viewer.dart';

/// Flutter OpenCV 데모 앱
///
/// 이 예제는 Flutter에서 OpenCV FFI 플러그인을 사용하여
/// 이미지 처리와 실시간 카메라 스트리밍을 구현하는 방법을 보여줍니다.
void main() {
  // 앱 시작 로그
  AppLogger.info('Flutter OpenCV Demo 앱 시작');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter OpenCV Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

/// 홈 페이지 위젯
///
/// 이미지 로드, 필터 적용, 카메라 스트리밍 기능을 제공합니다.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _tag = 'HomePage';

  // OpenCV 버전 정보
  String _opencvVersion = 'Unknown';

  // 이미지 상태
  CvImage? _originalImage; // 원본 이미지 (필터 재적용을 위해 보관)
  CvImage? _processedImage; // 처리된 이미지 (현재 표시 중)
  Uint8List? _displayBytes; // UI에 표시할 이미지 바이트

  // 필터 상태
  FilterType _activeFilter = FilterType.none;

  // 카메라 서비스
  final CameraService _cameraService = CameraService();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    AppLogger.info('HomePage dispose', tag: _tag);

    // 리소스 정리
    _cameraService.dispose();
    _originalImage?.dispose();
    _processedImage?.dispose();

    super.dispose();
  }

  /// 앱 초기화
  ///
  /// OpenCV 버전 확인 및 기본 이미지 로드
  Future<void> _initializeApp() async {
    try {
      AppLogger.info('앱 초기화 시작', tag: _tag);

      // OpenCV 버전 가져오기
      final version = opencvVersion();
      setState(() {
        _opencvVersion = version;
      });

      AppLogger.info('OpenCV 버전: $version', tag: _tag);

      // 기본 이미지 로드
      await _loadDefaultImage();

      AppLogger.success('앱 초기화 완료', tag: _tag);
    } catch (e, stackTrace) {
      AppLogger.error(
        '앱 초기화 중 에러 발생',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );

      _showErrorSnackBar('앱 초기화 실패: $e');
    }
  }

  /// 기본 이미지 로드
  ///
  /// 앱 시작시 표시할 샘플 이미지를 생성합니다.
  Future<void> _loadDefaultImage() async {
    try {
      AppLogger.info('기본 이미지 로드', tag: _tag);

      // 카메라가 실행 중이면 중지
      if (_cameraService.isActive) {
        await _cameraService.stop();
      }

      // 기존 이미지 정리
      _resetImageState();

      // 기본 이미지 생성
      final defaultImage = ImageProcessingService.createDefaultImage();

      if (defaultImage == null) {
        AppLogger.warning('기본 이미지 생성 실패', tag: _tag);
        return;
      }

      setState(() {
        _originalImage = defaultImage;
      });

      // 현재 필터 적용
      await _applyCurrentFilter();

      AppLogger.success('기본 이미지 로드 완료', tag: _tag);
    } catch (e, stackTrace) {
      AppLogger.error(
        '기본 이미지 로드 중 에러 발생',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
    }
  }

  /// 갤러리에서 이미지 선택
  ///
  /// 파일 피커를 사용하여 이미지 파일을 선택하고 로드합니다.
  /// Android: 저장소 권한 필요
  Future<void> _pickImageFromGallery() async {
    try {
      AppLogger.info('이미지 선택 시작', tag: _tag);

      // 저장소 권한 확인 및 요청 (Android)
      final hasPermission = await PermissionService.requestStoragePermission();
      if (!hasPermission) {
        AppLogger.warning('저장소 권한이 필요합니다', tag: _tag);
        _showPermissionDeniedDialog(
          '저장소 권한 필요',
          '갤러리에서 이미지를 선택하려면 저장소 접근 권한이 필요합니다.',
        );
        return;
      }

      // 파일 피커로 이미지 선택
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      // 선택 취소
      if (result == null || result.files.single.path == null) {
        AppLogger.info('이미지 선택 취소됨', tag: _tag);
        return;
      }

      final path = result.files.single.path!;
      AppLogger.info('선택된 파일: $path', tag: _tag);

      // 카메라 중지
      if (_cameraService.isActive) {
        await _cameraService.stop();
      }

      // 기존 이미지 정리
      _resetImageState();

      // 이미지 로드 (Isolate에서 처리)
      final imageBytes = await ImageProcessingService.loadFromFileIsolated(
        path,
        maxSize: 1280,
      );

      if (imageBytes == null) {
        AppLogger.warning('이미지 로드 실패', tag: _tag);
        _showErrorSnackBar('이미지를 로드할 수 없습니다');
        return;
      }

      // 바이트에서 CvImage로 디코딩 (메인 스레드)
      final image = ImageProcessingService.loadFromBytes(imageBytes);
      if (image == null) {
        _showErrorSnackBar('이미지 디코딩 실패');
        return;
      }

      setState(() {
        _originalImage = image;
      });

      // 필터 적용
      await _applyCurrentFilter();

      AppLogger.success('이미지 로드 및 처리 완료', tag: _tag);
    } catch (e, stackTrace) {
      AppLogger.error(
        '이미지 선택 중 에러 발생',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );

      _showErrorSnackBar('이미지 로드 실패: $e');
    }
  }

  /// 카메라 토글
  Future<void> _toggleCamera() async {
    if (_cameraService.isActive) {
      await _stopCamera();
    } else {
      await _startCamera();
    }
  }

  /// 카메라 시작
  ///
  /// Android: 카메라 권한 필요
  Future<void> _startCamera() async {
    try {
      AppLogger.info('카메라 시작 시도', tag: _tag);

      // 카메라 권한 확인 및 요청 (Android)
      final hasPermission = await PermissionService.requestCameraPermission();
      if (!hasPermission) {
        AppLogger.warning('카메라 권한이 필요합니다', tag: _tag);
        _showPermissionDeniedDialog(
          '카메라 권한 필요',
          '카메라를 사용하려면 카메라 접근 권한이 필요합니다.',
        );
        return;
      }

      _resetImageState();

      final success = await _cameraService.start(
        cameraIndex: 0,
        width: 640,
        height: 480,
        fps: 30,
        onFrame: _onCameraFrame,
      );

      if (!success) {
        AppLogger.error('카메라 시작 실패', tag: _tag);
        _showErrorSnackBar('카메라를 열 수 없습니다');
        return;
      }

      setState(() {});
      AppLogger.success('카메라 시작 완료', tag: _tag);
    } catch (e, stackTrace) {
      AppLogger.error(
        '카메라 시작 중 에러 발생',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
      _showErrorSnackBar('카메라 시작 실패: $e');
    }
  }

  /// 카메라 중지
  Future<void> _stopCamera() async {
    try {
      AppLogger.info('카메라 중지', tag: _tag);
      await _cameraService.stop();
      setState(() {
        _displayBytes = null;
      });
      AppLogger.success('카메라 중지 완료', tag: _tag);
    } catch (e, stackTrace) {
      AppLogger.error(
        '카메라 중지 중 에러 발생',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
    }
  }

  /// 카메라 프레임 콜백
  void _onCameraFrame(CvImage frame) {
    try {
      final processed = ImageProcessingService.applyFilter(
        frame,
        _activeFilter,
      );
      if (processed != frame) {
        frame.dispose();
      }
      final bytes = ImageProcessingService.encodeImage(processed);
      processed.dispose();
      if (mounted) {
        setState(() {
          _displayBytes = bytes;
        });
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        '프레임 처리 중 에러 발생',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
      frame.dispose();
    }
  }

  /// 필터 변경
  Future<void> _onFilterChanged(FilterType newFilter) async {
    try {
      if (_activeFilter == newFilter) return;

      AppLogger.info(
        '필터 변경: ${_activeFilter.displayName} -> ${newFilter.displayName}',
        tag: _tag,
      );

      setState(() {
        _activeFilter = newFilter;
      });

      if (!_cameraService.isActive) {
        await _applyCurrentFilter();
      }

      AppLogger.success('필터 변경 완료', tag: _tag);
    } catch (e, stackTrace) {
      AppLogger.error(
        '필터 변경 중 에러 발생',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
    }
  }

  /// 현재 필터 적용
  Future<void> _applyCurrentFilter() async {
    try {
      if (_originalImage == null || _cameraService.isActive) return;

      AppLogger.debug('필터 적용 시작: ${_activeFilter.displayName}', tag: _tag);

      // 원본 이미지를 바이트로 인코딩
      final originalBytes = ImageProcessingService.encodeImage(_originalImage!);

      // Isolate에서 필터 적용
      final resultBytes = await ImageProcessingService.applyFilterIsolated(
        originalBytes,
        _activeFilter,
      );

      if (resultBytes == null) {
        AppLogger.warning('필터 적용 실패', tag: _tag);
        _showErrorSnackBar('필터 적용 실패');
        return;
      }

      // UI 업데이트
      setState(() {
        _displayBytes = resultBytes;
      });

      AppLogger.debug('필터 적용 완료', tag: _tag);
    } catch (e, stackTrace) {
      AppLogger.error(
        '필터 적용 중 에러 발생',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
      _showErrorSnackBar('필터 적용 실패: $e');
    }
  }

  /// 이미지 상태 초기화
  void _resetImageState() {
    AppLogger.debug('이미지 상태 초기화', tag: _tag);
    _originalImage?.dispose();
    _processedImage?.dispose();
    _originalImage = null;
    _processedImage = null;
    _displayBytes = null;
    _activeFilter = FilterType.none;
  }

  /// 권한 거부 다이얼로그 표시
  ///
  /// 권한이 필요한 기능을 사용하려 할 때 권한이 거부된 경우 안내 메시지를 표시합니다.
  void _showPermissionDeniedDialog(String title, String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              PermissionService.goToAppSettings();
            },
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }

  /// 에러 스낵바 표시
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 페이지 이동 (카메라 정지 후 이동)
  Future<void> _navigateToPage(Widget page) async {
    // 카메라 실행 중이면 중지
    if (_cameraService.isActive) {
      await _stopCamera();
    }

    if (!mounted) return;

    // 네비게이션
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenCV: 기본 필터 데모'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'v$_opencvVersion',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: colorScheme.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(Icons.camera, size: 35),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Flutter OpenCV',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Demo App',
                    style: TextStyle(
                      color: colorScheme.onPrimary.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.filter),
              title: const Text('기본 필터 데모'),
              selected: true,
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '실전 활용 예제',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.document_scanner),
              title: const Text('문서 스캐너'),
              subtitle: const Text('엣지 검출 및 투시 변환'),
              onTap: () {
                Navigator.pop(context);
                _navigateToPage(const DocumentScannerPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_filter),
              title: const Text('사진 품질 개선'),
              subtitle: const Text('노이즈 제거 및 선명도'),
              onTap: () {
                Navigator.pop(context);
                _navigateToPage(const PhotoEnhancementPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('색상 객체 검출'),
              subtitle: const Text('HSV 마스킹'),
              onTap: () {
                Navigator.pop(context);
                _navigateToPage(const ColorDetectionPage());
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ImageViewer(
              imageBytes: _displayBytes,
              isLiveMode: _cameraService.isActive,
            ),
          ),
          FilterSelector(
            selectedFilter: _activeFilter,
            onFilterSelected: _onFilterChanged,
          ),
          const SizedBox(height: 16),
          _buildActionButtons(colorScheme),
        ],
      ),
    );
  }

  /// 액션 버튼들 빌드
  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: FloatingActionButton.extended(
              onPressed: _pickImageFromGallery,
              heroTag: 'gallery',
              icon: const Icon(Icons.photo_library),
              label: const Text(
                'Gallery',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: colorScheme.secondaryContainer,
              foregroundColor: colorScheme.onSecondaryContainer,
              elevation: 1,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FloatingActionButton.extended(
              onPressed: _toggleCamera,
              heroTag: 'camera',
              icon: Icon(
                _cameraService.isActive ? Icons.videocam_off : Icons.videocam,
              ),
              label: Text(
                _cameraService.isActive ? 'Stop' : 'Camera',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: _cameraService.isActive
                  ? colorScheme.errorContainer
                  : colorScheme.primaryContainer,
              foregroundColor: _cameraService.isActive
                  ? colorScheme.onErrorContainer
                  : colorScheme.onPrimaryContainer,
              elevation: 1,
            ),
          ),
        ],
      ),
    );
  }
}
