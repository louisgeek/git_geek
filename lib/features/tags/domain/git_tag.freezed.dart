// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'git_tag.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GitTag {

 String get name; String? get commitSha; String? get tagObjectSha; bool? get isAnnotated; String? get tagger; String? get tagDate; String? get tagMessage; String? get commitAuthor; String? get commitDate; String? get commitSubject; String? get commitBody; TagSource get source;
/// Create a copy of GitTag
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitTagCopyWith<GitTag> get copyWith => _$GitTagCopyWithImpl<GitTag>(this as GitTag, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as GitTag;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitTag&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.commitSha, _this.commitSha) || other.commitSha == _this.commitSha)&&(identical(other.tagObjectSha, _this.tagObjectSha) || other.tagObjectSha == _this.tagObjectSha)&&(identical(other.isAnnotated, _this.isAnnotated) || other.isAnnotated == _this.isAnnotated)&&(identical(other.tagger, _this.tagger) || other.tagger == _this.tagger)&&(identical(other.tagDate, _this.tagDate) || other.tagDate == _this.tagDate)&&(identical(other.tagMessage, _this.tagMessage) || other.tagMessage == _this.tagMessage)&&(identical(other.commitAuthor, _this.commitAuthor) || other.commitAuthor == _this.commitAuthor)&&(identical(other.commitDate, _this.commitDate) || other.commitDate == _this.commitDate)&&(identical(other.commitSubject, _this.commitSubject) || other.commitSubject == _this.commitSubject)&&(identical(other.commitBody, _this.commitBody) || other.commitBody == _this.commitBody)&&(identical(other.source, _this.source) || other.source == _this.source));
}


@override
int get hashCode {
  final _this = this as GitTag;
  return Object.hash(runtimeType,_this.name,_this.commitSha,_this.tagObjectSha,_this.isAnnotated,_this.tagger,_this.tagDate,_this.tagMessage,_this.commitAuthor,_this.commitDate,_this.commitSubject,_this.commitBody,_this.source);
}

@override
String toString() {
  final _this = this as GitTag;
  return 'GitTag(name: ${_this.name}, commitSha: ${_this.commitSha}, tagObjectSha: ${_this.tagObjectSha}, isAnnotated: ${_this.isAnnotated}, tagger: ${_this.tagger}, tagDate: ${_this.tagDate}, tagMessage: ${_this.tagMessage}, commitAuthor: ${_this.commitAuthor}, commitDate: ${_this.commitDate}, commitSubject: ${_this.commitSubject}, commitBody: ${_this.commitBody}, source: ${_this.source})';
}


}

/// @nodoc
abstract mixin class $GitTagCopyWith<$Res>  {
  factory $GitTagCopyWith(GitTag value, $Res Function(GitTag) _then) = _$GitTagCopyWithImpl;
@useResult
$Res call({
 String name, String? commitSha, String? tagObjectSha, bool? isAnnotated, String? tagger, String? tagDate, String? tagMessage, String? commitAuthor, String? commitDate, String? commitSubject, String? commitBody, TagSource source
});




}
/// @nodoc
class _$GitTagCopyWithImpl<$Res>
    implements $GitTagCopyWith<$Res> {
  _$GitTagCopyWithImpl(this._self, this._then);

  final GitTag _self;
  final $Res Function(GitTag) _then;

/// Create a copy of GitTag
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? commitSha = freezed,Object? tagObjectSha = freezed,Object? isAnnotated = freezed,Object? tagger = freezed,Object? tagDate = freezed,Object? tagMessage = freezed,Object? commitAuthor = freezed,Object? commitDate = freezed,Object? commitSubject = freezed,Object? commitBody = freezed,Object? source = null,}) {
  return _then(GitTag(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,commitSha: freezed == commitSha ? _self.commitSha : commitSha // ignore: cast_nullable_to_non_nullable
as String?,tagObjectSha: freezed == tagObjectSha ? _self.tagObjectSha : tagObjectSha // ignore: cast_nullable_to_non_nullable
as String?,isAnnotated: freezed == isAnnotated ? _self.isAnnotated : isAnnotated // ignore: cast_nullable_to_non_nullable
as bool?,tagger: freezed == tagger ? _self.tagger : tagger // ignore: cast_nullable_to_non_nullable
as String?,tagDate: freezed == tagDate ? _self.tagDate : tagDate // ignore: cast_nullable_to_non_nullable
as String?,tagMessage: freezed == tagMessage ? _self.tagMessage : tagMessage // ignore: cast_nullable_to_non_nullable
as String?,commitAuthor: freezed == commitAuthor ? _self.commitAuthor : commitAuthor // ignore: cast_nullable_to_non_nullable
as String?,commitDate: freezed == commitDate ? _self.commitDate : commitDate // ignore: cast_nullable_to_non_nullable
as String?,commitSubject: freezed == commitSubject ? _self.commitSubject : commitSubject // ignore: cast_nullable_to_non_nullable
as String?,commitBody: freezed == commitBody ? _self.commitBody : commitBody // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as TagSource,
  ));
}

}


