import 'dart:async';
import 'package:flutter_opencv/flutter_opencv.dart';
import '../utils/logger.dart';

/// 카메라 프레임 콜백 타입 정의
/// 
/// [frame]: 캡처된 프레임 이미지
typedef CameraFrameCallback = void Function(CvImage frame);

/// 카메라 서비스
/// 
/// 웹캠/카메라 접근, 실시간 프레임 캡처, 스트리밍 관리 기능을 제공합니다.
/// 타이머를 사용하여 주기적으로 프레임을 캡처하고 콜백으로 전달합니다.
class CameraService {
  static const String _tag = 'Camera';
  
  /// OpenCV VideoCapture 객체
  CvVideoCapture? _capture;
  
  /// 프레임 캡처 타이머
  Timer? _frameTimer;
  
  /// 카메라 활성 상태
  bool _isActive = false;
  
  /// 프레임 콜백 함수
  CameraFrameCallback? _onFrame;
  
  /// 카메라 활성 상태 확인
  bool get isActive => _isActive;
  
  /// 카메라 연결 및 스트리밍 시작
  /// 
  /// [cameraIndex]: 카메라 장치 인덱스 (보통 0이 기본 카메라)
  /// [width]: 캡처 해상도 너비
  /// [height]: 캡처 해상도 높이
  /// [fps]: 초당 프레임 수 (기본값: 30)
  /// [onFrame]: 프레임 캡처시 호출될 콜백 함수
  /// 
  /// Returns: 성공시 true, 실패시 false
  /// 
  /// 예시:
  /// ```dart
  /// final success = await cameraService.start(
  ///   cameraIndex: 0,
  ///   width: 640,
  ///   height: 480,
  ///   onFrame: (frame) {
  ///     // 프레임 처리
  ///     frame.dispose(); // 처리 후 반드시 해제
  ///   },
  /// );
  /// ```
  Future<bool> start({
    int cameraIndex = 0,
    int width = 640,
    int height = 480,
    int fps = 30,
    required CameraFrameCallback onFrame,
  }) async {
    try {
      AppLogger.info(
        '카메라 시작 시도: index=$cameraIndex, ${width}x$height, ${fps}fps',
        tag: _tag,
      );
      
      // 이미 실행 중이면 먼저 중지
      if (_isActive) {
        AppLogger.warning('이미 카메라가 실행 중입니다. 재시작합니다.', tag: _tag);
        await stop();
      }
      
      // OpenCV VideoCapture 생성 및 카메라 연결
      final capture = CvVideoCapture.connect(cameraIndex);
      
      if (capture == null) {
        AppLogger.error(
          '카메라 연결 실패: 장치를 찾을 수 없거나 접근 권한이 없습니다',
          tag: _tag,
        );
        return false;
      }
      
      _capture = capture;
      _onFrame = onFrame;
      
      // 카메라 해상도 설정
      // 속성 ID: 3 = CAP_PROP_FRAME_WIDTH, 4 = CAP_PROP_FRAME_HEIGHT
      _capture!.set(3, width.toDouble());
      _capture!.set(4, height.toDouble());
      
      // 실제 설정된 해상도 확인 (카메라가 지원하지 않으면 다른 값이 될 수 있음)
      final actualWidth = _capture!.get(3).toInt();
      final actualHeight = _capture!.get(4).toInt();
      
      AppLogger.info(
        '실제 카메라 해상도: ${actualWidth}x$actualHeight',
        tag: _tag,
      );
      
      // 프레임 캡처 타이머 시작
      // 1000ms / fps = 각 프레임 간 간격 (밀리초)
      final intervalMs = (1000 / fps).round();
      _frameTimer = Timer.periodic(
        Duration(milliseconds: intervalMs),
        _captureFrame,
      );
      
      _isActive = true;
      
      AppLogger.success('카메라 시작 완료', tag: _tag);
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        '카메라 시작 중 에러 발생',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
      
      // 에러 발생시 정리
      await stop();
      return false;
    }
  }
  
