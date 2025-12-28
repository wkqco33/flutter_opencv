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

  /// BGR to RGB 변환
  CvImage toRgb() {
    final ptr = bindings.cv_cvtColor_bgr2rgb(_ptr);
    if (ptr == ffi.nullptr) {
      throw Exception('Failed to convert to RGB');
    }
    return CvImage._(ptr, _dylib);
  }

  /// BGR to HSV 변환
  CvImage toHsv() {
    final ptr = bindings.cv_cvtColor_bgr2hsv(_ptr);
    if (ptr == ffi.nullptr) {
      throw Exception('Failed to convert to HSV');
    }
    return CvImage._(ptr, _dylib);
  }

  /// HSV to BGR 변환
  CvImage hsvToBgr() {
    final ptr = bindings.cv_cvtColor_hsv2bgr(_ptr);
    if (ptr == ffi.nullptr) {
      throw Exception('Failed to convert HSV to BGR');
    }
    return CvImage._(ptr, _dylib);
  }

  /// BGR to LAB 변환
  CvImage toLab() {
    final ptr = bindings.cv_cvtColor_bgr2lab(_ptr);
    if (ptr == ffi.nullptr) {
      throw Exception('Failed to convert to LAB');
    }
    return CvImage._(ptr, _dylib);
  }

  /// LAB to BGR 변환
  CvImage labToBgr() {
    final ptr = bindings.cv_cvtColor_lab2bgr(_ptr);
    if (ptr == ffi.nullptr) {
      throw Exception('Failed to convert LAB to BGR');
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

  /// Applies Median Blur to the image.
  ///
  /// [kernelSize] must be odd. Good for removing salt-and-pepper noise.
  CvImage medianBlur(int kernelSize) {
    if (kernelSize % 2 == 0) {
      kernelSize++;
    }
    final ptr = bindings.cv_median_blur(_ptr, kernelSize);
    if (ptr == ffi.nullptr) {
      throw Exception('Failed to apply median blur');
    }
    return CvImage._(ptr, _dylib);
  }

  /// Applies Bilateral Filter to the image.
  ///
  /// Reduces noise while keeping edges sharp.
  /// [d] - diameter of pixel neighborhood
  /// [sigmaColor] - filter sigma in the color space
  /// [sigmaSpace] - filter sigma in the coordinate space
  CvImage bilateralFilter(int d, double sigmaColor, double sigmaSpace) {
    final ptr = bindings.cv_bilateral_filter(_ptr, d, sigmaColor, sigmaSpace);
    if (ptr == ffi.nullptr) {
      throw Exception('Failed to apply bilateral filter');
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

  /// Applies Sobel edge detection.
  ///
  /// [dx] - order of the derivative x
  /// [dy] - order of the derivative y
  /// [ksize] - size of the extended Sobel kernel (1, 3, 5, or 7)
  CvImage sobel(int dx, int dy, {int ksize = 3}) {
    final ptr = bindings.cv_sobel(_ptr, dx, dy, ksize);
    if (ptr == ffi.nullptr) {
      throw Exception('Failed to apply Sobel');
    }
    return CvImage._(ptr, _dylib);
  }

  /// Applies Laplacian edge detection.
  CvImage laplacian({int ksize = 1}) {
    final ptr = bindings.cv_laplacian(_ptr, ksize);
    if (ptr == ffi.nullptr) {
      throw Exception('Failed to apply Laplacian');
    }
    return CvImage._(ptr, _dylib);
  }

  /// Sharpens the image using a sharpening kernel.
  CvImage sharpen() {
    final ptr = bindings.cv_sharpen(_ptr);
    if (ptr == ffi.nullptr) {
      throw Exception('Failed to sharpen image');
    }
    return CvImage._(ptr, _dylib);
  }

  // --- Morphological Operations ---

  /// Erodes the image (makes objects thinner).
  CvImage erode(int kernelSize, {int iterations = 1}) {
    final ptr = bindings.cv_erode(_ptr, kernelSize, iterations);
    if (ptr == ffi.nullptr) {
      throw Exception('Failed to erode image');
    }
    return CvImage._(ptr, _dylib);
  }

  /// Dilates the image (makes objects thicker).
  CvImage dilate(int kernelSize, {int iterations = 1}) {
    final ptr = bindings.cv_dilate(_ptr, kernelSize, iterations);
    if (ptr == ffi.nullptr) {
      throw Exception('Failed to dilate image');
    }
    return CvImage._(ptr, _dylib);
  }

  /// Applies morphological operation.
  ///
  /// [op] - morphology operation type:
  /// - 0: MORPH_ERODE
  /// - 1: MORPH_DILATE
  /// - 2: MORPH_OPEN (erosion followed by dilation)
  /// - 3: MORPH_CLOSE (dilation followed by erosion)
  /// - 4: MORPH_GRADIENT (difference between dilation and erosion)
  /// - 5: MORPH_TOPHAT (difference between input and opening)
  /// - 6: MORPH_BLACKHAT (difference between closing and input)
  CvImage morphologyEx(int op, int kernelSize) {
    final ptr = bindings.cv_morphology_ex(_ptr, op, kernelSize);
    if (ptr == ffi.nullptr) {
      throw Exception('Failed to apply morphology');
    }
    return CvImage._(ptr, _dylib);
  }

  // --- Thresholding ---

  /// Applies fixed-level threshold.
  ///
  /// [type] - threshold type:
  /// - 0: THRESH_BINARY
  /// - 1: THRESH_BINARY_INV
  /// - 2: THRESH_TRUNC
  /// - 3: THRESH_TOZERO
  /// - 4: THRESH_TOZERO_INV
  CvImage threshold(double thresh, double maxval, {int type = 0}) {
    final ptr = bindings.cv_threshold(_ptr, thresh, maxval, type);
    if (ptr == ffi.nullptr) {
      throw Exception('Failed to apply threshold');
    }
    return CvImage._(ptr, _dylib);
  }

  /// Applies adaptive threshold.
  ///
  /// [adaptiveMethod] - 0: ADAPTIVE_THRESH_MEAN_C, 1: ADAPTIVE_THRESH_GAUSSIAN_C
  /// [thresholdType] - 0: THRESH_BINARY, 1: THRESH_BINARY_INV
  CvImage adaptiveThreshold(
    double maxValue,
    int adaptiveMethod,
    int thresholdType,
    int blockSize,
    double c,
  ) {
    final ptr = bindings.cv_adaptive_threshold(
      _ptr,
      maxValue,
      adaptiveMethod,
      thresholdType,
      blockSize,
      c,
    );
    if (ptr == ffi.nullptr) {
      throw Exception('Failed to apply adaptive threshold');
    }
    return CvImage._(ptr, _dylib);
  }

  // --- Histogram ---

  /// Equalizes the histogram of a grayscale or color image.
  CvImage equalizeHist() {
    final ptr = bindings.cv_equalize_hist(_ptr);
    if (ptr == ffi.nullptr) {
      throw Exception('Failed to equalize histogram');
    }
    return CvImage._(ptr, _dylib);
  }

  // --- Denoising ---

  /// Removes noise from grayscale image using Non-local Means Denoising.
  ///
  /// [h] - filter strength (higher value removes more noise but removes details too)
  CvImage fastNlMeansDenoising({
    double h = 10,
    int templateWindowSize = 7,
    int searchWindowSize = 21,
  }) {
    final ptr = bindings.cv_fast_nl_means_denoising(
      _ptr,
      h,
      templateWindowSize,
      searchWindowSize,
    );
    if (ptr == ffi.nullptr) {
      throw Exception('Failed to denoise image');
    }
    return CvImage._(ptr, _dylib);
  }

  /// Removes noise from color image using Non-local Means Denoising.
  CvImage fastNlMeansDenoisingColored({
    double h = 10,
    double hColor = 10,
    int templateWindowSize = 7,
    int searchWindowSize = 21,
  }) {
    final ptr = bindings.cv_fast_nl_means_denoising_colored(
      _ptr,
      h,
      hColor,
      templateWindowSize,
      searchWindowSize,
    );
    if (ptr == ffi.nullptr) {
      throw Exception('Failed to denoise colored image');
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
