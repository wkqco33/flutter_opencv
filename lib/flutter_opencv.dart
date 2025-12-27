import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

import 'flutter_opencv_bindings_generated.dart';

export 'src/cv_image.dart';
export 'src/cv_video_capture.dart';

const String _libName = 'flutter_opencv';

/// 네이티브 라이브러리
final DynamicLibrary dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// FFI 바인딩
final FlutterOpencvBindings bindings = FlutterOpencvBindings(dylib);

/// OpenCV 버전
String opencvVersion() {
  return bindings.opencv_version().cast<Utf8>().toDartString();
}
