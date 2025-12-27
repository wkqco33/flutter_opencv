import 'package:flutter/foundation.dart';

/// 앱 전역 로깅 유틸리티
/// 
/// 디버그 로그, 정보 로그, 경고, 에러를 일관된 형식으로 출력합니다.
/// Release 모드에서는 디버그 로그가 자동으로 비활성화됩니다.
class AppLogger {
  static const String _prefix = '[OpenCV Demo]';
  
  /// 디버그 레벨 로그 출력
  /// 
  /// [message]: 로그 메시지
  /// [tag]: 로그 태그 (선택사항)
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_prefix$tagStr 🔍 $message');
    }
  }
  
  /// 정보 레벨 로그 출력
  /// 
  /// [message]: 로그 메시지
  /// [tag]: 로그 태그 (선택사항)
  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_prefix$tagStr ℹ️ $message');
    }
  }
  
  /// 경고 레벨 로그 출력
  /// 
  /// [message]: 경고 메시지
  /// [tag]: 로그 태그 (선택사항)
  static void warning(String message, {String? tag}) {
    final tagStr = tag != null ? '[$tag]' : '';
    debugPrint('$_prefix$tagStr ⚠️ $message');
  }
  
  /// 에러 레벨 로그 출력
  /// 
  /// [message]: 에러 메시지
  /// [error]: 에러 객체 (선택사항)
  /// [stackTrace]: 스택 트레이스 (선택사항)
  /// [tag]: 로그 태그 (선택사항)
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  }) {
    final tagStr = tag != null ? '[$tag]' : '';
    debugPrint('$_prefix$tagStr ❌ $message');
    
    if (error != null) {
      debugPrint('$_prefix$tagStr Error: $error');
    }
    
    if (stackTrace != null && kDebugMode) {
      debugPrint('$_prefix$tagStr StackTrace:\n$stackTrace');
    }
  }
  
  /// 성공 메시지 로그 출력
  /// 
  /// [message]: 성공 메시지
  /// [tag]: 로그 태그 (선택사항)
  static void success(String message, {String? tag}) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_prefix$tagStr ✅ $message');
    }
  }
}