/// Adds pattern-matching-related methods to [GitTag].
extension GitTagPatterns on GitTag {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitTag value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitTag() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitTag value)  $default,){
final _that = this;
switch (_that) {
case _GitTag():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitTag value)?  $default,){
final _that = this;
switch (_that) {
case _GitTag() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? commitSha,  String? tagObjectSha,  bool? isAnnotated,  String? tagger,  String? tagDate,  String? tagMessage,  String? commitAuthor,  String? commitDate,  String? commitSubject,  String? commitBody,  TagSource source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitTag() when $default != null:
return $default(_that.name,_that.commitSha,_that.tagObjectSha,_that.isAnnotated,_that.tagger,_that.tagDate,_that.tagMessage,_that.commitAuthor,_that.commitDate,_that.commitSubject,_that.commitBody,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? commitSha,  String? tagObjectSha,  bool? isAnnotated,  String? tagger,  String? tagDate,  String? tagMessage,  String? commitAuthor,  String? commitDate,  String? commitSubject,  String? commitBody,  TagSource source)  $default,) {final _that = this;
switch (_that) {
case _GitTag():
return $default(_that.name,_that.commitSha,_that.tagObjectSha,_that.isAnnotated,_that.tagger,_that.tagDate,_that.tagMessage,_that.commitAuthor,_that.commitDate,_that.commitSubject,_that.commitBody,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? commitSha,  String? tagObjectSha,  bool? isAnnotated,  String? tagger,  String? tagDate,  String? tagMessage,  String? commitAuthor,  String? commitDate,  String? commitSubject,  String? commitBody,  TagSource source)?  $default,) {final _that = this;
switch (_that) {
case _GitTag() when $default != null:
return $default(_that.name,_that.commitSha,_that.tagObjectSha,_that.isAnnotated,_that.tagger,_that.tagDate,_that.tagMessage,_that.commitAuthor,_that.commitDate,_that.commitSubject,_that.commitBody,_that.source);case _:
  return null;

}
}

}

/// @nodoc


class _GitTag implements GitTag {
  const _GitTag({required this.name, this.commitSha, this.tagObjectSha, this.isAnnotated, this.tagger, this.tagDate, this.tagMessage, this.commitAuthor, this.commitDate, this.commitSubject, this.commitBody, this.source = TagSource.local});
  

@override final  String name;
@override final  String? commitSha;
@override final  String? tagObjectSha;
@override final  bool? isAnnotated;
@override final  String? tagger;
@override final  String? tagDate;
@override final  String? tagMessage;
@override final  String? commitAuthor;
@override final  String? commitDate;
@override final  String? commitSubject;
@override final  String? commitBody;
@override@JsonKey() final  TagSource source;

/// Create a copy of GitTag
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitTagCopyWith<_GitTag> get copyWith => __$GitTagCopyWithImpl<_GitTag>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitTag&&(identical(other.name, name) || other.name == name)&&(identical(other.commitSha, commitSha) || other.commitSha == commitSha)&&(identical(other.tagObjectSha, tagObjectSha) || other.tagObjectSha == tagObjectSha)&&(identical(other.isAnnotated, isAnnotated) || other.isAnnotated == isAnnotated)&&(identical(other.tagger, tagger) || other.tagger == tagger)&&(identical(other.tagDate, tagDate) || other.tagDate == tagDate)&&(identical(other.tagMessage, tagMessage) || other.tagMessage == tagMessage)&&(identical(other.commitAuthor, commitAuthor) || other.commitAuthor == commitAuthor)&&(identical(other.commitDate, commitDate) || other.commitDate == commitDate)&&(identical(other.commitSubject, commitSubject) || other.commitSubject == commitSubject)&&(identical(other.commitBody, commitBody) || other.commitBody == commitBody)&&(identical(other.source, source) || other.source == source));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,commitSha,tagObjectSha,isAnnotated,tagger,tagDate,tagMessage,commitAuthor,commitDate,commitSubject,commitBody,source);
}

