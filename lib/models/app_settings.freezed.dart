// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppSettings {

 int get version; int get languageCode; double get musicVolume; double get characterVolume; int get time; int get difficulty; String get backgroundPath; bool get muted; bool get lowPower; bool get reducedMotion; bool get highContrast; bool get largerTargets; bool get haptics;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.version, version) || other.version == version)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.musicVolume, musicVolume) || other.musicVolume == musicVolume)&&(identical(other.characterVolume, characterVolume) || other.characterVolume == characterVolume)&&(identical(other.time, time) || other.time == time)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.backgroundPath, backgroundPath) || other.backgroundPath == backgroundPath)&&(identical(other.muted, muted) || other.muted == muted)&&(identical(other.lowPower, lowPower) || other.lowPower == lowPower)&&(identical(other.reducedMotion, reducedMotion) || other.reducedMotion == reducedMotion)&&(identical(other.highContrast, highContrast) || other.highContrast == highContrast)&&(identical(other.largerTargets, largerTargets) || other.largerTargets == largerTargets)&&(identical(other.haptics, haptics) || other.haptics == haptics));
}


@override
int get hashCode => Object.hash(runtimeType,version,languageCode,musicVolume,characterVolume,time,difficulty,backgroundPath,muted,lowPower,reducedMotion,highContrast,largerTargets,haptics);

@override
String toString() {
  return 'AppSettings(version: $version, languageCode: $languageCode, musicVolume: $musicVolume, characterVolume: $characterVolume, time: $time, difficulty: $difficulty, backgroundPath: $backgroundPath, muted: $muted, lowPower: $lowPower, reducedMotion: $reducedMotion, highContrast: $highContrast, largerTargets: $largerTargets, haptics: $haptics)';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
 int version, int languageCode, double musicVolume, double characterVolume, int time, int difficulty, String backgroundPath, bool muted, bool lowPower, bool reducedMotion, bool highContrast, bool largerTargets, bool haptics
});




}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? languageCode = null,Object? musicVolume = null,Object? characterVolume = null,Object? time = null,Object? difficulty = null,Object? backgroundPath = null,Object? muted = null,Object? lowPower = null,Object? reducedMotion = null,Object? highContrast = null,Object? largerTargets = null,Object? haptics = null,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as int,musicVolume: null == musicVolume ? _self.musicVolume : musicVolume // ignore: cast_nullable_to_non_nullable
as double,characterVolume: null == characterVolume ? _self.characterVolume : characterVolume // ignore: cast_nullable_to_non_nullable
as double,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as int,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as int,backgroundPath: null == backgroundPath ? _self.backgroundPath : backgroundPath // ignore: cast_nullable_to_non_nullable
as String,muted: null == muted ? _self.muted : muted // ignore: cast_nullable_to_non_nullable
as bool,lowPower: null == lowPower ? _self.lowPower : lowPower // ignore: cast_nullable_to_non_nullable
as bool,reducedMotion: null == reducedMotion ? _self.reducedMotion : reducedMotion // ignore: cast_nullable_to_non_nullable
as bool,highContrast: null == highContrast ? _self.highContrast : highContrast // ignore: cast_nullable_to_non_nullable
as bool,largerTargets: null == largerTargets ? _self.largerTargets : largerTargets // ignore: cast_nullable_to_non_nullable
as bool,haptics: null == haptics ? _self.haptics : haptics // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettings value)  $default,){
final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int version,  int languageCode,  double musicVolume,  double characterVolume,  int time,  int difficulty,  String backgroundPath,  bool muted,  bool lowPower,  bool reducedMotion,  bool highContrast,  bool largerTargets,  bool haptics)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.version,_that.languageCode,_that.musicVolume,_that.characterVolume,_that.time,_that.difficulty,_that.backgroundPath,_that.muted,_that.lowPower,_that.reducedMotion,_that.highContrast,_that.largerTargets,_that.haptics);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int version,  int languageCode,  double musicVolume,  double characterVolume,  int time,  int difficulty,  String backgroundPath,  bool muted,  bool lowPower,  bool reducedMotion,  bool highContrast,  bool largerTargets,  bool haptics)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.version,_that.languageCode,_that.musicVolume,_that.characterVolume,_that.time,_that.difficulty,_that.backgroundPath,_that.muted,_that.lowPower,_that.reducedMotion,_that.highContrast,_that.largerTargets,_that.haptics);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int version,  int languageCode,  double musicVolume,  double characterVolume,  int time,  int difficulty,  String backgroundPath,  bool muted,  bool lowPower,  bool reducedMotion,  bool highContrast,  bool largerTargets,  bool haptics)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.version,_that.languageCode,_that.musicVolume,_that.characterVolume,_that.time,_that.difficulty,_that.backgroundPath,_that.muted,_that.lowPower,_that.reducedMotion,_that.highContrast,_that.largerTargets,_that.haptics);case _:
  return null;

}
}

}

