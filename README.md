# Flutter OpenCV FFI Plugin

Dart FFI를 통해 OpenCV C++ 라이브러리를 Flutter에서 사용하는 플러그인입니다.

## 주요 기능

### 🎨 색상 변환

- BGR ↔ Grayscale, RGB, HSV, LAB

### 🔄 이미지 변환

- 리사이즈, 회전, 뒤집기

### 🌫️ 블러/필터

- Gaussian Blur, Median Blur, Bilateral Filter
- Sharpen

### 📐 엣지 검출

- Canny, Sobel, Laplacian

### ✨ 이미지 향상

- 히스토그램 평활화
- 노이즈 제거 (Non-local Means)

### 🔲 형태학 연산

- Erode, Dilate, Open, Close, Gradient, Tophat, Blackhat

### 🎯 임계값 처리

- 고정 임계값, 적응형 임계값

### ✏️ 그리기

- 사각형, 원, 선

### 📹 비디오 캡처

- 웹캠 실시간 프레임 캡처

> 📖 **[전체 기능 목록 및 사용 예제 보기](FEATURES.md)**

## 설치

### 필수 요구사항

OpenCV 라이브러리 설치 필요.

#### macOS

```bash
brew install opencv
```

#### Linux

```bash
sudo apt-get update
sudo apt-get install libopencv-dev
```

### pubspec.yaml 설정

```yaml
dependencies:
  flutter_opencv:
    path: ./path/to/flutter_opencv
```

## 사용 방법

### 이미지 처리

```dart
// 이미지 로드
final image = CvImage.fromFile('path/to/image.jpg');

// 색상 변환
final gray = image.toGrayscale();
final hsv = image.toHsv();

// 필터 적용
final blurred = image.gaussianBlur(5, 1.5);
final denoised = image.medianBlur(5);
final edges = image.canny(100, 200);

// 이미지 향상
final enhanced = image.equalizeHist();
final sharpened = image.sharpen();

// 형태학 연산
final opened = gray.morphologyEx(2, 5); // MORPH_OPEN

// 임계값 처리
final binary = gray.threshold(127, 255);
final adaptive = gray.adaptiveThreshold(255, 1, 0, 11, 2);

// 변환
final resized = image.resize(800, 600);
final rotated = image.rotate(0); // 90도 시계방향

// 인코딩
final bytes = image.encode(ext: '.jpg');
```

### 비디오 캡처

```dart
final capture = CvVideoCapture.create(0);
if (capture != null) {
  // 프레임 읽기
  final frame = CvImage.wrap(/* ... */);
  if (capture.read(frame)) {
    // 프레임 처리
  }
  capture.dispose();
}
```

## 사용 방법dart

import 'package:flutter_opencv/flutter_opencv.dart';

CvImage? img = CvImage.fromFile('/path/to/image.jpg');

if (img != null) {
  CvImage resized = img.resize(300, 300);
  CvImage gray = resized.toGrayscale();
  CvImage edges = gray.canny(50, 150);
  Uint8List bytes = edges.encode(ext: ".jpg");
  
  // 메모리 해제
  img.dispose();
  resized.dispose();
  gray.dispose();
}

### 카메라 연동

```dart
import 'package:flutter_opencv/flutter_opencv.dart';
import 'dart:async';

CvVideoCapture? _cap;
Timer? _timer;

void startCamera() {
  _cap = CvVideoCapture.connect(0);
  
  if (_cap != null) {
    _cap!.set(3, 640); // 너비
    _cap!.set(4, 480); // 높이
    
    _timer = Timer.periodic(Duration(milliseconds: 33), (timer) {
      CvImage? frame = _cap!.read();
      if (frame != null) {
        // 필터 적용 또는 UI 업데이트
        frame.dispose();
      }
    });
  }
}

void stopCamera() {
  _timer?.cancel();
  _cap?.dispose();
}
```

## 예제

`example` 디렉토리에서 데모 앱 실행 가능.

### Linux에서 실행

```bash
cd example
flutter run -d linux
```

### Android에서 실행

**사전 준비:**

1. [OpenCV Android SDK](https://opencv.org/releases/) 다운로드 및 설정
2. `example/android/app/src/main/AndroidManifest.xml`에 권한 설정 확인
3. 권한 처리 패키지 설치: `flutter pub get`

**실행:**

```bash
cd example
flutter run -d android
```

**상세 가이드:** [ANDROID_BUILD.md](ANDROID_BUILD.md) 참조

## 라이선스

MIT 라이선스. OpenCV 라이브러리는 Apache 2.0 라이선스.

---

## 플랫폼 지원

현재 Linux에서 검증 완료. Android, iOS, Windows, macOS 지원 가능.

### Linux(Ubuntu)

```bash
sudo apt-get install libopencv-dev
```

### Android

[OpenCV Android SDK](https://opencv.org/releases/) 다운로드 후 `android/CMakeLists.txt`에서 경로 설정.

**필수 권한 설정 (`android/app/src/main/AndroidManifest.xml`):**

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

**자세한 내용:** [ANDROID_BUILD.md](ANDROID_BUILD.md) 참조

### iOS & macOS

iOS: `opencv2.framework` 필요  
macOS: `brew install opencv`

### Windows

`windows/CMakeLists.txt`에 OpenCV 경로 설정.

```cmake
set(OpenCV_DIR "C:/opencv/build")
find_package(OpenCV REQUIRED)
```