@override
String toString() {
    return 'GitTag(name: $name, commitSha: $commitSha, tagObjectSha: $tagObjectSha, isAnnotated: $isAnnotated, tagger: $tagger, tagDate: $tagDate, tagMessage: $tagMessage, commitAuthor: $commitAuthor, commitDate: $commitDate, commitSubject: $commitSubject, commitBody: $commitBody, source: $source)';
}


}

/// @nodoc
abstract mixin class _$GitTagCopyWith<$Res> implements $GitTagCopyWith<$Res> {
  factory _$GitTagCopyWith(_GitTag value, $Res Function(_GitTag) _then) = __$GitTagCopyWithImpl;
@override @useResult
$Res call({
 String name, String? commitSha, String? tagObjectSha, bool? isAnnotated, String? tagger, String? tagDate, String? tagMessage, String? commitAuthor, String? commitDate, String? commitSubject, String? commitBody, TagSource source
});




}
/// @nodoc
class __$GitTagCopyWithImpl<$Res>
    implements _$GitTagCopyWith<$Res> {
  __$GitTagCopyWithImpl(this._self, this._then);

  final _GitTag _self;
  final $Res Function(_GitTag) _then;

/// Create a copy of GitTag
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? commitSha = freezed,Object? tagObjectSha = freezed,Object? isAnnotated = freezed,Object? tagger = freezed,Object? tagDate = freezed,Object? tagMessage = freezed,Object? commitAuthor = freezed,Object? commitDate = freezed,Object? commitSubject = freezed,Object? commitBody = freezed,Object? source = null,}) {
  return _then(_GitTag(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,commitSha: freezed == commitSha ? _self.commitSha : commitSha // ignore: cast_nullable_to_non_nullable
as String?,tagObjectSha: freezed == tagObjectSha ? _self.tagObjectSha : tagObjectSha // ignore: cast_nullable_to_non_nullable
as String?,isAnnotated: freezed == isAnnotated ? _self.isAnnotated : isAnnotated // ignore: cast_nullable_to_non_nullable
as bool?,tagger: freezed == tagger ? _self.tagger : tagger // ignore: cast_nullable_to_non_nullable
as String?,tagDate: freezed == tagDate ? _self.tagDate : tagDate // ignore: cast_nullable_to_non_nullable
as String?,tagMessage: freezed == tagMessage ? _self.tagMessage : tagMessage // ignore: cast_nullable_to_non_nullable
as String?,commitAuthor: freezed == commitAuthor ? _self.commitAuthor : commitAuthor // ignore: cast_nullable_to_non_nullable
as String?,commitDate: freezed == commitDate ? _self.commitDate : commitDate // ignore: cast_nullable_to_non_nullable
as String?,commitSubject: freezed == commitSubject ? _self.commitSubject : commitSubject // ignore: cast_nullable_to_non_nullable
as String?,commitBody: freezed == commitBody ? _self.commitBody : commitBody // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as TagSource,
  ));
}


}

/// @nodoc
mixin _$TagCompareItem {

 String get name; GitTag? get local; GitTag? get remote; TagSyncStatus get status;
/// Create a copy of TagCompareItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TagCompareItemCopyWith<TagCompareItem> get copyWith => _$TagCompareItemCopyWithImpl<TagCompareItem>(this as TagCompareItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TagCompareItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TagCompareItem&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.local, _this.local) || other.local == _this.local)&&(identical(other.remote, _this.remote) || other.remote == _this.remote)&&(identical(other.status, _this.status) || other.status == _this.status));
}


@override
int get hashCode {
  final _this = this as TagCompareItem;
  return Object.hash(runtimeType,_this.name,_this.local,_this.remote,_this.status);
}

