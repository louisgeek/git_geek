// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_prefs.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsState {

 String get repoPath; String get remote; String get langCode; String get sortModeName; String get branch;
/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsStateCopyWith<SettingsState> get copyWith => _$SettingsStateCopyWithImpl<SettingsState>(this as SettingsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SettingsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsState&&(identical(other.repoPath, _this.repoPath) || other.repoPath == _this.repoPath)&&(identical(other.remote, _this.remote) || other.remote == _this.remote)&&(identical(other.langCode, _this.langCode) || other.langCode == _this.langCode)&&(identical(other.sortModeName, _this.sortModeName) || other.sortModeName == _this.sortModeName)&&(identical(other.branch, _this.branch) || other.branch == _this.branch));
}


@override
int get hashCode {
  final _this = this as SettingsState;
  return Object.hash(runtimeType,_this.repoPath,_this.remote,_this.langCode,_this.sortModeName,_this.branch);
}

@override
String toString() {
  final _this = this as SettingsState;
  return 'SettingsState(repoPath: ${_this.repoPath}, remote: ${_this.remote}, langCode: ${_this.langCode}, sortModeName: ${_this.sortModeName}, branch: ${_this.branch})';
}


}

/// @nodoc
abstract mixin class $SettingsStateCopyWith<$Res>  {
  factory $SettingsStateCopyWith(SettingsState value, $Res Function(SettingsState) _then) = _$SettingsStateCopyWithImpl;
@useResult
$Res call({
 String repoPath, String remote, String langCode, String sortModeName, String branch
});




}
/// @nodoc
class _$SettingsStateCopyWithImpl<$Res>
    implements $SettingsStateCopyWith<$Res> {
  _$SettingsStateCopyWithImpl(this._self, this._then);

  final SettingsState _self;
  final $Res Function(SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? repoPath = null,Object? remote = null,Object? langCode = null,Object? sortModeName = null,Object? branch = null,}) {
  return _then(SettingsState(
repoPath: null == repoPath ? _self.repoPath : repoPath // ignore: cast_nullable_to_non_nullable
as String,remote: null == remote ? _self.remote : remote // ignore: cast_nullable_to_non_nullable
as String,langCode: null == langCode ? _self.langCode : langCode // ignore: cast_nullable_to_non_nullable
as String,sortModeName: null == sortModeName ? _self.sortModeName : sortModeName // ignore: cast_nullable_to_non_nullable
as String,branch: null == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SettingsState].
extension SettingsStatePatterns on SettingsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettingsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettingsState value)  $default,){
final _that = this;
switch (_that) {
case _SettingsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettingsState value)?  $default,){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String repoPath,  String remote,  String langCode,  String sortModeName,  String branch)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.repoPath,_that.remote,_that.langCode,_that.sortModeName,_that.branch);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String repoPath,  String remote,  String langCode,  String sortModeName,  String branch)  $default,) {final _that = this;
switch (_that) {
case _SettingsState():
return $default(_that.repoPath,_that.remote,_that.langCode,_that.sortModeName,_that.branch);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String repoPath,  String remote,  String langCode,  String sortModeName,  String branch)?  $default,) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.repoPath,_that.remote,_that.langCode,_that.sortModeName,_that.branch);case _:
  return null;

}
}

}

/// @nodoc


class _SettingsState implements SettingsState {
  const _SettingsState({this.repoPath = '', this.remote = 'origin', this.langCode = 'zh', this.sortModeName = 'semverDesc', this.branch = ''});
  

@override@JsonKey() final  String repoPath;
@override@JsonKey() final  String remote;
@override@JsonKey() final  String langCode;
@override@JsonKey() final  String sortModeName;
@override@JsonKey() final  String branch;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsStateCopyWith<_SettingsState> get copyWith => __$SettingsStateCopyWithImpl<_SettingsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingsState&&(identical(other.repoPath, repoPath) || other.repoPath == repoPath)&&(identical(other.remote, remote) || other.remote == remote)&&(identical(other.langCode, langCode) || other.langCode == langCode)&&(identical(other.sortModeName, sortModeName) || other.sortModeName == sortModeName)&&(identical(other.branch, branch) || other.branch == branch));
}


@override
int get hashCode {
    return Object.hash(runtimeType,repoPath,remote,langCode,sortModeName,branch);
}

@override
String toString() {
    return 'SettingsState(repoPath: $repoPath, remote: $remote, langCode: $langCode, sortModeName: $sortModeName, branch: $branch)';
}


}

/// @nodoc
abstract mixin class _$SettingsStateCopyWith<$Res> implements $SettingsStateCopyWith<$Res> {
  factory _$SettingsStateCopyWith(_SettingsState value, $Res Function(_SettingsState) _then) = __$SettingsStateCopyWithImpl;
@override @useResult
$Res call({
 String repoPath, String remote, String langCode, String sortModeName, String branch
});




}
/// @nodoc
class __$SettingsStateCopyWithImpl<$Res>
    implements _$SettingsStateCopyWith<$Res> {
  __$SettingsStateCopyWithImpl(this._self, this._then);

  final _SettingsState _self;
  final $Res Function(_SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? repoPath = null,Object? remote = null,Object? langCode = null,Object? sortModeName = null,Object? branch = null,}) {
  return _then(_SettingsState(
repoPath: null == repoPath ? _self.repoPath : repoPath // ignore: cast_nullable_to_non_nullable
as String,remote: null == remote ? _self.remote : remote // ignore: cast_nullable_to_non_nullable
as String,langCode: null == langCode ? _self.langCode : langCode // ignore: cast_nullable_to_non_nullable
as String,sortModeName: null == sortModeName ? _self.sortModeName : sortModeName // ignore: cast_nullable_to_non_nullable
as String,branch: null == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
