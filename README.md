# Flutter OpenCV FFI Plugin

Dart FFI를 통해 OpenCV C++ 라이브러리를 Flutter에서 사용하는 플러그인입니다.

## 주요 기능

### 이미지 처리 (`CvImage`)

- 파일/바이트 배열에서 이미지 로드
- Grayscale 변환
- Gaussian Blur 필터
- Canny Edge Detection
- 이미지 리사이즈
- 회전 (90도 단위)

### 그리기

- 사각형, 원, 선 그리기

### 비디오 캡처 (`CvVideoCapture`)

- 웹캠 접근
- 실시간 프레임 캡처
- 해상도 설정

## 설치

### 필수 요구사항

OpenCV 라이브러리 설치 필요.

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
```

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
