// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tags_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TagsState {

 List<GitTag> get localTags; List<GitTag> get remoteTags; String get query; TagSortMode get sortMode; TagFilter get filter; bool get isLoadingLocal; bool get isLoadingRemote; String? get localError; String? get remoteError; String get lastRefreshInfo; bool get remoteFromCache;
/// Create a copy of TagsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TagsStateCopyWith<TagsState> get copyWith => _$TagsStateCopyWithImpl<TagsState>(this as TagsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TagsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TagsState&&const DeepCollectionEquality().equals(other.localTags, _this.localTags)&&const DeepCollectionEquality().equals(other.remoteTags, _this.remoteTags)&&(identical(other.query, _this.query) || other.query == _this.query)&&(identical(other.sortMode, _this.sortMode) || other.sortMode == _this.sortMode)&&(identical(other.filter, _this.filter) || other.filter == _this.filter)&&(identical(other.isLoadingLocal, _this.isLoadingLocal) || other.isLoadingLocal == _this.isLoadingLocal)&&(identical(other.isLoadingRemote, _this.isLoadingRemote) || other.isLoadingRemote == _this.isLoadingRemote)&&(identical(other.localError, _this.localError) || other.localError == _this.localError)&&(identical(other.remoteError, _this.remoteError) || other.remoteError == _this.remoteError)&&(identical(other.lastRefreshInfo, _this.lastRefreshInfo) || other.lastRefreshInfo == _this.lastRefreshInfo)&&(identical(other.remoteFromCache, _this.remoteFromCache) || other.remoteFromCache == _this.remoteFromCache));
}


@override
int get hashCode {
  final _this = this as TagsState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.localTags),const DeepCollectionEquality().hash(_this.remoteTags),_this.query,_this.sortMode,_this.filter,_this.isLoadingLocal,_this.isLoadingRemote,_this.localError,_this.remoteError,_this.lastRefreshInfo,_this.remoteFromCache);
}

@override
String toString() {
  final _this = this as TagsState;
  return 'TagsState(localTags: ${_this.localTags}, remoteTags: ${_this.remoteTags}, query: ${_this.query}, sortMode: ${_this.sortMode}, filter: ${_this.filter}, isLoadingLocal: ${_this.isLoadingLocal}, isLoadingRemote: ${_this.isLoadingRemote}, localError: ${_this.localError}, remoteError: ${_this.remoteError}, lastRefreshInfo: ${_this.lastRefreshInfo}, remoteFromCache: ${_this.remoteFromCache})';
}


}

