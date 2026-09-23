// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workspace_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WorkspaceState {

 String get repoPath; String get remote; AppLang get lang; int get selectedTagTab; String get selectedScope; String get cacheDirHint;
/// Create a copy of WorkspaceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkspaceStateCopyWith<WorkspaceState> get copyWith => _$WorkspaceStateCopyWithImpl<WorkspaceState>(this as WorkspaceState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WorkspaceState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceState&&(identical(other.repoPath, _this.repoPath) || other.repoPath == _this.repoPath)&&(identical(other.remote, _this.remote) || other.remote == _this.remote)&&(identical(other.lang, _this.lang) || other.lang == _this.lang)&&(identical(other.selectedTagTab, _this.selectedTagTab) || other.selectedTagTab == _this.selectedTagTab)&&(identical(other.selectedScope, _this.selectedScope) || other.selectedScope == _this.selectedScope)&&(identical(other.cacheDirHint, _this.cacheDirHint) || other.cacheDirHint == _this.cacheDirHint));
}


@override
int get hashCode {
  final _this = this as WorkspaceState;
  return Object.hash(runtimeType,_this.repoPath,_this.remote,_this.lang,_this.selectedTagTab,_this.selectedScope,_this.cacheDirHint);
}

@override
String toString() {
  final _this = this as WorkspaceState;
  return 'WorkspaceState(repoPath: ${_this.repoPath}, remote: ${_this.remote}, lang: ${_this.lang}, selectedTagTab: ${_this.selectedTagTab}, selectedScope: ${_this.selectedScope}, cacheDirHint: ${_this.cacheDirHint})';
}


}

/// @nodoc
abstract mixin class $WorkspaceStateCopyWith<$Res>  {
  factory $WorkspaceStateCopyWith(WorkspaceState value, $Res Function(WorkspaceState) _then) = _$WorkspaceStateCopyWithImpl;
@useResult
$Res call({
 String repoPath, String remote, AppLang lang, int selectedTagTab, String selectedScope, String cacheDirHint
});




}
/// @nodoc
class _$WorkspaceStateCopyWithImpl<$Res>
    implements $WorkspaceStateCopyWith<$Res> {
  _$WorkspaceStateCopyWithImpl(this._self, this._then);

  final WorkspaceState _self;
  final $Res Function(WorkspaceState) _then;

/// Create a copy of WorkspaceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? repoPath = null,Object? remote = null,Object? lang = null,Object? selectedTagTab = null,Object? selectedScope = null,Object? cacheDirHint = null,}) {
  return _then(WorkspaceState(
repoPath: null == repoPath ? _self.repoPath : repoPath // ignore: cast_nullable_to_non_nullable
as String,remote: null == remote ? _self.remote : remote // ignore: cast_nullable_to_non_nullable
as String,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as AppLang,selectedTagTab: null == selectedTagTab ? _self.selectedTagTab : selectedTagTab // ignore: cast_nullable_to_non_nullable
as int,selectedScope: null == selectedScope ? _self.selectedScope : selectedScope // ignore: cast_nullable_to_non_nullable
as String,cacheDirHint: null == cacheDirHint ? _self.cacheDirHint : cacheDirHint // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkspaceState].
extension WorkspaceStatePatterns on WorkspaceState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkspaceState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkspaceState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkspaceState value)  $default,){
final _that = this;
switch (_that) {
case _WorkspaceState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkspaceState value)?  $default,){
final _that = this;
switch (_that) {
case _WorkspaceState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String repoPath,  String remote,  AppLang lang,  int selectedTagTab,  String selectedScope,  String cacheDirHint)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkspaceState() when $default != null:
return $default(_that.repoPath,_that.remote,_that.lang,_that.selectedTagTab,_that.selectedScope,_that.cacheDirHint);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String repoPath,  String remote,  AppLang lang,  int selectedTagTab,  String selectedScope,  String cacheDirHint)  $default,) {final _that = this;
switch (_that) {
case _WorkspaceState():
return $default(_that.repoPath,_that.remote,_that.lang,_that.selectedTagTab,_that.selectedScope,_that.cacheDirHint);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String repoPath,  String remote,  AppLang lang,  int selectedTagTab,  String selectedScope,  String cacheDirHint)?  $default,) {final _that = this;
switch (_that) {
case _WorkspaceState() when $default != null:
return $default(_that.repoPath,_that.remote,_that.lang,_that.selectedTagTab,_that.selectedScope,_that.cacheDirHint);case _:
  return null;

}
}

}