/// @nodoc


class _AppSettings extends AppSettings {
  const _AppSettings({required this.version, required this.languageCode, required this.musicVolume, required this.characterVolume, required this.time, required this.difficulty, required this.backgroundPath, required this.muted, required this.lowPower, this.reducedMotion = false, this.highContrast = false, this.largerTargets = false, this.haptics = false}): super._();


@override final  int version;
@override final  int languageCode;
@override final  double musicVolume;
@override final  double characterVolume;
@override final  int time;
@override final  int difficulty;
@override final  String backgroundPath;
@override final  bool muted;
@override final  bool lowPower;
@override@JsonKey() final  bool reducedMotion;
@override@JsonKey() final  bool highContrast;
@override@JsonKey() final  bool largerTargets;
@override@JsonKey() final  bool haptics;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.version, version) || other.version == version)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.musicVolume, musicVolume) || other.musicVolume == musicVolume)&&(identical(other.characterVolume, characterVolume) || other.characterVolume == characterVolume)&&(identical(other.time, time) || other.time == time)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.backgroundPath, backgroundPath) || other.backgroundPath == backgroundPath)&&(identical(other.muted, muted) || other.muted == muted)&&(identical(other.lowPower, lowPower) || other.lowPower == lowPower)&&(identical(other.reducedMotion, reducedMotion) || other.reducedMotion == reducedMotion)&&(identical(other.highContrast, highContrast) || other.highContrast == highContrast)&&(identical(other.largerTargets, largerTargets) || other.largerTargets == largerTargets)&&(identical(other.haptics, haptics) || other.haptics == haptics));
}


@override
int get hashCode => Object.hash(runtimeType,version,languageCode,musicVolume,characterVolume,time,difficulty,backgroundPath,muted,lowPower,reducedMotion,highContrast,largerTargets,haptics);

@override
String toString() {
  return 'AppSettings(version: $version, languageCode: $languageCode, musicVolume: $musicVolume, characterVolume: $characterVolume, time: $time, difficulty: $difficulty, backgroundPath: $backgroundPath, muted: $muted, lowPower: $lowPower, reducedMotion: $reducedMotion, highContrast: $highContrast, largerTargets: $largerTargets, haptics: $haptics)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
 int version, int languageCode, double musicVolume, double characterVolume, int time, int difficulty, String backgroundPath, bool muted, bool lowPower, bool reducedMotion, bool highContrast, bool largerTargets, bool haptics
});




}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? languageCode = null,Object? musicVolume = null,Object? characterVolume = null,Object? time = null,Object? difficulty = null,Object? backgroundPath = null,Object? muted = null,Object? lowPower = null,Object? reducedMotion = null,Object? highContrast = null,Object? largerTargets = null,Object? haptics = null,}) {
  return _then(_AppSettings(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as int,musicVolume: null == musicVolume ? _self.musicVolume : musicVolume // ignore: cast_nullable_to_non_nullable
as double,characterVolume: null == characterVolume ? _self.characterVolume : characterVolume // ignore: cast_nullable_to_non_nullable
as double,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as int,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as int,backgroundPath: null == backgroundPath ? _self.backgroundPath : backgroundPath // ignore: cast_nullable_to_non_nullable
as String,muted: null == muted ? _self.muted : muted // ignore: cast_nullable_to_non_nullable
as bool,lowPower: null == lowPower ? _self.lowPower : lowPower // ignore: cast_nullable_to_non_nullable
as bool,reducedMotion: null == reducedMotion ? _self.reducedMotion : reducedMotion // ignore: cast_nullable_to_non_nullable
as bool,highContrast: null == highContrast ? _self.highContrast : highContrast // ignore: cast_nullable_to_non_nullable
as bool,largerTargets: null == largerTargets ? _self.largerTargets : largerTargets // ignore: cast_nullable_to_non_nullable
as bool,haptics: null == haptics ? _self.haptics : haptics // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
