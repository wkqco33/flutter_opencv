# Flutter OpenCV - 기능 목록

## 📌 지원 기능

### 1. 색상 변환 (Color Conversion)

- `toGrayscale()` - BGR to Grayscale
- `toRgb()` - BGR to RGB
- `toHsv()` - BGR to HSV
- `hsvToBgr()` - HSV to BGR
- `toLab()` - BGR to LAB
- `labToBgr()` - LAB to BGR

**사용 예제:**

```dart
final grayImage = originalImage.toGrayscale();
final hsvImage = originalImage.toHsv();
```

### 2. 이미지 변환 (Transformations)

- `resize(width, height, {interpolation})` - 이미지 리사이즈
- `flip(mode)` - 이미지 뒤집기 (0: x축, 1: y축, -1: 양축)
- `rotate(code)` - 이미지 회전 (0: 90° CW, 1: 180°, 2: 90° CCW)

**사용 예제:**

```dart
final resized = image.resize(800, 600);
final flipped = image.flip(0); // 수평 뒤집기
final rotated = image.rotate(0); // 90도 시계방향 회전
```

### 3. 블러 필터 (Blur Filters)

- `gaussianBlur(kernelSize, sigma)` - 가우시안 블러
- `medianBlur(kernelSize)` - 미디언 블러 (소금 후추 노이즈 제거에 효과적)
- `bilateralFilter(d, sigmaColor, sigmaSpace)` - 양방향 필터 (엣지 보존하며 노이즈 제거)

**사용 예제:**

```dart
final blurred = image.gaussianBlur(5, 1.5);
final denoised = image.medianBlur(5);
final smoothed = image.bilateralFilter(9, 75, 75);
```

### 4. 엣지 검출 (Edge Detection)

- `canny(threshold1, threshold2)` - Canny 엣지 검출
- `sobel(dx, dy, {ksize})` - Sobel 엣지 검출
- `laplacian({ksize})` - Laplacian 엣지 검출

**사용 예제:**

```dart
final edges = image.canny(100, 200);
final sobelX = image.sobel(1, 0, ksize: 3);
final laplace = image.laplacian(ksize: 3);
```

### 5. 이미지 향상 (Image Enhancement)

- `sharpen()` - 샤프닝 필터
- `equalizeHist()` - 히스토그램 평활화 (명암 대비 개선)

**사용 예제:**

```dart
final sharpened = image.sharpen();
final enhanced = image.equalizeHist();
```

### 6. 형태학 연산 (Morphological Operations)

- `erode(kernelSize, {iterations})` - 침식 (객체를 얇게)
- `dilate(kernelSize, {iterations})` - 팽창 (객체를 두껍게)
- `morphologyEx(op, kernelSize)` - 형태학 연산
  - 0: MORPH_ERODE - 침식
  - 1: MORPH_DILATE - 팽창
  - 2: MORPH_OPEN - 열림 (침식 후 팽창)
  - 3: MORPH_CLOSE - 닫힘 (팽창 후 침식)
  - 4: MORPH_GRADIENT - 그래디언트
  - 5: MORPH_TOPHAT - 탑햇
  - 6: MORPH_BLACKHAT - 블랙햇

**사용 예제:**

```dart
final eroded = image.erode(5, iterations: 1);
final dilated = image.dilate(5, iterations: 1);
final opened = image.morphologyEx(2, 5); // MORPH_OPEN
```

### 7. 임계값 처리 (Thresholding)

- `threshold(thresh, maxval, {type})` - 고정 임계값
  - 0: THRESH_BINARY
  - 1: THRESH_BINARY_INV
  - 2: THRESH_TRUNC
  - 3: THRESH_TOZERO
  - 4: THRESH_TOZERO_INV
- `adaptiveThreshold(maxValue, adaptiveMethod, thresholdType, blockSize, c)` - 적응형 임계값
  - adaptiveMethod: 0: MEAN_C, 1: GAUSSIAN_C
  - thresholdType: 0: BINARY, 1: BINARY_INV