@override
String toString() {
  final _this = this as TagCompareItem;
  return 'TagCompareItem(name: ${_this.name}, local: ${_this.local}, remote: ${_this.remote}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $TagCompareItemCopyWith<$Res>  {
  factory $TagCompareItemCopyWith(TagCompareItem value, $Res Function(TagCompareItem) _then) = _$TagCompareItemCopyWithImpl;
@useResult
$Res call({
 String name, GitTag? local, GitTag? remote, TagSyncStatus status
});


$GitTagCopyWith<$Res>? get local;$GitTagCopyWith<$Res>? get remote;

}
/// @nodoc
class _$TagCompareItemCopyWithImpl<$Res>
    implements $TagCompareItemCopyWith<$Res> {
  _$TagCompareItemCopyWithImpl(this._self, this._then);

  final TagCompareItem _self;
  final $Res Function(TagCompareItem) _then;

/// Create a copy of TagCompareItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? local = freezed,Object? remote = freezed,Object? status = null,}) {
  return _then(TagCompareItem(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,local: freezed == local ? _self.local : local // ignore: cast_nullable_to_non_nullable
as GitTag?,remote: freezed == remote ? _self.remote : remote // ignore: cast_nullable_to_non_nullable
as GitTag?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TagSyncStatus,
  ));
}
/// Create a copy of TagCompareItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GitTagCopyWith<$Res>? get local {
    if (_self.local == null) {
    return null;
  }

  return $GitTagCopyWith<$Res>(_self.local!, (value) {
    return _then(_self.copyWith(local: value));
  });
}/// Create a copy of TagCompareItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GitTagCopyWith<$Res>? get remote {
    if (_self.remote == null) {
    return null;
  }

  return $GitTagCopyWith<$Res>(_self.remote!, (value) {
    return _then(_self.copyWith(remote: value));
  });
}
}


/// Adds pattern-matching-related methods to [TagCompareItem].
extension TagCompareItemPatterns on TagCompareItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TagCompareItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TagCompareItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TagCompareItem value)  $default,){
final _that = this;
switch (_that) {
case _TagCompareItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TagCompareItem value)?  $default,){
final _that = this;
switch (_that) {
case _TagCompareItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  GitTag? local,  GitTag? remote,  TagSyncStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TagCompareItem() when $default != null:
return $default(_that.name,_that.local,_that.remote,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  GitTag? local,  GitTag? remote,  TagSyncStatus status)  $default,) {final _that = this;
switch (_that) {
case _TagCompareItem():
return $default(_that.name,_that.local,_that.remote,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  GitTag? local,  GitTag? remote,  TagSyncStatus status)?  $default,) {final _that = this;
switch (_that) {
case _TagCompareItem() when $default != null:
return $default(_that.name,_that.local,_that.remote,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _TagCompareItem implements TagCompareItem {
  const _TagCompareItem({required this.name, this.local, this.remote, required this.status});
  

@override final  String name;
@override final  GitTag? local;
@override final  GitTag? remote;
@override final  TagSyncStatus status;

/// Create a copy of TagCompareItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TagCompareItemCopyWith<_TagCompareItem> get copyWith => __$TagCompareItemCopyWithImpl<_TagCompareItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TagCompareItem&&(identical(other.name, name) || other.name == name)&&(identical(other.local, local) || other.local == local)&&(identical(other.remote, remote) || other.remote == remote)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,local,remote,status);
}

@override
String toString() {
    return 'TagCompareItem(name: $name, local: $local, remote: $remote, status: $status)';
}


}

/// @nodoc
abstract mixin class _$TagCompareItemCopyWith<$Res> implements $TagCompareItemCopyWith<$Res> {
  factory _$TagCompareItemCopyWith(_TagCompareItem value, $Res Function(_TagCompareItem) _then) = __$TagCompareItemCopyWithImpl;
@override @useResult
$Res call({
 String name, GitTag? local, GitTag? remote, TagSyncStatus status
});


@override $GitTagCopyWith<$Res>? get local;@override $GitTagCopyWith<$Res>? get remote;

}
/// @nodoc
class __$TagCompareItemCopyWithImpl<$Res>
    implements _$TagCompareItemCopyWith<$Res> {
  __$TagCompareItemCopyWithImpl(this._self, this._then);

  final _TagCompareItem _self;
  final $Res Function(_TagCompareItem) _then;

/// Create a copy of TagCompareItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? local = freezed,Object? remote = freezed,Object? status = null,}) {
  return _then(_TagCompareItem(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,local: freezed == local ? _self.local : local // ignore: cast_nullable_to_non_nullable
as GitTag?,remote: freezed == remote ? _self.remote : remote // ignore: cast_nullable_to_non_nullable
as GitTag?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TagSyncStatus,
  ));
}

/// Create a copy of TagCompareItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GitTagCopyWith<$Res>? get local {
    if (_self.local == null) {
    return null;
  }

  return $GitTagCopyWith<$Res>(_self.local!, (value) {
    return _then(_self.copyWith(local: value));
  });
}/// Create a copy of TagCompareItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GitTagCopyWith<$Res>? get remote {
    if (_self.remote == null) {
    return null;
  }

  return $GitTagCopyWith<$Res>(_self.remote!, (value) {
    return _then(_self.copyWith(remote: value));
  });
}
}

/// @nodoc
mixin _$TagStats {

 int get localCount; int get remoteCount; int get syncedCount; int get onlyLocalCount; int get onlyRemoteCount; int get divergedCount;
/// Create a copy of TagStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TagStatsCopyWith<TagStats> get copyWith => _$TagStatsCopyWithImpl<TagStats>(this as TagStats, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TagStats;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TagStats&&(identical(other.localCount, _this.localCount) || other.localCount == _this.localCount)&&(identical(other.remoteCount, _this.remoteCount) || other.remoteCount == _this.remoteCount)&&(identical(other.syncedCount, _this.syncedCount) || other.syncedCount == _this.syncedCount)&&(identical(other.onlyLocalCount, _this.onlyLocalCount) || other.onlyLocalCount == _this.onlyLocalCount)&&(identical(other.onlyRemoteCount, _this.onlyRemoteCount) || other.onlyRemoteCount == _this.onlyRemoteCount)&&(identical(other.divergedCount, _this.divergedCount) || other.divergedCount == _this.divergedCount));
}


@override
int get hashCode {
  final _this = this as TagStats;
  return Object.hash(runtimeType,_this.localCount,_this.remoteCount,_this.syncedCount,_this.onlyLocalCount,_this.onlyRemoteCount,_this.divergedCount);
}

@override
String toString() {
  final _this = this as TagStats;
  return 'TagStats(localCount: ${_this.localCount}, remoteCount: ${_this.remoteCount}, syncedCount: ${_this.syncedCount}, onlyLocalCount: ${_this.onlyLocalCount}, onlyRemoteCount: ${_this.onlyRemoteCount}, divergedCount: ${_this.divergedCount})';
}


}