/// @nodoc
abstract mixin class $TagsStateCopyWith<$Res>  {
  factory $TagsStateCopyWith(TagsState value, $Res Function(TagsState) _then) = _$TagsStateCopyWithImpl;
@useResult
$Res call({
 List<GitTag> localTags, List<GitTag> remoteTags, String query, TagSortMode sortMode, TagFilter filter, bool isLoadingLocal, bool isLoadingRemote, String? localError, String? remoteError, String lastRefreshInfo, bool remoteFromCache
});




}
/// @nodoc
class _$TagsStateCopyWithImpl<$Res>
    implements $TagsStateCopyWith<$Res> {
  _$TagsStateCopyWithImpl(this._self, this._then);

  final TagsState _self;
  final $Res Function(TagsState) _then;

/// Create a copy of TagsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? localTags = null,Object? remoteTags = null,Object? query = null,Object? sortMode = null,Object? filter = null,Object? isLoadingLocal = null,Object? isLoadingRemote = null,Object? localError = freezed,Object? remoteError = freezed,Object? lastRefreshInfo = null,Object? remoteFromCache = null,}) {
  return _then(TagsState(
localTags: null == localTags ? _self.localTags : localTags // ignore: cast_nullable_to_non_nullable
as List<GitTag>,remoteTags: null == remoteTags ? _self.remoteTags : remoteTags // ignore: cast_nullable_to_non_nullable
as List<GitTag>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,sortMode: null == sortMode ? _self.sortMode : sortMode // ignore: cast_nullable_to_non_nullable
as TagSortMode,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as TagFilter,isLoadingLocal: null == isLoadingLocal ? _self.isLoadingLocal : isLoadingLocal // ignore: cast_nullable_to_non_nullable
as bool,isLoadingRemote: null == isLoadingRemote ? _self.isLoadingRemote : isLoadingRemote // ignore: cast_nullable_to_non_nullable
as bool,localError: freezed == localError ? _self.localError : localError // ignore: cast_nullable_to_non_nullable
as String?,remoteError: freezed == remoteError ? _self.remoteError : remoteError // ignore: cast_nullable_to_non_nullable
as String?,lastRefreshInfo: null == lastRefreshInfo ? _self.lastRefreshInfo : lastRefreshInfo // ignore: cast_nullable_to_non_nullable
as String,remoteFromCache: null == remoteFromCache ? _self.remoteFromCache : remoteFromCache // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TagsState].
extension TagsStatePatterns on TagsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TagsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TagsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TagsState value)  $default,){
final _that = this;
switch (_that) {
case _TagsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TagsState value)?  $default,){
final _that = this;
switch (_that) {
case _TagsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<GitTag> localTags,  List<GitTag> remoteTags,  String query,  TagSortMode sortMode,  TagFilter filter,  bool isLoadingLocal,  bool isLoadingRemote,  String? localError,  String? remoteError,  String lastRefreshInfo,  bool remoteFromCache)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TagsState() when $default != null:
return $default(_that.localTags,_that.remoteTags,_that.query,_that.sortMode,_that.filter,_that.isLoadingLocal,_that.isLoadingRemote,_that.localError,_that.remoteError,_that.lastRefreshInfo,_that.remoteFromCache);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<GitTag> localTags,  List<GitTag> remoteTags,  String query,  TagSortMode sortMode,  TagFilter filter,  bool isLoadingLocal,  bool isLoadingRemote,  String? localError,  String? remoteError,  String lastRefreshInfo,  bool remoteFromCache)  $default,) {final _that = this;
switch (_that) {
case _TagsState():
return $default(_that.localTags,_that.remoteTags,_that.query,_that.sortMode,_that.filter,_that.isLoadingLocal,_that.isLoadingRemote,_that.localError,_that.remoteError,_that.lastRefreshInfo,_that.remoteFromCache);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<GitTag> localTags,  List<GitTag> remoteTags,  String query,  TagSortMode sortMode,  TagFilter filter,  bool isLoadingLocal,  bool isLoadingRemote,  String? localError,  String? remoteError,  String lastRefreshInfo,  bool remoteFromCache)?  $default,) {final _that = this;
switch (_that) {
case _TagsState() when $default != null:
return $default(_that.localTags,_that.remoteTags,_that.query,_that.sortMode,_that.filter,_that.isLoadingLocal,_that.isLoadingRemote,_that.localError,_that.remoteError,_that.lastRefreshInfo,_that.remoteFromCache);case _:
  return null;

}
}

}

/// @nodoc


class _TagsState implements TagsState {
  const _TagsState({ List<GitTag> localTags = const [],  List<GitTag> remoteTags = const [], this.query = '', this.sortMode = TagSortMode.semverDesc, this.filter = TagFilter.all, this.isLoadingLocal = false, this.isLoadingRemote = false, this.localError, this.remoteError, this.lastRefreshInfo = '', this.remoteFromCache = false}): _localTags = localTags,_remoteTags = remoteTags;
  

 final  List<GitTag> _localTags;
@override@JsonKey() List<GitTag> get localTags {
  if (_localTags is EqualUnmodifiableListView) return _localTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_localTags);
}

 final  List<GitTag> _remoteTags;
@override@JsonKey() List<GitTag> get remoteTags {
  if (_remoteTags is EqualUnmodifiableListView) return _remoteTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_remoteTags);
}

@override@JsonKey() final  String query;
@override@JsonKey() final  TagSortMode sortMode;
@override@JsonKey() final  TagFilter filter;
@override@JsonKey() final  bool isLoadingLocal;
@override@JsonKey() final  bool isLoadingRemote;
@override final  String? localError;
@override final  String? remoteError;
@override@JsonKey() final  String lastRefreshInfo;
@override@JsonKey() final  bool remoteFromCache;