**사용 예제:**

```dart
final binary = grayImage.threshold(127, 255, type: 0);
final adaptive = grayImage.adaptiveThreshold(255, 1, 0, 11, 2);
```

### 8. 노이즈 제거 (Denoising)

- `fastNlMeansDenoising({h, templateWindowSize, searchWindowSize})` - 그레이스케일 노이즈 제거
- `fastNlMeansDenoisingColored({h, hColor, templateWindowSize, searchWindowSize})` - 컬러 이미지 노이즈 제거

**사용 예제:**

```dart
final denoised = grayImage.fastNlMeansDenoising(h: 10);
final denoisedColor = colorImage.fastNlMeansDenoisingColored(h: 10, hColor: 10);
```

### 9. 그리기 기능 (Drawing)

- `drawRectangle(x, y, width, height, r, g, b, thickness)` - 사각형 그리기
- `drawCircle(centerX, centerY, radius, r, g, b, thickness)` - 원 그리기
- `drawLine(x1, y1, x2, y2, r, g, b, thickness)` - 선 그리기

**사용 예제:**

```dart
image.drawRectangle(100, 100, 200, 150, 255, 0, 0, 2); // 빨간 사각형
image.drawCircle(320, 240, 50, 0, 255, 0, 3); // 초록 원
image.drawLine(0, 0, 640, 480, 0, 0, 255, 2); // 파란 선
```

### 10. 비디오 캡처 (Video Capture)

- `CvVideoCapture.create(index)` - 카메라 열기
- `read(dst)` - 프레임 읽기
- `get(propId)` - 속성 가져오기
- `set(propId, value)` - 속성 설정하기

**사용 예제:**

```dart
final capture = CvVideoCapture.create(0); // 기본 카메라
if (capture != null) {
  final frame = CvImage.wrap(/* frame pointer */);
  final success = capture.read(frame);
  capture.dispose();
}
```

## 🎯 실전 활용 예제

### 문서 스캐너

```dart
// 1. 그레이스케일 변환
final gray = image.toGrayscale();

// 2. 블러로 노이즈 제거
final blurred = gray.gaussianBlur(5, 0);

// 3. 적응형 임계값으로 이진화
final binary = blurred.adaptiveThreshold(255, 1, 0, 11, 2);

// 4. 형태학 연산으로 노이즈 제거
final cleaned = binary.morphologyEx(2, 3); // OPEN
```

### 얼굴/객체 강조

```dart
// 1. 양방향 필터로 피부 부드럽게
final smoothed = image.bilateralFilter(9, 75, 75);

// 2. 엣지 검출
final edges = image.canny(100, 200);

// 3. 엣지에 객체 강조
// ... edges를 활용한 추가 처리
```

### 사진 품질 개선

```dart
// 1. 노이즈 제거
final denoised = image.fastNlMeansDenoisingColored(h: 10, hColor: 10);

// 2. 히스토그램 평활화
final enhanced = denoised.equalizeHist();

// 3. 샤프닝
final sharpened = enhanced.sharpen();
```

### 색상 기반 객체 검출

```dart
// 1. HSV로 변환
final hsv = image.toHsv();

// 2. 색상 범위로 마스크 생성 (별도 구현 필요)
// ... inRange 등을 사용

// 3. 형태학 연산으로 마스크 정제
final mask = /* mask */.morphologyEx(3, 5); // CLOSE
```

## 📝 참고사항

- 모든 필터 연산은 새로운 `CvImage` 객체를 반환합니다 (원본 불변)
- 그리기 함수들은 in-place로 동작합니다 (원본 수정)
- 메모리는 자동으로 관리되지만, 필요시 `dispose()`를 호출하여 수동 해제 가능
- kernelSize는 홀수여야 합니다 (자동 보정됨)

## 🔗 추가 정보

더 자세한 사용법은 [OpenCV 공식 문서](https://docs.opencv.org/)를 참조하세요.
