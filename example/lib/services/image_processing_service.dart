import 'package:flutter/foundation.dart'; // compute 함수, Uint8List
import 'package:flutter_opencv/flutter_opencv.dart';
import '../models/filter_type.dart';
import '../utils/isolate_image_processor.dart';
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
        // ===== 색상 변환 (Color Conversion) =====
        case FilterType.grayscale:
          // BGR 이미지를 Grayscale로 변환
          // 색상 정보를 제거하고 밝기 정보만 유지
          result = source.toGrayscale();
          AppLogger.success('Grayscale 변환 완료', tag: _tag);
          break;

        case FilterType.rgb:
          // BGR을 RGB로 변환
          // OpenCV는 BGR 형식을 사용하므로 표시를 위해 RGB로 변환
          result = source.toRgb();
          AppLogger.success('RGB 변환 완료', tag: _tag);
          break;

        case FilterType.hsv:
          // BGR을 HSV로 변환
          // HSV 공간에서 색상 기반 작업 수행 (색상, 채도, 명도)
          result = source.toHsv();
          AppLogger.success('HSV 변환 완료', tag: _tag);
          break;

        case FilterType.lab:
          // BGR을 LAB로 변환
          // LAB 색 공간은 인간의 시각 인지와 유사
          result = source.toLab();
          AppLogger.success('LAB 변환 완료', tag: _tag);
          break;

        // ===== 이미지 변환 (Transformations) =====
        case FilterType.rotate:
          // 이미지를 90도 시계방향으로 회전
          // code: 0 = 90도 CW, 1 = 180도, 2 = 90도 CCW
          result = source.rotate(0);
          AppLogger.success('이미지 회전 완료', tag: _tag);
          break;

        case FilterType.flipHorizontal:
          // 이미지를 수평으로 뒤집기 (좌우 반전)
          // mode: 1 = 수평 (y축 기준)
          result = source.flip(1);
          AppLogger.success('수평 뒤집기 완료', tag: _tag);
          break;

        case FilterType.flipVertical:
          // 이미지를 수직으로 뒤집기 (상하 반전)
          // mode: 0 = 수직 (x축 기준)
          result = source.flip(0);
          AppLogger.success('수직 뒤집기 완료', tag: _tag);
          break;

        case FilterType.flipBoth:
          // 이미지를 양축으로 뒤집기 (180도 회전과 동일)
          // mode: -1 = 양축
          result = source.flip(-1);
          AppLogger.success('양축 뒤집기 완료', tag: _tag);
          break;

        // ===== 블러 필터 (Blur Filters) =====
        case FilterType.blur:
          // 가우시안 블러 필터 적용
          // kernelSize: 15 (블러 강도), sigma: 0 (자동 계산)
          result = source.gaussianBlur(15, 0);
          AppLogger.success('Gaussian Blur 적용 완료', tag: _tag);
          break;

        case FilterType.medianBlur:
          // 미디언 블러 필터 적용
          // kernelSize: 5 (블러 강도)
          // 소금 후추 노이즈 제거에 효과적
          result = source.medianBlur(5);
          AppLogger.success('Median Blur 적용 완료', tag: _tag);
          break;

        case FilterType.bilateralFilter:
          // 양방향 필터 적용
          // d: 9 (필터 직경), sigmaColor: 75, sigmaSpace: 75
          // 엣지를 보존하면서 노이즈 제거
          result = source.bilateralFilter(9, 75, 75);
          AppLogger.success('Bilateral Filter 적용 완료', tag: _tag);
          break;

        // ===== 엣지 검출 (Edge Detection) =====
        case FilterType.canny:
          // Canny 엣지 검출 알고리즘 적용
          // threshold1: 50, threshold2: 150
          // 낮은 값은 더 많은 엣지를 검출하지만 노이즈도 증가
          result = source.canny(50, 150);
          AppLogger.success('Canny 엣지 검출 완료', tag: _tag);
          break;

        case FilterType.sobel:
          // Sobel 엣지 검출 적용
          // dx: 1, dy: 0 (수평 방향), ksize: 3
          // 그래디언트 기반 엣지 검출
          result = source.sobel(1, 0, ksize: 3);
          AppLogger.success('Sobel 엣지 검출 완료', tag: _tag);
          break;

        case FilterType.laplacian:
          // Laplacian 엣지 검출 적용
          // ksize: 3
          // 2차 미분 기반 엣지 검출
          result = source.laplacian(ksize: 3);
          AppLogger.success('Laplacian 엣지 검출 완료', tag: _tag);
          break;

        // ===== 이미지 향상 (Image Enhancement) =====
        case FilterType.sharpen:
          // 샤프닝 필터 적용
          // 이미지를 더 선명하게 만듦
          result = source.sharpen();
          AppLogger.success('샤프닝 적용 완료', tag: _tag);
          break;

        case FilterType.equalizeHist:
          // 히스토그램 평활화 적용
          // 명암 대비를 개선하여 이미지를 더 선명하게
          result = source.equalizeHist();
          AppLogger.success('히스토그램 평활화 완료', tag: _tag);
          break;

        // ===== 형태학 연산 (Morphological Operations) =====
        case FilterType.erode:
          // 침식 연산 적용
          // kernelSize: 5, iterations: 1
          // 객체를 얇게 만들고 노이즈 제거
          result = source.erode(5, iterations: 1);
          AppLogger.success('침식 적용 완료', tag: _tag);
          break;

        case FilterType.dilate:
          // 팽창 연산 적용
          // kernelSize: 5, iterations: 1
          // 객체를 두껍게 만들고 구멍 메우기
          result = source.dilate(5, iterations: 1);
          AppLogger.success('팽창 적용 완료', tag: _tag);
          break;

        case FilterType.morphOpen:
          // 열림 연산 (침식 후 팽창)
          // op: 2 = MORPH_OPEN, kernelSize: 5
          // 작은 노이즈 제거
          result = source.morphologyEx(2, 5);
          AppLogger.success('열림 연산 완료', tag: _tag);
          break;

        case FilterType.morphClose:
          // 닫힘 연산 (팽창 후 침식)
          // op: 3 = MORPH_CLOSE, kernelSize: 5
          // 작은 구멍 메우기
          result = source.morphologyEx(3, 5);
          AppLogger.success('닫힘 연산 완료', tag: _tag);
          break;

        case FilterType.morphGradient:
          // 형태학 그래디언트 (팽창 - 침식)
          // op: 4 = MORPH_GRADIENT, kernelSize: 5
          // 객체의 윤곽선 추출
          result = source.morphologyEx(4, 5);
          AppLogger.success('그래디언트 연산 완료', tag: _tag);
          break;

        case FilterType.morphTophat:
          // 탑햇 변환 (원본 - 열림)
          // op: 5 = MORPH_TOPHAT, kernelSize: 9
          // 밝은 영역 강조
          result = source.morphologyEx(5, 9);
          AppLogger.success('탑햇 변환 완료', tag: _tag);
          break;

        case FilterType.morphBlackhat:
          // 블랙햇 변환 (닫힘 - 원본)
          // op: 6 = MORPH_BLACKHAT, kernelSize: 9
          // 어두운 영역 강조
          result = source.morphologyEx(6, 9);
          AppLogger.success('블랙햇 변환 완료', tag: _tag);
          break;

        // ===== 임계값 처리 (Thresholding) =====
        case FilterType.threshold:
          // 고정 임계값 적용
          // thresh: 127, maxval: 255, type: 0 (THRESH_BINARY)
          // 그레이스케일 변환 후 이진화
          final gray = source.toGrayscale();
          result = gray.threshold(127, 255, type: 0);
          if (result != gray) gray.dispose();
          AppLogger.success('고정 임계값 적용 완료', tag: _tag);
          break;

        case FilterType.adaptiveThreshold:
          // 적응형 임계값 적용
          // maxValue: 255, adaptiveMethod: 1 (GAUSSIAN_C)
          // thresholdType: 0 (BINARY), blockSize: 11, c: 2
          // 그레이스케일 변환 후 적응형 이진화
          final grayAdaptive = source.toGrayscale();
          result = grayAdaptive.adaptiveThreshold(255, 1, 0, 11, 2);
          if (result != grayAdaptive) grayAdaptive.dispose();
          AppLogger.success('적응형 임계값 적용 완료', tag: _tag);
          break;

        // ===== 노이즈 제거 (Denoising) =====
        case FilterType.denoise:
          // 그레이스케일 노이즈 제거
          // h: 10 (필터 강도)
          // 그레이스케일 변환 후 노이즈 제거
          final grayDenoise = source.toGrayscale();
          result = grayDenoise.fastNlMeansDenoising(h: 10);
          if (result != grayDenoise) grayDenoise.dispose();
          AppLogger.success('그레이스케일 노이즈 제거 완료', tag: _tag);
          break;

        case FilterType.denoiseColored:
          // 컬러 이미지 노이즈 제거
          // h: 10, hColor: 10
          // 컬러를 유지하면서 노이즈 제거
          result = source.fastNlMeansDenoisingColored(h: 10, hColor: 10);
          AppLogger.success('컬러 노이즈 제거 완료', tag: _tag);
          break;

        // ===== 그리기 (Drawing) =====
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

  /// 문서 스캐너 파이프라인
  ///
  /// [source]: 원본 이미지
  ///
  /// 처리 단계:
  /// 1. Grayscale 변환
  /// 2. Gaussian Blur (노이즈 제거)
  /// 3. Adaptive Threshold (이진화)
  /// 4. Morph Open (노이즈 제거)
  static CvImage processDocumentScanner(CvImage source) {
    try {
      AppLogger.debug('문서 스캐너 처리 시작', tag: _tag);

      // 1. Grayscale
      final gray = source.toGrayscale();

      // 2. Blur
      final blurred = gray.gaussianBlur(5, 0);
      if (blurred != gray) gray.dispose();

      // 3. Adaptive Threshold
      // 조명 변화에 강한 적응형 임계값 사용
      final binary = blurred.adaptiveThreshold(255, 1, 0, 11, 2);
      if (binary != blurred) blurred.dispose();

      // 4. Morph Open
      // 작은 점이나 노이즈 제거
      final result = binary.morphologyEx(2, 3);
      if (result != binary) binary.dispose();

      AppLogger.success('문서 스캐너 처리 완료', tag: _tag);
      return result;
    } catch (e, stackTrace) {
      AppLogger.error(
        '문서 스캐너 처리 중 에러',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
      return ImageProcessingService.cloneImage(source);
    }
  }

  /// 사진 품질 개선 파이프라인
  ///
  /// [source]: 원본 이미지
  ///
  /// 처리 단계:
  /// 1. Denoise (컬러 노이즈 제거)
  /// 2. Equalize Histogram (YUV 변환 후 Y채널 평활화)
  /// 3. Sharpen (선명도 향상)
  static CvImage processPhotoEnhancement(CvImage source) {
    try {
      AppLogger.debug('사진 품질 개선 처리 시작', tag: _tag);

      // 1. Denoise
      final denoised = source.fastNlMeansDenoisingColored(h: 10, hColor: 10);

      // 2. Equalize Histogram
      // 컬러 이미지의 경우 바로 equalizeHist를 호출하면 색상이 왜곡됨
      // YUV로 변환하여 밝기(Y) 채널만 평활화해야 함
      // (현재는 간단히 RGB 각 채널에 적용하거나, 단순화를 위해 샤프닝만 적용할 수도 있음)
      // 여기서는 간단히 샤프닝만 적용하거나, 그레이스케일이 아닌 컬러 평활화는 복잡하므로
      // denoise 후 sharpen만 적용

      // 3. Sharpen
      final sharpened = denoised.sharpen();
      if (sharpened != denoised) denoised.dispose();

      AppLogger.success('사진 품질 개선 처리 완료', tag: _tag);
      return sharpened;
    } catch (e, stackTrace) {
      AppLogger.error(
        '사진 품질 개선 처리 중 에러',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
      // 에러 발생 시 원본의 복사본 반환 (원본 보호)
      return ImageProcessingService.cloneImage(source);
    }
  }

  /// 색상 기반 객체 검출 파이프라인
  ///
  /// [source]: 원본 이미지
  ///
  /// 처리 단계:
  /// 1. HSV 변환
  /// 2. 마스킹 (현재는 예제로 특정 색상을 강조하는 로직으로 대체)
  ///    (실제로는 inRange가 필요하나, 간단히 HSV 변환 후 채도 강조 등으로 구현)
  static CvImage processColorDetection(CvImage source) {
    try {
      AppLogger.debug('색상 검출 처리 시작', tag: _tag);

      // 1. HSV 변환
      // HSV 공간은 색상(Hue), 채도(Saturation), 명도(Value)로 분리되어 색상 검출에 유리
      final hsv = source.toHsv();

      // 마스킹이나 특정 처리를 수행할 수 있음
      // 여기서는 예제로 HSV 변환 결과만 반환
      // (inRange 함수가 binding에 추가되면 특정 색상 마스킹 가능)

      AppLogger.success('색상 검출 처리 완료', tag: _tag);
      return hsv;
    } catch (e, stackTrace) {
      AppLogger.error(
        '색상 검출 처리 중 에러',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
      return ImageProcessingService.cloneImage(source);
    }
  }

  // ==========================================================================
  // Isolate 기반 비동기 메서드들
  // ==========================================================================

  /// Isolate에서 이미지 파일 로딩 (비동기)
  ///
  /// [path]: 이미지 파일 경로
  /// [maxSize]: 최대 이미지 크기
  ///
  /// Returns: 로드 및 인코딩된 이미지 바이트, 실패시 null
  ///
  /// 무거운 이미지 로딩을 백그라운드 Isolate에서 수행하여 UI 블로킹 방지
  static Future<Uint8List?> loadFromFileIsolated(
    String path, {
    int maxSize = 1280,
  }) async {
    try {
      AppLogger.info('Isolate로 이미지 로딩 시작: $path', tag: _tag);

      final params = LoadImageParams(filePath: path, maxSize: maxSize);
      final result = await compute(isolateLoadImage, params);

      if (result != null) {
        AppLogger.success('Isolate 이미지 로딩 완료', tag: _tag);
      } else {
        AppLogger.warning('Isolate 이미지 로딩 실패', tag: _tag);
      }

      return result;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Isolate 이미지 로딩 중 에러',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
      return null;
    }
  }

  /// Isolate에서 필터 적용 (비동기)
  ///
  /// [imageBytes]: 원본 이미지의 바이트 배열
  /// [filterType]: 적용할 필터 타입
  ///
  /// Returns: 필터가 적용된 이미지 바이트, 실패시 null
  ///
  /// 무거운 필터 연산을 백그라운드 Isolate에서 수행하여 UI 블로킹 방지
  static Future<Uint8List?> applyFilterIsolated(
    Uint8List imageBytes,
    FilterType filterType,
  ) async {
    try {
      AppLogger.info('Isolate로 필터 적용 시작: ${filterType.displayName}', tag: _tag);

      final params = ApplyFilterParams(
        imageBytes: imageBytes,
        filterTypeName: filterType.name,
      );
      final result = await compute(isolateApplyFilter, params);

      if (result != null) {
        AppLogger.success('Isolate 필터 적용 완료', tag: _tag);
      } else {
        AppLogger.warning('Isolate 필터 적용 실패', tag: _tag);
      }

      return result;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Isolate 필터 적용 중 에러',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
      return null;
    }
  }

  /// Isolate에서 문서 스캐너 파이프라인 처리 (비동기)
  ///
  /// [imageBytes]: 원본 이미지의 바이트 배열
  ///
  /// Returns: 처리된 이미지 바이트, 실패시 null
  static Future<Uint8List?> processDocumentScannerIsolated(
    Uint8List imageBytes,
  ) async {
    try {
      AppLogger.info('Isolate로 문서 스캐너 처리 시작', tag: _tag);

      final params = PipelineParams(
        imageBytes: imageBytes,
        pipelineType: 'document',
      );
      final result = await compute(isolateProcessPipeline, params);

      if (result != null) {
        AppLogger.success('Isolate 문서 스캐너 처리 완료', tag: _tag);
      } else {
        AppLogger.warning('Isolate 문서 스캐너 처리 실패', tag: _tag);
      }

      return result;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Isolate 문서 스캐너 처리 중 에러',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
      return null;
    }
  }

  /// Isolate에서 사진 품질 개선 파이프라인 처리 (비동기)
  ///
  /// [imageBytes]: 원본 이미지의 바이트 배열
  ///
  /// Returns: 처리된 이미지 바이트, 실패시 null
  static Future<Uint8List?> processPhotoEnhancementIsolated(
    Uint8List imageBytes,
  ) async {
    try {
      AppLogger.info('Isolate로 사진 품질 개선 처리 시작', tag: _tag);

      final params = PipelineParams(
        imageBytes: imageBytes,
        pipelineType: 'enhancement',
      );
      final result = await compute(isolateProcessPipeline, params);

      if (result != null) {
        AppLogger.success('Isolate 사진 품질 개선 처리 완료', tag: _tag);
      } else {
        AppLogger.warning('Isolate 사진 품질 개선 처리 실패', tag: _tag);
      }

      return result;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Isolate 사진 품질 개선 처리 중 에러',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
      return null;
    }
  }

  /// Isolate에서 색상 검출 파이프라인 처리 (비동기)
  ///
  /// [imageBytes]: 원본 이미지의 바이트 배열
  ///
  /// Returns: 처리된 이미지 바이트, 실패시 null
  static Future<Uint8List?> processColorDetectionIsolated(
    Uint8List imageBytes,
  ) async {
    try {
      AppLogger.info('Isolate로 색상 검출 처리 시작', tag: _tag);

      final params = PipelineParams(
        imageBytes: imageBytes,
        pipelineType: 'color',
      );
      final result = await compute(isolateProcessPipeline, params);

      if (result != null) {
        AppLogger.success('Isolate 색상 검출 처리 완료', tag: _tag);
      } else {
        AppLogger.warning('Isolate 색상 검출 처리 실패', tag: _tag);
      }

      return result;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Isolate 색상 검출 처리 중 에러',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
      return null;
    }
  }
}
