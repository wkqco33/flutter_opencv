import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'logger.dart';

/// 권한 관리 서비스
///
/// Android/iOS에서 필요한 런타임 권한을 요청하고 관리합니다.
class PermissionService {
  static const String _tag = 'Permission';

  /// 카메라 권한 확인 및 요청
  ///
  /// Returns: 권한이 허용되면 true, 거부되면 false
  ///
  /// Android: 카메라 권한 필요
  /// iOS: Info.plist에 NSCameraUsageDescription 추가 필요
  static Future<bool> requestCameraPermission() async {
    try {
      // Android가 아니면 권한 검사 통과
      if (!Platform.isAndroid) {
        return true;
      }

      AppLogger.info('카메라 권한 확인 중...', tag: _tag);

      // 현재 권한 상태 확인
      var status = await Permission.camera.status;

      if (status.isGranted) {
        AppLogger.success('카메라 권한 이미 허용됨', tag: _tag);
        return true;
      }

      // 권한 요청
      AppLogger.info('카메라 권한 요청', tag: _tag);
      status = await Permission.camera.request();

      if (status.isGranted) {
        AppLogger.success('카메라 권한 허용됨', tag: _tag);
        return true;
      } else if (status.isDenied) {
        AppLogger.warning('카메라 권한 거부됨', tag: _tag);
        return false;
      } else if (status.isPermanentlyDenied) {
        AppLogger.warning('카메라 권한 영구 거부됨 - 설정에서 변경 필요', tag: _tag);
        return false;
      }

      return false;
    } catch (e, stackTrace) {
      AppLogger.error(
        '카메라 권한 확인 중 에러 발생',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
      return false;
    }
  }

  /// 저장소 권한 확인 및 요청
  ///
  /// Returns: 권한이 허용되면 true, 거부되면 false
  ///
  /// Android 13+ (API 33+): READ_MEDIA_IMAGES 권한 사용
  /// Android 6-12 (API 23-32): READ_EXTERNAL_STORAGE 권한 사용
  /// iOS: Info.plist에 NSPhotoLibraryUsageDescription 추가 필요
  static Future<bool> requestStoragePermission() async {
    try {
      // Android가 아니면 권한 검사 통과
      if (!Platform.isAndroid) {
        return true;
      }

      AppLogger.info('저장소 권한 확인 중...', tag: _tag);

      // Android 13 이상에서는 photos 권한 사용
      Permission permission = Permission.photos;

      // 현재 권한 상태 확인
      var status = await permission.status;

      if (status.isGranted || status.isLimited) {
        AppLogger.success('저장소 권한 이미 허용됨', tag: _tag);
        return true;
      }

      // 권한 요청
      AppLogger.info('저장소 권한 요청', tag: _tag);
      status = await permission.request();

      if (status.isGranted || status.isLimited) {
        AppLogger.success('저장소 권한 허용됨', tag: _tag);
        return true;
      } else if (status.isDenied) {
        AppLogger.warning('저장소 권한 거부됨', tag: _tag);
        return false;
      } else if (status.isPermanentlyDenied) {
        AppLogger.warning('저장소 권한 영구 거부됨 - 설정에서 변경 필요', tag: _tag);
        return false;
      }

      return false;
    } catch (e, stackTrace) {
      AppLogger.error(
        '저장소 권한 확인 중 에러 발생',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
      return false;
    }
  }

  /// 앱 설정 화면 열기
  ///
  /// 권한이 영구 거부된 경우 사용자를 설정 화면으로 안내합니다.
  static Future<bool> goToAppSettings() async {
    try {
      AppLogger.info('앱 설정 화면 열기', tag: _tag);
      return await openAppSettings();
    } catch (e, stackTrace) {
      AppLogger.error(
        '앱 설정 화면 열기 실패',
        error: e,
        stackTrace: stackTrace,
        tag: _tag,
      );
      return false;
    }
  }

  /// 모든 필요한 권한 확인
  ///
  /// 카메라와 저장소 권한 모두 확인하여 상태를 반환합니다.
  static Future<Map<String, bool>> checkAllPermissions() async {
    AppLogger.info('모든 권한 상태 확인', tag: _tag);

    final cameraStatus = await Permission.camera.status;
    final photosStatus = await Permission.photos.status;

    final result = {
      'camera': cameraStatus.isGranted,
      'storage': photosStatus.isGranted || photosStatus.isLimited,
    };

    AppLogger.info('권한 상태: $result', tag: _tag);
    return result;
  }
}