/// Create a copy of TagsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TagsStateCopyWith<_TagsState> get copyWith => __$TagsStateCopyWithImpl<_TagsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TagsState&&const DeepCollectionEquality().equals(other.localTags, _localTags)&&const DeepCollectionEquality().equals(other.remoteTags, _remoteTags)&&(identical(other.query, query) || other.query == query)&&(identical(other.sortMode, sortMode) || other.sortMode == sortMode)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.isLoadingLocal, isLoadingLocal) || other.isLoadingLocal == isLoadingLocal)&&(identical(other.isLoadingRemote, isLoadingRemote) || other.isLoadingRemote == isLoadingRemote)&&(identical(other.localError, localError) || other.localError == localError)&&(identical(other.remoteError, remoteError) || other.remoteError == remoteError)&&(identical(other.lastRefreshInfo, lastRefreshInfo) || other.lastRefreshInfo == lastRefreshInfo)&&(identical(other.remoteFromCache, remoteFromCache) || other.remoteFromCache == remoteFromCache));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_localTags),const DeepCollectionEquality().hash(_remoteTags),query,sortMode,filter,isLoadingLocal,isLoadingRemote,localError,remoteError,lastRefreshInfo,remoteFromCache);
}

@override
String toString() {
    return 'TagsState(localTags: $localTags, remoteTags: $remoteTags, query: $query, sortMode: $sortMode, filter: $filter, isLoadingLocal: $isLoadingLocal, isLoadingRemote: $isLoadingRemote, localError: $localError, remoteError: $remoteError, lastRefreshInfo: $lastRefreshInfo, remoteFromCache: $remoteFromCache)';
}


}

/// @nodoc
abstract mixin class _$TagsStateCopyWith<$Res> implements $TagsStateCopyWith<$Res> {
  factory _$TagsStateCopyWith(_TagsState value, $Res Function(_TagsState) _then) = __$TagsStateCopyWithImpl;
@override @useResult
$Res call({
 List<GitTag> localTags, List<GitTag> remoteTags, String query, TagSortMode sortMode, TagFilter filter, bool isLoadingLocal, bool isLoadingRemote, String? localError, String? remoteError, String lastRefreshInfo, bool remoteFromCache
});




}
/// @nodoc
class __$TagsStateCopyWithImpl<$Res>
    implements _$TagsStateCopyWith<$Res> {
  __$TagsStateCopyWithImpl(this._self, this._then);

  final _TagsState _self;
  final $Res Function(_TagsState) _then;

/// Create a copy of TagsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? localTags = null,Object? remoteTags = null,Object? query = null,Object? sortMode = null,Object? filter = null,Object? isLoadingLocal = null,Object? isLoadingRemote = null,Object? localError = freezed,Object? remoteError = freezed,Object? lastRefreshInfo = null,Object? remoteFromCache = null,}) {
  return _then(_TagsState(
localTags: null == localTags ? _self._localTags : localTags // ignore: cast_nullable_to_non_nullable
as List<GitTag>,remoteTags: null == remoteTags ? _self._remoteTags : remoteTags // ignore: cast_nullable_to_non_nullable
as List<GitTag>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,sortMode: null == sortMode ? _self.sortMode : sortMode // ignore: cast_nullable_to_non_nullable
as TagSortMode,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as TagFilter,isLoadingLocal: null == isLoadingLocal ? _self.isLoadingLocal : isLoadingLocal // ignore: cast_nullable_to_non_nullable
as bool,isLoadingRemote: null == isLoadingRemote ? _self.isLoadingRemote : isLoadingRemote // ignore: cast_nullable_to_non_nullable
as bool,localError: freezed == localError ? _self.localError : localError // ignore: cast_nullable_to_non_nullable
as String?,remoteError: freezed == remoteError ? _self.remoteError : remoteError // ignore: cast_nullable_to_non_nullable
as String?,lastRefreshInfo: null == lastRefreshInfo ? _self.lastRefreshInfo : lastRefreshInfo // ignore: cast_nullable_to_non_nullable
as String,remoteFromCache: null == remoteFromCache ? _self.remoteFromCache : remoteFromCache // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
