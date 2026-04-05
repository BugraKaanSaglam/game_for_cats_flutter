import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

//* Memoized package-info loader used by About/build surfaces.
class AppInfoService {
  AppInfoService._();

  static final AppInfoService instance = AppInfoService._();

  Future<PackageInfo>? _infoFuture;
  Future<PackageInfo> Function() _loader = PackageInfo.fromPlatform;

  //! PackageInfo.fromPlatform is relatively expensive and static for a session, so we cache the future.
  Future<PackageInfo> load() {
    return _infoFuture ??= _loader();
  }

  @visibleForTesting
  void overrideLoader(Future<PackageInfo> Function() loader) {
    _loader = loader;
    _infoFuture = null;
  }

  @visibleForTesting
  void reset() {
    _loader = PackageInfo.fromPlatform;
    _infoFuture = null;
  }
}
