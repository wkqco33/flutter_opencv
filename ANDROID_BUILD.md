# Android 빌드 및 실행 가이드

## 📋 사전 요구사항

### 1. OpenCV Android SDK 설치

안드로이드에서 OpenCV를 사용하려면 OpenCV Android SDK가 필요합니다.

#### 다운로드

1. [OpenCV Releases](https://opencv.org/releases/) 페이지 방문
2. 최신 안드로이드 SDK 다운로드 (예: opencv-4.x.x-android-sdk.zip)
3. 압축 해제

#### 설정 방법

##### **방법 1: CMake에서 직접 경로 지정**

`android/build.gradle`에서 OpenCV 경로 설정:

```gradle
android {
    // ... 기존 설정 ...

    defaultConfig {
        // ... 기존 설정 ...

        externalNativeBuild {
            cmake {
                arguments "-DOpenCV_DIR=/path/to/opencv-android-sdk/sdk/native/jni"
            }
        }
    }
}
```

##### **방법 2: 환경 변수 설정**

```bash
# ~/.bashrc 또는 ~/.zshrc에 추가
export OPENCV_ANDROID_SDK=/path/to/opencv-android-sdk
```

### 2. Android NDK 설치

Flutter는 자동으로 적절한 NDK를 다운로드하지만, 수동 설치도 가능합니다:

```bash
# Android Studio의 SDK Manager에서 설치
# 또는 명령줄로:
sdkmanager --install "ndk;25.1.8937393"
```

### 3. 필요한 권한 확인

`android/app/src/main/AndroidManifest.xml`에 다음 권한이 있는지 확인:

```xml
<!-- 카메라 권한 (필수) -->
<uses-permission android:name="android.permission.CAMERA" />

<!-- 저장소 읽기 권한 (갤러리용) -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />

<!-- Android 13+ 미디어 권한 -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

## 🔨 빌드 방법

### 1. 의존성 설치

```bash
cd example
flutter pub get
```

### 2. Android 빌드

```bash
# Debug 모드
flutter build apk --debug

# Release 모드
flutter build apk --release

# App Bundle (Google Play 배포용)
flutter build appbundle --release
```

### 3. 실행

```bash
# 연결된 기기나 에뮬레이터에서 실행
flutter run -d android

# 특정 기기 지정
flutter devices  # 연결된 기기 목록 확인
flutter run -d <device-id>
```

## 🐛 문제 해결

### OpenCV 라이브러리를 찾을 수 없음

**증상:**

```text
CMake Error: Could not find OpenCV
```

**해결:**

1. OpenCV Android SDK가 올바르게 다운로드되었는지 확인
2. CMakeLists.txt에서 경로가 올바른지 확인
3. 환경 변수가 설정되었는지 확인

### 카메라가 작동하지 않음

**증상:**

- 카메라 권한 에러
- 검은 화면

**해결:**

1. AndroidManifest.xml에 카메라 권한 추가 확인
2. 기기 설정에서 앱 권한 확인
3. 에뮬레이터의 경우 가상 카메라 설정 확인

### 빌드 시간이 너무 오래 걸림

**해결:**

```gradle
// android/app/build.gradle.kts
android {
    defaultConfig {
        ndk {
            // 필요한 ABI만 빌드 (개발 중)
            abiFilters += listOf("arm64-v8a")
        }
    }
}
```

릴리스 빌드 시에는 모든 ABI 포함:

```gradle
android {
    buildTypes {
        release {
            ndk {
                abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86", "x86_64")
            }
        }
    }
}
```

### 64KB DEX 제한 초과

**증상:**

```text
The number of method references in a .dex file cannot exceed 64K
```

**해결:**

```gradle
// android/app/build.gradle.kts
android {
    defaultConfig {
        multiDexEnabled = true
    }
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
```

## ⚙️ 최적화 팁

### 1. ProGuard 설정 (Release 빌드)

`android/app/proguard-rules.pro`:

```proguard
# OpenCV 최적화 제외
-keep class org.opencv.** { *; }
```

### 2. 빌드 크기 줄이기

```gradle
android {
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
        }
    }

    splits {
        abi {
            enable true
            reset()
            include 'armeabi-v7a', 'arm64-v8a'
            universalApk false
        }
    }
}
```

### 3. 성능 최적화

- Release 모드에서 실행: `flutter run --release`
- 프로파일 모드에서 테스트: `flutter run --profile`
- 카메라 해상도 조정: 640x480 권장 (예제 기본값)

## 📱 테스트 환경

### 권장 사양

- Android 7.0 (API 24) 이상
- RAM 2GB 이상
- 카메라 지원 기기

### 에뮬레이터 설정

1. Android Studio > AVD Manager
2. Create Virtual Device
3. Pixel 5 (API 30 이상) 선택
4. Hardware 탭에서 Camera 활성화

## 🔐 보안 고려사항

### 권한 최소화

- 사용하지 않는 권한은 AndroidManifest.xml에서 제거
- 런타임에 권한 요청 시 명확한 설명 제공

### 데이터 보호

- 카메라로 촬영한 이미지는 메모리에서만 처리
- 파일 저장 시 적절한 권한 확인
- 민감한 데이터는 암호화 저장

## 📚 참고 자료

- [Flutter Android 문서](https://docs.flutter.dev/deployment/android)
- [OpenCV Android 문서](https://docs.opencv.org/master/d5/df8/tutorial_dev_with_OCV_on_Android.html)
- [Android 권한 가이드](https://developer.android.com/guide/topics/permissions/overview)
