import 'dart:ffi' as ffi;
import 'package:flutter_opencv/flutter_opencv.dart';
import 'package:flutter_opencv/flutter_opencv_bindings_generated.dart' as gen;

/// OpenCV VideoCapture 래퍼
class CvVideoCapture implements ffi.Finalizable {
  /// C++ cv::VideoCapture 포인터
  final ffi.Pointer<gen.CvVideoCapture> _ptr;

  /// 라이브러리 참조
  // ignore: unused_field
  final ffi.DynamicLibrary _dylib;

  /// 메모리 자동 해제
  static final ffi.NativeFinalizer _finalizer = ffi.NativeFinalizer(
    bindings.addresses.cv_videocapture_release
        .cast<ffi.NativeFinalizerFunction>(),
  );

  CvVideoCapture._(this._ptr, this._dylib) {
    _finalizer.attach(this, _ptr.cast(), detach: this);
  }

  /// 카메라 연결 (index: 카메라 인덱스, 보통 0)
  static CvVideoCapture? connect(int index) {
    final ptr = bindings.cv_videocapture_create(index);
    if (ptr == ffi.nullptr) {
      return null;
    }
    return CvVideoCapture._(ptr, dylib);
  }

  /// 프레임 읽기
  CvImage? read() {
    final matPtr = bindings.cv_mat_create();
    if (matPtr == ffi.nullptr) return null;

    final int result = bindings.cv_videocapture_read(_ptr, matPtr);

    if (result == 0) {
      bindings.cv_mat_release(matPtr);
      return null;
    }

    return CvImage.wrap(matPtr);
  }

  /// 속성 가져오기
  double get(int propId) {
    return bindings.cv_videocapture_get(_ptr, propId);
  }

  /// 속성 설정
  void set(int propId, double value) {
    bindings.cv_videocapture_set(_ptr, propId, value);
  }

  /// 메모리 수동 해제
  void dispose() {
    _finalizer.detach(this);
    bindings.cv_videocapture_release(_ptr);
  }
}