  /// 카메라 스트리밍 중지 및 리소스 해제
  /// 
  /// Returns: 성공시 true, 실패시 false
  Future<bool> stop() async {
    try {
      if (!_isActive) {
        AppLogger.debug('이미 카메라가 중지된 상태입니다', tag: _tag);
        return true;
      }
      
      AppLogger.info('카메라 중지 시작', tag: _tag);
      
      // 타이머 취소
      _frameTimer?.cancel();
      _frameTimer = null;
      
      // VideoCapture 해제
      _capture?.dispose();
      _capture = null;
      
      // 콜백 제거
      _onFrame = null;
      
      _isActive = false;
      
      AppLogger.success('카메라 중지 완료', tag: _tag);
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        '카메라 중지 중 에러 발생',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
      
      // 에러가 발생해도 상태는 초기화
      _isActive = false;
      _frameTimer = null;
      _capture = null;
      _onFrame = null;
      
      return false;
    }
  }
  
  /// 단일 프레임 캡처 (내부 메서드)
  /// 
  /// 타이머에 의해 주기적으로 호출되며,
  /// 카메라로부터 프레임을 읽어 콜백으로 전달합니다.
  void _captureFrame(Timer timer) {
    try {
      // 카메라가 비활성화되었으면 타이머 중지
      if (!_isActive || _capture == null) {
        timer.cancel();
        AppLogger.warning('카메라가 비활성화되어 프레임 캡처 중지', tag: _tag);
        return;
      }
      
      // 카메라에서 프레임 읽기
      final frame = _capture!.read();
      
      if (frame == null) {
        // 프레임을 읽을 수 없는 경우 (일시적 문제)
        // 에러는 로그로만 남기고 계속 시도
        AppLogger.warning('프레임 읽기 실패 (일시적)', tag: _tag);
        return;
      }
      
      // 프레임을 콜백으로 전달
      // 주의: 콜백에서 프레임 처리 후 반드시 dispose() 호출 필요
      _onFrame?.call(frame);
    } catch (e, stackTrace) {
      // 프레임 캡처 중 에러 발생
      // 에러를 로그로 남기지만 스트리밍은 계속 진행
      AppLogger.error(
        '프레임 캡처 중 에러 발생',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
    }
  }
  
  /// 카메라 속성 가져오기
  /// 
  /// [propertyId]: OpenCV 속성 ID
  /// 
  /// Returns: 속성 값 (double)
  /// 
  /// 주요 속성 ID:
  /// - 3: CAP_PROP_FRAME_WIDTH (너비)
  /// - 4: CAP_PROP_FRAME_HEIGHT (높이)
  /// - 5: CAP_PROP_FPS (FPS)
  double? getProperty(int propertyId) {
    try {
      if (_capture == null) {
        AppLogger.warning('카메라가 연결되지 않았습니다', tag: _tag);
        return null;
      }
      
      return _capture!.get(propertyId);
    } catch (e, stackTrace) {
      AppLogger.error(
        '속성 읽기 중 에러 발생: propertyId=$propertyId',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
      return null;
    }
  }
  
  /// 카메라 속성 설정
  /// 
  /// [propertyId]: OpenCV 속성 ID
  /// [value]: 설정할 값
  void setProperty(int propertyId, double value) {
    try {
      if (_capture == null) {
        AppLogger.warning('카메라가 연결되지 않았습니다', tag: _tag);
        return;
      }
      
      _capture!.set(propertyId, value);
      AppLogger.debug(
        '속성 설정: propertyId=$propertyId, value=$value',
        tag: _tag,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        '속성 설정 중 에러 발생: propertyId=$propertyId',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
    }
  }
  
  /// 서비스 정리 (dispose)
  /// 
  /// 위젯이 dispose될 때 호출하여 모든 리소스를 해제합니다.
  void dispose() {
    AppLogger.info('CameraService dispose 호출', tag: _tag);
    stop();
  }
}