/// @nodoc


class _WorkspaceState implements WorkspaceState {
  const _WorkspaceState({this.repoPath = '', this.remote = 'origin', this.lang = AppLang.zh, this.selectedTagTab = 0, this.selectedScope = '', this.cacheDirHint = ''});
  

@override@JsonKey() final  String repoPath;
@override@JsonKey() final  String remote;
@override@JsonKey() final  AppLang lang;
@override@JsonKey() final  int selectedTagTab;
@override@JsonKey() final  String selectedScope;
@override@JsonKey() final  String cacheDirHint;

/// Create a copy of WorkspaceState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkspaceStateCopyWith<_WorkspaceState> get copyWith => __$WorkspaceStateCopyWithImpl<_WorkspaceState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkspaceState&&(identical(other.repoPath, repoPath) || other.repoPath == repoPath)&&(identical(other.remote, remote) || other.remote == remote)&&(identical(other.lang, lang) || other.lang == lang)&&(identical(other.selectedTagTab, selectedTagTab) || other.selectedTagTab == selectedTagTab)&&(identical(other.selectedScope, selectedScope) || other.selectedScope == selectedScope)&&(identical(other.cacheDirHint, cacheDirHint) || other.cacheDirHint == cacheDirHint));
}


@override
int get hashCode {
    return Object.hash(runtimeType,repoPath,remote,lang,selectedTagTab,selectedScope,cacheDirHint);
}

@override
String toString() {
    return 'WorkspaceState(repoPath: $repoPath, remote: $remote, lang: $lang, selectedTagTab: $selectedTagTab, selectedScope: $selectedScope, cacheDirHint: $cacheDirHint)';
}


}

/// @nodoc
abstract mixin class _$WorkspaceStateCopyWith<$Res> implements $WorkspaceStateCopyWith<$Res> {
  factory _$WorkspaceStateCopyWith(_WorkspaceState value, $Res Function(_WorkspaceState) _then) = __$WorkspaceStateCopyWithImpl;
@override @useResult
$Res call({
 String repoPath, String remote, AppLang lang, int selectedTagTab, String selectedScope, String cacheDirHint
});




}
/// @nodoc
class __$WorkspaceStateCopyWithImpl<$Res>
    implements _$WorkspaceStateCopyWith<$Res> {
  __$WorkspaceStateCopyWithImpl(this._self, this._then);

  final _WorkspaceState _self;
  final $Res Function(_WorkspaceState) _then;

/// Create a copy of WorkspaceState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? repoPath = null,Object? remote = null,Object? lang = null,Object? selectedTagTab = null,Object? selectedScope = null,Object? cacheDirHint = null,}) {
  return _then(_WorkspaceState(
repoPath: null == repoPath ? _self.repoPath : repoPath // ignore: cast_nullable_to_non_nullable
as String,remote: null == remote ? _self.remote : remote // ignore: cast_nullable_to_non_nullable
as String,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as AppLang,selectedTagTab: null == selectedTagTab ? _self.selectedTagTab : selectedTagTab // ignore: cast_nullable_to_non_nullable
as int,selectedScope: null == selectedScope ? _self.selectedScope : selectedScope // ignore: cast_nullable_to_non_nullable
as String,cacheDirHint: null == cacheDirHint ? _self.cacheDirHint : cacheDirHint // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
