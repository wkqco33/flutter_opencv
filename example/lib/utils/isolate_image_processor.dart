import 'dart:typed_data';
import 'package:flutter_opencv/flutter_opencv.dart';
import '../models/filter_type.dart';
import '../services/image_processing_service.dart';
import 'logger.dart';

/// Isolate에서 이미지 로딩을 수행하기 위한 파라미터 클래스
class LoadImageParams {
  final String filePath;
  final int maxSize;

  LoadImageParams({required this.filePath, required this.maxSize});
}

/// Isolate에서 필터 적용을 수행하기 위한 파라미터 클래스
class ApplyFilterParams {
  final Uint8List imageBytes;
  final String filterTypeName;

  ApplyFilterParams({required this.imageBytes, required this.filterTypeName});
}

/// Isolate에서 파이프라인 처리를 수행하기 위한 파라미터 클래스
class PipelineParams {
  final Uint8List imageBytes;
  final String pipelineType; // 'document', 'enhancement', 'color'

  PipelineParams({required this.imageBytes, required this.pipelineType});
}

// ============================================================================
// Top-level entry point 함수들 (Isolate에서 실행됨)
// ============================================================================

/// Isolate에서 이미지 로딩 처리
///
/// [params]: 파일 경로 및 최대 크기 정보
/// Returns: 로드되고 리사이즈된 이미지의 바이트 배열, 실패시 null
Future<Uint8List?> isolateLoadImage(LoadImageParams params) async {
  try {
    AppLogger.info('Isolate: 이미지 로딩 시작 - ${params.filePath}');

    // 이미지 로드
    final image = CvImage.fromFile(params.filePath);
    if (image == null) {
      AppLogger.warning('Isolate: 이미지 로드 실패');
      return null;
    }

    // 리사이징
    CvImage finalImage = image;
    if (image.width > params.maxSize || image.height > params.maxSize) {
      final aspectRatio = image.height / image.width;
      final newWidth = params.maxSize;
      final newHeight = (newWidth * aspectRatio).toInt();

      finalImage = image.resize(newWidth, newHeight);
      image.dispose();
    }

    // 바이트로 인코딩
    final bytes = finalImage.encode(ext: '.jpg');
    finalImage.dispose();

    AppLogger.success('Isolate: 이미지 로딩 완료 (${bytes.length} bytes)');
    return Uint8List.fromList(bytes);
  } catch (e, stackTrace) {
    AppLogger.error('Isolate: 이미지 로딩 중 에러', error: e, stackTrace: stackTrace);
    return null;
  }
}

/// Isolate에서 필터 적용 처리
///
/// [params]: 이미지 바이트 및 필터 타입 정보
/// Returns: 필터가 적용된 이미지의 바이트 배열, 실패시 null
Future<Uint8List?> isolateApplyFilter(ApplyFilterParams params) async {
  try {
    AppLogger.info('Isolate: 필터 적용 시작 - ${params.filterTypeName}');

    // 바이트에서 이미지 디코딩
    final image = CvImage.fromBytes(params.imageBytes);
    if (image == null) {
      AppLogger.warning('Isolate: 이미지 디코딩 실패');
      return null;
    }

    // 필터 타입 문자열을 enum으로 변환
    final filterType = FilterType.values.firstWhere(
      (e) => e.name == params.filterTypeName,
      orElse: () => FilterType.none,
    );

    // 필터 적용
    final filtered = ImageProcessingService.applyFilter(image, filterType);

    // 원본과 결과가 다르면 원본 dispose
    if (filtered != image) {
      image.dispose();
    }

    // 바이트로 인코딩
    final bytes = filtered.encode(ext: '.jpg');
    filtered.dispose();

    AppLogger.success('Isolate: 필터 적용 완료 (${bytes.length} bytes)');
    return Uint8List.fromList(bytes);
  } catch (e, stackTrace) {
    AppLogger.error('Isolate: 필터 적용 중 에러', error: e, stackTrace: stackTrace);
    return null;
  }
}

/// Isolate에서 파이프라인 처리
///
/// [params]: 이미지 바이트 및 파이프라인 타입 정보
/// Returns: 처리된 이미지의 바이트 배열, 실패시 null
Future<Uint8List?> isolateProcessPipeline(PipelineParams params) async {
  try {
    AppLogger.info('Isolate: 파이프라인 처리 시작 - ${params.pipelineType}');

    // 바이트에서 이미지 디코딩
    final image = CvImage.fromBytes(params.imageBytes);
    if (image == null) {
      AppLogger.warning('Isolate: 이미지 디코딩 실패');
      return null;
    }

    // 파이프라인 타입에 따라 처리
    CvImage result;
    switch (params.pipelineType) {
      case 'document':
        result = ImageProcessingService.processDocumentScanner(image);
        break;
      case 'enhancement':
        result = ImageProcessingService.processPhotoEnhancement(image);
        break;
      case 'color':
        result = ImageProcessingService.processColorDetection(image);
        break;
      default:
        AppLogger.warning('Isolate: 알 수 없는 파이프라인 타입 - ${params.pipelineType}');
        result = image;
    }

    // 원본과 결과가 다르면 원본 dispose
    if (result != image) {
      image.dispose();
    }

    // 바이트로 인코딩
    final bytes = result.encode(ext: '.jpg');
    result.dispose();

    AppLogger.success('Isolate: 파이프라인 처리 완료 (${bytes.length} bytes)');
    return Uint8List.fromList(bytes);
  } catch (e, stackTrace) {
    AppLogger.error('Isolate: 파이프라인 처리 중 에러', error: e, stackTrace: stackTrace);
    return null;
  }
}