/// @nodoc
abstract mixin class $TagStatsCopyWith<$Res>  {
  factory $TagStatsCopyWith(TagStats value, $Res Function(TagStats) _then) = _$TagStatsCopyWithImpl;
@useResult
$Res call({
 int localCount, int remoteCount, int syncedCount, int onlyLocalCount, int onlyRemoteCount, int divergedCount
});




}
/// @nodoc
class _$TagStatsCopyWithImpl<$Res>
    implements $TagStatsCopyWith<$Res> {
  _$TagStatsCopyWithImpl(this._self, this._then);

  final TagStats _self;
  final $Res Function(TagStats) _then;

/// Create a copy of TagStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? localCount = null,Object? remoteCount = null,Object? syncedCount = null,Object? onlyLocalCount = null,Object? onlyRemoteCount = null,Object? divergedCount = null,}) {
  return _then(TagStats(
localCount: null == localCount ? _self.localCount : localCount // ignore: cast_nullable_to_non_nullable
as int,remoteCount: null == remoteCount ? _self.remoteCount : remoteCount // ignore: cast_nullable_to_non_nullable
as int,syncedCount: null == syncedCount ? _self.syncedCount : syncedCount // ignore: cast_nullable_to_non_nullable
as int,onlyLocalCount: null == onlyLocalCount ? _self.onlyLocalCount : onlyLocalCount // ignore: cast_nullable_to_non_nullable
as int,onlyRemoteCount: null == onlyRemoteCount ? _self.onlyRemoteCount : onlyRemoteCount // ignore: cast_nullable_to_non_nullable
as int,divergedCount: null == divergedCount ? _self.divergedCount : divergedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TagStats].
extension TagStatsPatterns on TagStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TagStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TagStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TagStats value)  $default,){
final _that = this;
switch (_that) {
case _TagStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TagStats value)?  $default,){
final _that = this;
switch (_that) {
case _TagStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int localCount,  int remoteCount,  int syncedCount,  int onlyLocalCount,  int onlyRemoteCount,  int divergedCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TagStats() when $default != null:
return $default(_that.localCount,_that.remoteCount,_that.syncedCount,_that.onlyLocalCount,_that.onlyRemoteCount,_that.divergedCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int localCount,  int remoteCount,  int syncedCount,  int onlyLocalCount,  int onlyRemoteCount,  int divergedCount)  $default,) {final _that = this;
switch (_that) {
case _TagStats():
return $default(_that.localCount,_that.remoteCount,_that.syncedCount,_that.onlyLocalCount,_that.onlyRemoteCount,_that.divergedCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int localCount,  int remoteCount,  int syncedCount,  int onlyLocalCount,  int onlyRemoteCount,  int divergedCount)?  $default,) {final _that = this;
switch (_that) {
case _TagStats() when $default != null:
return $default(_that.localCount,_that.remoteCount,_that.syncedCount,_that.onlyLocalCount,_that.onlyRemoteCount,_that.divergedCount);case _:
  return null;

}
}

}

/// @nodoc


class _TagStats implements TagStats {
  const _TagStats({this.localCount = 0, this.remoteCount = 0, this.syncedCount = 0, this.onlyLocalCount = 0, this.onlyRemoteCount = 0, this.divergedCount = 0});
  

@override@JsonKey() final  int localCount;
@override@JsonKey() final  int remoteCount;
@override@JsonKey() final  int syncedCount;
@override@JsonKey() final  int onlyLocalCount;
@override@JsonKey() final  int onlyRemoteCount;
@override@JsonKey() final  int divergedCount;

/// Create a copy of TagStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TagStatsCopyWith<_TagStats> get copyWith => __$TagStatsCopyWithImpl<_TagStats>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TagStats&&(identical(other.localCount, localCount) || other.localCount == localCount)&&(identical(other.remoteCount, remoteCount) || other.remoteCount == remoteCount)&&(identical(other.syncedCount, syncedCount) || other.syncedCount == syncedCount)&&(identical(other.onlyLocalCount, onlyLocalCount) || other.onlyLocalCount == onlyLocalCount)&&(identical(other.onlyRemoteCount, onlyRemoteCount) || other.onlyRemoteCount == onlyRemoteCount)&&(identical(other.divergedCount, divergedCount) || other.divergedCount == divergedCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,localCount,remoteCount,syncedCount,onlyLocalCount,onlyRemoteCount,divergedCount);
}

@override
String toString() {
    return 'TagStats(localCount: $localCount, remoteCount: $remoteCount, syncedCount: $syncedCount, onlyLocalCount: $onlyLocalCount, onlyRemoteCount: $onlyRemoteCount, divergedCount: $divergedCount)';
}


}

