import 'dart:typed_data';
import 'package:flutter_opencv/flutter_opencv.dart';
import '../models/filter_type.dart';
import '../utils/logger.dart';

/// 이미지 처리 서비스
///
/// OpenCV를 사용한 이미지 로드, 필터 적용, 인코딩 등의 기능을 제공합니다.
/// 모든 메서드는 에러 핸들링과 로깅을 포함합니다.
class ImageProcessingService {
  static const String _tag = 'ImageProcessing';

  /// 파일 경로에서 이미지 로드
  ///
  /// [path]: 이미지 파일 경로
  /// [maxSize]: 최대 이미지 크기 (성능 최적화용)
  ///
  /// Returns: 로드된 [CvImage] 또는 실패시 null
  ///
  /// 예시:
  /// ```dart
  /// final img = await ImageProcessingService.loadFromFile('/path/to/image.jpg');
  /// if (img != null) {
  ///   // 이미지 처리
  ///   img.dispose(); // 사용 후 메모리 해제 필수
  /// }
  /// ```
  static Future<CvImage?> loadFromFile(
    String path, {
    int maxSize = 1280,
  }) async {
    try {
      AppLogger.info('파일에서 이미지 로드 시작: $path', tag: _tag);

      // OpenCV를 사용하여 이미지 파일 읽기
      final image = CvImage.fromFile(path);

      if (image == null) {
        AppLogger.warning('이미지 로드 실패: 파일을 읽을 수 없음', tag: _tag);
        return null;
      }

      AppLogger.debug('원본 이미지 크기: ${image.width}x${image.height}', tag: _tag);

      // 이미지가 너무 큰 경우 리사이즈 (성능 최적화)
      if (image.width > maxSize || image.height > maxSize) {
        AppLogger.info('이미지 크기 조정 중...', tag: _tag);

        final aspectRatio = image.height / image.width;
        final newWidth = maxSize;
        final newHeight = (newWidth * aspectRatio).toInt();

        final resized = image.resize(newWidth, newHeight);
        image.dispose(); // 원본 이미지는 더 이상 필요 없으므로 해제

        AppLogger.success(
          '이미지 크기 조정 완료: ${resized.width}x${resized.height}',
          tag: _tag,
        );

        return resized;
      }

      AppLogger.success('이미지 로드 완료', tag: _tag);
      return image;
    } catch (e, stackTrace) {
      AppLogger.error(
        '이미지 로드 중 에러 발생',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
      return null;
    }
  }

  /// 바이트 배열에서 이미지 로드
  ///
  /// [bytes]: 이미지 바이트 데이터
  ///
  /// Returns: 로드된 [CvImage] 또는 실패시 null
  static CvImage? loadFromBytes(List<int> bytes) {
    try {
      AppLogger.debug('바이트에서 이미지 디코딩 시작 (${bytes.length} bytes)', tag: _tag);

      final image = CvImage.fromBytes(bytes);

      if (image == null) {
        AppLogger.warning('이미지 디코딩 실패', tag: _tag);
        return null;
      }

      AppLogger.success('이미지 디코딩 완료', tag: _tag);
      return image;
    } catch (e, stackTrace) {
      AppLogger.error(
        '이미지 디코딩 중 에러 발생',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
      return null;
    }
  }

  /// 필터를 적용하여 새 이미지 생성
  ///
  /// [source]: 원본 이미지
  /// [filterType]: 적용할 필터 타입
  ///
  /// Returns: 필터가 적용된 새 [CvImage]
  ///
  /// 주의: 반환된 이미지는 원본과 다른 새로운 객체이므로
  /// 원본 이미지를 계속 사용하려면 별도로 보관해야 합니다.
  static CvImage applyFilter(CvImage source, FilterType filterType) {
    try {
      AppLogger.debug('필터 적용 시작: ${filterType.displayName}', tag: _tag);

      CvImage result;

      switch (filterType) {
        case FilterType.grayscale:
          // BGR 이미지를 Grayscale로 변환
          // 색상 정보를 제거하고 밝기 정보만 유지
          result = source.toGrayscale();
          AppLogger.success('Grayscale 변환 완료', tag: _tag);
          break;

        case FilterType.blur:
          // 가우시안 블러 필터 적용
          // kernelSize: 15 (블러 강도), sigma: 0 (자동 계산)
          result = source.gaussianBlur(15, 0);
          AppLogger.success('Gaussian Blur 적용 완료', tag: _tag);
          break;

        case FilterType.canny:
          // Canny 엣지 검출 알고리즘 적용
          // threshold1: 50, threshold2: 150
          // 낮은 값은 더 많은 엣지를 검출하지만 노이즈도 증가
          result = source.canny(50, 150);
          AppLogger.success('Canny 엣지 검출 완료', tag: _tag);
          break;

        case FilterType.rotate:
          // 이미지를 90도 시계방향으로 회전
          // code: 0 = 90도 CW, 1 = 180도, 2 = 90도 CCW
          result = source.rotate(0);
          AppLogger.success('이미지 회전 완료', tag: _tag);
          break;

        case FilterType.draw:
          // 이미지에 도형 그리기 (In-place 수정)
          // 원본 이미지를 직접 수정하므로 복사본을 사용해야 함

          // 빨간색 사각형 그리기
          // (50, 50) 위치에 100x100 크기, 선 두께 3
          source.drawRectangle(50, 50, 100, 100, 0, 0, 255, 3);

          // 초록색 원 그리기
          // (150, 150) 중심, 반지름 50, 선 두께 3
          source.drawCircle(150, 150, 50, 0, 255, 0, 3);

          result = source;
          AppLogger.success('도형 그리기 완료', tag: _tag);
          break;

        case FilterType.none:
          // 필터 없음 - 원본 그대로 반환
          result = source;
          AppLogger.debug('필터 없음 - 원본 반환', tag: _tag);
          break;
      }

      return result;
    } catch (e, stackTrace) {
      AppLogger.error(
        '필터 적용 중 에러 발생: ${filterType.displayName}',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
      // 에러 발생시 원본 이미지 반환
      return source;
    }
  }

  /// 이미지를 바이트 배열로 인코딩
  ///
  /// [image]: 인코딩할 이미지
  /// [format]: 이미지 포맷 ('.jpg', '.png' 등)
  ///
  /// Returns: 인코딩된 바이트 배열
  ///
  /// JPG는 손실 압축으로 파일 크기가 작지만 품질 저하가 있고,
  /// PNG는 무손실 압축으로 품질은 좋지만 파일 크기가 큽니다.
  static Uint8List encodeImage(CvImage image, {String format = '.jpg'}) {
    try {
      AppLogger.debug('이미지 인코딩 시작: $format', tag: _tag);

      final bytes = image.encode(ext: format);
      final result = Uint8List.fromList(bytes);

      AppLogger.success('이미지 인코딩 완료: ${result.length} bytes', tag: _tag);

      return result;
    } catch (e, stackTrace) {
      AppLogger.error(
        '이미지 인코딩 중 에러 발생',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
      // 에러 발생시 빈 바이트 배열 반환
      return Uint8List(0);
    }
  }

  /// 이미지 복사본 생성
  ///
  /// [image]: 복사할 이미지
  ///
  /// Returns: 원본과 동일한 내용의 새 이미지
  ///
  /// OpenCV에는 직접적인 clone 메서드가 없으므로
  /// resize를 동일한 크기로 수행하여 복사본을 생성합니다.
  static CvImage cloneImage(CvImage image) {
    try {
      AppLogger.debug('이미지 복사 시작: ${image.width}x${image.height}', tag: _tag);

      // 동일한 크기로 resize하여 복사본 생성
      final clone = image.resize(image.width, image.height);

      AppLogger.success('이미지 복사 완료', tag: _tag);
      return clone;
    } catch (e, stackTrace) {
      AppLogger.error(
        '이미지 복사 중 에러 발생',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
      rethrow;
    }
  }

  /// 데모용 기본 이미지 생성
  ///
  /// Returns: 샘플 도형이 그려진 640x480 이미지
  ///
  /// 앱 시작시 표시할 기본 이미지를 생성합니다.
  static CvImage? createDefaultImage() {
    try {
      AppLogger.info('기본 이미지 생성 시작', tag: _tag);

      // 1x1 투명 PNG 이미지의 바이트 데이터
      const List<int> minimalPng = [
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
        0x00,
        0x00,
        0x00,
        0x0D,
        0x49,
        0x48,
        0x44,
        0x52,
        0x00,
        0x00,
        0x00,
        0x01,
        0x00,
        0x00,
        0x00,
        0x01,
        0x08,
        0x02,
        0x00,
        0x00,
        0x00,
        0x90,
        0x77,
        0x53,
        0xDE,
        0x00,
        0x00,
        0x00,
        0x0C,
        0x49,
        0x44,
        0x41,
        0x54,
        0x08,
        0xD7,
        0x63,
        0xF8,
        0xCF,
        0xC0,
        0x00,
        0x00,
        0x03,
        0x01,
        0x01,
        0x00,
        0x18,
        0xDD,
        0x8D,
        0xB0,
        0x00,
        0x00,
        0x00,
        0x00,
        0x49,
        0x45,
        0x4E,
        0x44,
        0xAE,
        0x42,
        0x60,
        0x82,
      ];

      // 1x1 이미지를 로드
      final tempImg = CvImage.fromBytes(minimalPng);
      if (tempImg == null) {
        AppLogger.error('기본 이미지 생성 실패', tag: _tag);
        return null;
      }

      // 640x480으로 리사이즈
      final resized = tempImg.resize(640, 480);
      tempImg.dispose(); // 임시 이미지 해제

      // 회색 배경 그리기 (RGB: 240, 240, 240)
      // -1은 채우기를 의미 (내부를 색으로 채움)
      resized.drawRectangle(0, 0, 640, 480, 240, 240, 240, -1);

      // 분홍색 원 그리기 (중앙)
      resized.drawCircle(320, 240, 100, 255, 100, 100, 5);

      // 파란색 사각형 그리기
      resized.drawRectangle(200, 150, 240, 180, 0, 0, 255, 3);

      AppLogger.success('기본 이미지 생성 완료', tag: _tag);
      return resized;
    } catch (e, stackTrace) {
      AppLogger.error(
        '기본 이미지 생성 중 에러 발생',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
      return null;
    }
  }
}
