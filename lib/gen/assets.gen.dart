// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsAudioGen {
  const $AssetsAudioGen();

  /// File path: assets/audio/bird_background_sound.mp3
  String get birdBackgroundSound => 'assets/audio/bird_background_sound.mp3';

  /// File path: assets/audio/bug_tap.wav
  String get bugTap => 'assets/audio/bug_tap.wav';

  /// File path: assets/audio/mice_tap.mp3
  String get miceTap => 'assets/audio/mice_tap.mp3';

  /// List of all assets
  List<String> get values => [birdBackgroundSound, bugTap, miceTap];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/back_button.png
  AssetGenImage get backButton =>
      const AssetGenImage('assets/images/back_button.png');

  /// File path: assets/images/background.webp
  AssetGenImage get background =>
      const AssetGenImage('assets/images/background.webp');

  /// File path: assets/images/bug_sprite.png
  AssetGenImage get bugSprite =>
      const AssetGenImage('assets/images/bug_sprite.png');

  /// File path: assets/images/mainscreenbg.png
  AssetGenImage get mainscreenbg =>
      const AssetGenImage('assets/images/mainscreenbg.png');

  /// File path: assets/images/mice_sprite.png
  AssetGenImage get miceSprite =>
      const AssetGenImage('assets/images/mice_sprite.png');

  /// File path: assets/images/splashscreen.png
  AssetGenImage get splashscreen =>
      const AssetGenImage('assets/images/splashscreen.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    backButton,
    background,
    bugSprite,
    mainscreenbg,
    miceSprite,
    splashscreen,
  ];
}

class Assets {
  const Assets._();

  static const $AssetsAudioGen audio = $AssetsAudioGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
