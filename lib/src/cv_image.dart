import 'dart:ffi' as ffi;
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:flutter_opencv/flutter_opencv.dart';
import 'package:flutter_opencv/flutter_opencv_bindings_generated.dart';

/// OpenCV Mat 객체 래퍼
class CvImage implements ffi.Finalizable {
  /// C++ cv::Mat 포인터
  final ffi.Pointer<CvMat> _ptr;

  /// 라이브러리 참조
  // ignore: unused_field
  final ffi.DynamicLibrary _dylib;

  /// 메모리 자동 해제
  static final ffi.NativeFinalizer _finalizer = ffi.NativeFinalizer(
    bindings.addresses.cv_mat_release.cast<ffi.NativeFinalizerFunction>(),
  );

  CvImage._(this._ptr, this._dylib) {
    _finalizer.attach(this, _ptr.cast(), detach: this);
  }

  /// 포인터 래핑
  factory CvImage.wrap(ffi.Pointer<CvMat> ptr) {
    return CvImage._(ptr, dylib);
  }

  /// 파일에서 로드
  static CvImage? fromFile(String path) {
    final pathC = path.toNativeUtf8();
    try {
      final ptr = bindings.cv_imread(pathC.cast());
      if (ptr == ffi.nullptr) {
        return null;
      }
      return CvImage._(ptr, dylib);
    } finally {
      malloc.free(pathC);
    }
  }

  /// 바이트에서 로드
  static CvImage? fromBytes(List<int> bytes) {
    final ffi.Pointer<ffi.Uint8> dataC = malloc.allocate<ffi.Uint8>(
      bytes.length,
    );
    final Uint8List nativeBytes = dataC.asTypedList(bytes.length);
    nativeBytes.setAll(0, bytes);

    try {
      final ptr = bindings.cv_imdecode(dataC, bytes.length);
      if (ptr == ffi.nullptr) {
        return null;
      }
      return CvImage._(ptr, dylib);
    } finally {
      malloc.free(dataC);
    }
  }

  /// Grayscale 변환
  CvImage toGrayscale() {
    final ptr = bindings.cv_cvtColor_bgr2gray(_ptr);
    if (ptr == ffi.nullptr) {
      throw Exception('Failed to convert to grayscale');
    }
    return CvImage._(ptr, _dylib);
  }

  /// 리사이즈
  CvImage resize(int width, int height, {int interpolation = 1}) {
    final ptr = bindings.cv_resize(_ptr, width, height, interpolation);
    if (ptr == ffi.nullptr) {
      throw Exception('Failed to resize image');
    }
    return CvImage._(ptr, _dylib);
  }

  /// 뒤집기 (0: x축, 1: y축, -1: 양축)
  CvImage flip(int mode) {
    final ptr = bindings.cv_flip(_ptr, mode);
    if (ptr == ffi.nullptr) {
      throw Exception('Failed to flip image');
    }
    return CvImage._(ptr, _dylib);
  }

  /// 회전 (0: 90도 시계방향, 1: 180도, 2: 90도 반시계)
  CvImage rotate(int code) {
    final ptr = bindings.cv_rotate(_ptr, code);
    if (ptr == ffi.nullptr) {
      throw Exception('Failed to rotate image');
    }
    return CvImage._(ptr, _dylib);
  }

  /// Applies Gaussian Blur to the image.
  ///
  /// [kernelSize] must be odd. [sigma] is standard deviation.
  CvImage gaussianBlur(int kernelSize, double sigma) {
    if (kernelSize % 2 == 0) {
      kernelSize++;
    }
    final ptr = bindings.cv_gaussian_blur(_ptr, kernelSize, sigma);
    if (ptr == ffi.nullptr) {
      throw Exception('Failed to apply gaussian blur');
    }
    return CvImage._(ptr, _dylib);
  }

  /// Applies Canny Edge Detection.
  CvImage canny(double threshold1, double threshold2) {
    final ptr = bindings.cv_canny(_ptr, threshold1, threshold2);
    if (ptr == ffi.nullptr) {
      throw Exception('Failed to apply Canny edge detection');
    }
    return CvImage._(ptr, _dylib);
  }

  // --- In-place Drawing Functions ---

  /// Draws a rectangle on this image.
  ///
  /// [r], [g], [b] define the color (0-255). [thickness] defines line width.
  void drawRectangle(
    int x,
    int y,
    int width,
    int height,
    int r,
    int g,
    int b,
    int thickness,
  ) {
    bindings.cv_rectangle(_ptr, x, y, width, height, r, g, b, thickness);
  }

  /// Draws a circle on this image.
  void drawCircle(
    int centerX,
    int centerY,
    int radius,
    int r,
    int g,
    int b,
    int thickness,
  ) {
    bindings.cv_circle(_ptr, centerX, centerY, radius, r, g, b, thickness);
  }

  /// Draws a line on this image.
  void drawLine(
    int x1,
    int y1,
    int x2,
    int y2,
    int r,
    int g,
    int b,
    int thickness,
  ) {
    bindings.cv_line(_ptr, x1, y1, x2, y2, r, g, b, thickness);
  }

  /// Manually releases the native memory.
  ///
  /// Use this if you need deterministic memory release.
  /// After calling this, the object should not be used.
  void dispose() {
    _finalizer.detach(this);
    bindings.cv_mat_release(_ptr);
  }

  int get width => bindings.cv_mat_width(_ptr);
  int get height => bindings.cv_mat_height(_ptr);
  int get channels => bindings.cv_mat_channels(_ptr);

  /// Encodes the image to bytes with the specified extension (e.g., ".png", ".jpg").
  List<int> encode({String ext = ".png"}) {
    final extC = ext.toNativeUtf8();
    try {
      final result = bindings.cv_imencode(extC.cast(), _ptr);
      if (result.data == ffi.nullptr) {
        return [];
      }
      final List<int> dartBytes = result.data.asTypedList(result.len).toList();
      bindings.cv_free_bytes(result);
      return dartBytes;
    } finally {
      malloc.free(extC);
    }
  }
}
