import 'package:package_info_plus/package_info_plus.dart';

class AppInfoService {
  AppInfoService._();

  static final AppInfoService instance = AppInfoService._();

  Future<PackageInfo>? _infoFuture;

  Future<PackageInfo> load() {
    return _infoFuture ??= PackageInfo.fromPlatform();
  }
}
