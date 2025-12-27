/// 필터 타입 열거형
/// 
/// 이미지에 적용 가능한 다양한 OpenCV 필터와 변환을 정의합니다.
enum FilterType {
  /// 필터 없음 - 원본 이미지
  none,
  
  /// 흑백 변환 - BGR을 Grayscale로 변환
  grayscale,
  
  /// 가우시안 블러 - 이미지를 부드럽게 만듦
  blur,
  
  /// Canny 엣지 검출 - 이미지의 경계선 검출
  canny,
  
  /// 90도 회전 - 이미지를 시계방향으로 90도 회전
  rotate,
  
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
      case FilterType.grayscale:
        return 'Grayscale';
      case FilterType.blur:
        return 'Blur';
      case FilterType.canny:
        return 'Canny';
      case FilterType.rotate:
        return 'Rotate';
      case FilterType.draw:
        return 'Draw';
    }
  }
}