/// @nodoc
abstract mixin class _$TagStatsCopyWith<$Res> implements $TagStatsCopyWith<$Res> {
  factory _$TagStatsCopyWith(_TagStats value, $Res Function(_TagStats) _then) = __$TagStatsCopyWithImpl;
@override @useResult
$Res call({
 int localCount, int remoteCount, int syncedCount, int onlyLocalCount, int onlyRemoteCount, int divergedCount
});




}
/// @nodoc
class __$TagStatsCopyWithImpl<$Res>
    implements _$TagStatsCopyWith<$Res> {
  __$TagStatsCopyWithImpl(this._self, this._then);

  final _TagStats _self;
  final $Res Function(_TagStats) _then;

/// Create a copy of TagStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? localCount = null,Object? remoteCount = null,Object? syncedCount = null,Object? onlyLocalCount = null,Object? onlyRemoteCount = null,Object? divergedCount = null,}) {
  return _then(_TagStats(
localCount: null == localCount ? _self.localCount : localCount // ignore: cast_nullable_to_non_nullable
as int,remoteCount: null == remoteCount ? _self.remoteCount : remoteCount // ignore: cast_nullable_to_non_nullable
as int,syncedCount: null == syncedCount ? _self.syncedCount : syncedCount // ignore: cast_nullable_to_non_nullable
as int,onlyLocalCount: null == onlyLocalCount ? _self.onlyLocalCount : onlyLocalCount // ignore: cast_nullable_to_non_nullable
as int,onlyRemoteCount: null == onlyRemoteCount ? _self.onlyRemoteCount : onlyRemoteCount // ignore: cast_nullable_to_non_nullable
as int,divergedCount: null == divergedCount ? _self.divergedCount : divergedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
