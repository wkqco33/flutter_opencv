import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_opencv/flutter_opencv.dart';

import '../services/camera_service.dart';
import '../utils/logger.dart';
import '../services/image_processing_service.dart';
import '../utils/permission_service.dart';
import '../widgets/image_viewer.dart';

class ColorDetectionPage extends StatefulWidget {
  const ColorDetectionPage({super.key});

  @override
  State<ColorDetectionPage> createState() => _ColorDetectionPageState();
}

class _ColorDetectionPageState extends State<ColorDetectionPage> {
  static const String _tag = 'ColorDetectionPage';

  // 이미지 상태
  CvImage? _originalImage;
  CvImage? _processedImage;
  Uint8List? _displayBytes;

  final CameraService _cameraService = CameraService();

  @override
  void initState() {
    super.initState();
    _loadDefaultImage();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _originalImage?.dispose();
    _processedImage?.dispose();
    super.dispose();
  }

  Future<void> _loadDefaultImage() async {
    final defaultImage = ImageProcessingService.createDefaultImage();
    if (defaultImage != null) {
      setState(() {
        _originalImage = defaultImage;
      });
      await _processImage();
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      if (_cameraService.isActive) await _cameraService.stop();

      final hasPermission = await PermissionService.requestStoragePermission();
      if (!hasPermission) return;

      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result == null || result.files.single.path == null) return;

      final image = await ImageProcessingService.loadFromFile(
        result.files.single.path!,
      );
      if (image == null) return;

      _originalImage?.dispose();
      setState(() {
        _originalImage = image;
      });

      await _processImage();
    } catch (e) {
      AppLogger.error('이미지 선택 오류', error: e, tag: _tag);
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameraService.isActive) {
      await _cameraService.stop();
      setState(() {
        _displayBytes = null;
      });
    } else {
      final hasPermission = await PermissionService.requestCameraPermission();
      if (!hasPermission) return;

      _originalImage?.dispose();
      _processedImage?.dispose();
      _originalImage = null;
      _processedImage = null;

      await _cameraService.start(onFrame: _onCameraFrame);
      setState(() {});
    }
  }

  void _onCameraFrame(CvImage frame) {
    try {
      final processed = ImageProcessingService.processColorDetection(frame);
      if (processed != frame) frame.dispose();

      final bytes = ImageProcessingService.encodeImage(processed);
      processed.dispose();

      if (mounted) {
        setState(() {
          _displayBytes = bytes;
        });
      }
    } catch (e) {
      AppLogger.error('프레임 처리 오류', error: e, tag: _tag);
      frame.dispose();
    }
  }

  Future<void> _processImage() async {
    if (_originalImage == null) return;

    // 원본 이미지를 바이트로 인코딩
    final originalBytes = ImageProcessingService.encodeImage(_originalImage!);

    // Isolate에서 색상 검출 파이프라인 처리
    final resultBytes =
        await ImageProcessingService.processColorDetectionIsolated(
          originalBytes,
        );

    if (resultBytes == null) return;

    setState(() {
      _displayBytes = resultBytes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('색상 기반 객체 검출')),
      body: Column(
        children: [
          Expanded(
            child: ImageViewer(
              imageBytes: _displayBytes,
              isLiveMode: _cameraService.isActive,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              '처리 과정: HSV Conversion (Color Space Visualization)',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          _buildActionButtons(colorScheme),
        ],
      ),
    );
  }

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
              label: const Text('Gallery'),
              backgroundColor: colorScheme.secondaryContainer,
              foregroundColor: colorScheme.onSecondaryContainer,
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
              label: Text(_cameraService.isActive ? 'Stop' : 'Camera'),
              backgroundColor: _cameraService.isActive
                  ? colorScheme.errorContainer
                  : colorScheme.primaryContainer,
              foregroundColor: _cameraService.isActive
                  ? colorScheme.onErrorContainer
                  : colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
