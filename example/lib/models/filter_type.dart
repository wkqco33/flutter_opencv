/// 필터 타입 열거형
///
/// 이미지에 적용 가능한 다양한 OpenCV 필터와 변환을 정의합니다.
enum FilterType {
  /// 필터 없음 - 원본 이미지
  none,

  // ===== 색상 변환 (Color Conversion) =====
  /// 흑백 변환 - BGR을 Grayscale로 변환
  grayscale,

  /// RGB 변환 - BGR을 RGB로 변환
  rgb,

  /// HSV 변환 - BGR을 HSV로 변환
  hsv,

  /// LAB 변환 - BGR을 LAB로 변환
  lab,

  // ===== 이미지 변환 (Transformations) =====
  /// 90도 회전 - 이미지를 시계방향으로 90도 회전
  rotate,

  /// 수평 뒤집기 - 이미지를 좌우로 뒤집기
  flipHorizontal,

  /// 수직 뒤집기 - 이미지를 상하로 뒤집기
  flipVertical,

  /// 양축 뒤집기 - 이미지를 상하좌우로 뒤집기
  flipBoth,

  // ===== 블러 필터 (Blur Filters) =====
  /// 가우시안 블러 - 이미지를 부드럽게 만듦
  blur,

  /// 미디언 블러 - 소금 후추 노이즈 제거에 효과적
  medianBlur,

  /// 양방향 필터 - 엣지 보존하며 노이즈 제거
  bilateralFilter,

  // ===== 엣지 검출 (Edge Detection) =====
  /// Canny 엣지 검출 - 이미지의 경계선 검출
  canny,

  /// Sobel 엣지 검출 - 수평/수직 방향 그래디언트
  sobel,

  /// Laplacian 엣지 검출 - 2차 미분 기반 엣지 검출
  laplacian,

  // ===== 이미지 향상 (Image Enhancement) =====
  /// 샤프닝 - 이미지를 선명하게 만듦
  sharpen,

  /// 히스토그램 평활화 - 명암 대비 개선
  equalizeHist,

  // ===== 형태학 연산 (Morphological Operations) =====
  /// 침식 - 객체를 얇게 만듦
  erode,

  /// 팽창 - 객체를 두껍게 만듦
  dilate,

  /// 열림 - 침식 후 팽창 (노이즈 제거)
  morphOpen,

  /// 닫힘 - 팽창 후 침식 (구멍 메우기)
  morphClose,

  /// 그래디언트 - 팽창과 침식의 차이
  morphGradient,

  /// 탑햇 - 원본과 열림의 차이
  morphTophat,

  /// 블랙햇 - 닫힘과 원본의 차이
  morphBlackhat,

  // ===== 임계값 처리 (Thresholding) =====
  /// 고정 임계값 - 이진화
  threshold,

  /// 적응형 임계값 - 지역적 이진화
  adaptiveThreshold,

  // ===== 노이즈 제거 (Denoising) =====
  /// 그레이스케일 노이즈 제거
  denoise,

  /// 컬러 노이즈 제거
  denoiseColored,

  // ===== 그리기 (Drawing) =====
  /// 도형 그리기 - 샘플 사각형과 원을 이미지에 그림
  draw,
}

/// FilterType 확장 메서드
extension FilterTypeExtension on FilterType {
  /// 필터 이름 반환
  String get displayName {
    switch (this) {
      case FilterType.none:
        return 'None';

      // 색상 변환
      case FilterType.grayscale:
        return 'Grayscale';
      case FilterType.rgb:
        return 'RGB';
      case FilterType.hsv:
        return 'HSV';
      case FilterType.lab:
        return 'LAB';

      // 이미지 변환
      case FilterType.rotate:
        return 'Rotate';
      case FilterType.flipHorizontal:
        return 'Flip H';
      case FilterType.flipVertical:
        return 'Flip V';
      case FilterType.flipBoth:
        return 'Flip Both';

      // 블러 필터
      case FilterType.blur:
        return 'Blur';
      case FilterType.medianBlur:
        return 'Median';
      case FilterType.bilateralFilter:
        return 'Bilateral';

      // 엣지 검출
      case FilterType.canny:
        return 'Canny';
      case FilterType.sobel:
        return 'Sobel';
      case FilterType.laplacian:
        return 'Laplacian';

      // 이미지 향상
      case FilterType.sharpen:
        return 'Sharpen';
      case FilterType.equalizeHist:
        return 'Equalize';

      // 형태학 연산
      case FilterType.erode:
        return 'Erode';
      case FilterType.dilate:
        return 'Dilate';
      case FilterType.morphOpen:
        return 'Open';
      case FilterType.morphClose:
        return 'Close';
      case FilterType.morphGradient:
        return 'Gradient';
      case FilterType.morphTophat:
        return 'Tophat';
      case FilterType.morphBlackhat:
        return 'Blackhat';

      // 임계값 처리
      case FilterType.threshold:
        return 'Threshold';
      case FilterType.adaptiveThreshold:
        return 'Adaptive';

      // 노이즈 제거
      case FilterType.denoise:
        return 'Denoise';
      case FilterType.denoiseColored:
        return 'Denoise C';

      // 그리기
      case FilterType.draw:
        return 'Draw';
    }
  }
}
