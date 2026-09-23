// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'git_commit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GitCommit {

 String get sha; List<String> get parents; String? get author; String? get date; String? get refs; List<String> get tags; String? get subject; String? get body; List<SubmoduleChange> get submoduleChanges;
/// Create a copy of GitCommit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitCommitCopyWith<GitCommit> get copyWith => _$GitCommitCopyWithImpl<GitCommit>(this as GitCommit, _$identity);

  /// Serializes this GitCommit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GitCommit;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitCommit&&(identical(other.sha, _this.sha) || other.sha == _this.sha)&&const DeepCollectionEquality().equals(other.parents, _this.parents)&&(identical(other.author, _this.author) || other.author == _this.author)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.refs, _this.refs) || other.refs == _this.refs)&&const DeepCollectionEquality().equals(other.tags, _this.tags)&&(identical(other.subject, _this.subject) || other.subject == _this.subject)&&(identical(other.body, _this.body) || other.body == _this.body)&&const DeepCollectionEquality().equals(other.submoduleChanges, _this.submoduleChanges));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GitCommit;
  return Object.hash(runtimeType,_this.sha,const DeepCollectionEquality().hash(_this.parents),_this.author,_this.date,_this.refs,const DeepCollectionEquality().hash(_this.tags),_this.subject,_this.body,const DeepCollectionEquality().hash(_this.submoduleChanges));
}

@override
String toString() {
  final _this = this as GitCommit;
  return 'GitCommit(sha: ${_this.sha}, parents: ${_this.parents}, author: ${_this.author}, date: ${_this.date}, refs: ${_this.refs}, tags: ${_this.tags}, subject: ${_this.subject}, body: ${_this.body}, submoduleChanges: ${_this.submoduleChanges})';
}


}

/// @nodoc
abstract mixin class $GitCommitCopyWith<$Res>  {
  factory $GitCommitCopyWith(GitCommit value, $Res Function(GitCommit) _then) = _$GitCommitCopyWithImpl;
@useResult
$Res call({
 String sha, List<String> parents, String? author, String? date, String? refs, List<String> tags, String? subject, String? body, List<SubmoduleChange> submoduleChanges
});




}
/// @nodoc
class _$GitCommitCopyWithImpl<$Res>
    implements $GitCommitCopyWith<$Res> {
  _$GitCommitCopyWithImpl(this._self, this._then);

  final GitCommit _self;
  final $Res Function(GitCommit) _then;

/// Create a copy of GitCommit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sha = null,Object? parents = null,Object? author = freezed,Object? date = freezed,Object? refs = freezed,Object? tags = null,Object? subject = freezed,Object? body = freezed,Object? submoduleChanges = null,}) {
  return _then(GitCommit(
sha: null == sha ? _self.sha : sha // ignore: cast_nullable_to_non_nullable
as String,parents: null == parents ? _self.parents : parents // ignore: cast_nullable_to_non_nullable
as List<String>,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,refs: freezed == refs ? _self.refs : refs // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,subject: freezed == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,submoduleChanges: null == submoduleChanges ? _self.submoduleChanges : submoduleChanges // ignore: cast_nullable_to_non_nullable
as List<SubmoduleChange>,
  ));
}

}


/// Adds pattern-matching-related methods to [GitCommit].
extension GitCommitPatterns on GitCommit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitCommit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitCommit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitCommit value)  $default,){
final _that = this;
switch (_that) {
case _GitCommit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitCommit value)?  $default,){
final _that = this;
switch (_that) {
case _GitCommit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sha,  List<String> parents,  String? author,  String? date,  String? refs,  List<String> tags,  String? subject,  String? body,  List<SubmoduleChange> submoduleChanges)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitCommit() when $default != null:
return $default(_that.sha,_that.parents,_that.author,_that.date,_that.refs,_that.tags,_that.subject,_that.body,_that.submoduleChanges);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sha,  List<String> parents,  String? author,  String? date,  String? refs,  List<String> tags,  String? subject,  String? body,  List<SubmoduleChange> submoduleChanges)  $default,) {final _that = this;
switch (_that) {
case _GitCommit():
return $default(_that.sha,_that.parents,_that.author,_that.date,_that.refs,_that.tags,_that.subject,_that.body,_that.submoduleChanges);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sha,  List<String> parents,  String? author,  String? date,  String? refs,  List<String> tags,  String? subject,  String? body,  List<SubmoduleChange> submoduleChanges)?  $default,) {final _that = this;
switch (_that) {
case _GitCommit() when $default != null:
return $default(_that.sha,_that.parents,_that.author,_that.date,_that.refs,_that.tags,_that.subject,_that.body,_that.submoduleChanges);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GitCommit implements GitCommit {
  const _GitCommit({required this.sha,  List<String> parents = const [], this.author, this.date, this.refs,  List<String> tags = const [], this.subject, this.body,  List<SubmoduleChange> submoduleChanges = const []}): _parents = parents,_tags = tags,_submoduleChanges = submoduleChanges;
  factory _GitCommit.fromJson(Map<String, dynamic> json) => _$GitCommitFromJson(json);

@override final  String sha;
 final  List<String> _parents;
@override@JsonKey() List<String> get parents {
  if (_parents is EqualUnmodifiableListView) return _parents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_parents);
}

@override final  String? author;
@override final  String? date;
@override final  String? refs;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override final  String? subject;
@override final  String? body;
 final  List<SubmoduleChange> _submoduleChanges;
@override@JsonKey() List<SubmoduleChange> get submoduleChanges {
  if (_submoduleChanges is EqualUnmodifiableListView) return _submoduleChanges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_submoduleChanges);
}


/// Create a copy of GitCommit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitCommitCopyWith<_GitCommit> get copyWith => __$GitCommitCopyWithImpl<_GitCommit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GitCommitToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitCommit&&(identical(other.sha, sha) || other.sha == sha)&&const DeepCollectionEquality().equals(other.parents, _parents)&&(identical(other.author, author) || other.author == author)&&(identical(other.date, date) || other.date == date)&&(identical(other.refs, refs) || other.refs == refs)&&const DeepCollectionEquality().equals(other.tags, _tags)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.body, body) || other.body == body)&&const DeepCollectionEquality().equals(other.submoduleChanges, _submoduleChanges));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,sha,const DeepCollectionEquality().hash(_parents),author,date,refs,const DeepCollectionEquality().hash(_tags),subject,body,const DeepCollectionEquality().hash(_submoduleChanges));
}

@override
String toString() {
    return 'GitCommit(sha: $sha, parents: $parents, author: $author, date: $date, refs: $refs, tags: $tags, subject: $subject, body: $body, submoduleChanges: $submoduleChanges)';
}


}

/// @nodoc
abstract mixin class _$GitCommitCopyWith<$Res> implements $GitCommitCopyWith<$Res> {
  factory _$GitCommitCopyWith(_GitCommit value, $Res Function(_GitCommit) _then) = __$GitCommitCopyWithImpl;
@override @useResult
$Res call({
 String sha, List<String> parents, String? author, String? date, String? refs, List<String> tags, String? subject, String? body, List<SubmoduleChange> submoduleChanges
});




}
/// @nodoc
class __$GitCommitCopyWithImpl<$Res>
    implements _$GitCommitCopyWith<$Res> {
  __$GitCommitCopyWithImpl(this._self, this._then);

  final _GitCommit _self;
  final $Res Function(_GitCommit) _then;

/// Create a copy of GitCommit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sha = null,Object? parents = null,Object? author = freezed,Object? date = freezed,Object? refs = freezed,Object? tags = null,Object? subject = freezed,Object? body = freezed,Object? submoduleChanges = null,}) {
  return _then(_GitCommit(
sha: null == sha ? _self.sha : sha // ignore: cast_nullable_to_non_nullable
as String,parents: null == parents ? _self._parents : parents // ignore: cast_nullable_to_non_nullable
as List<String>,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,refs: freezed == refs ? _self.refs : refs // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,subject: freezed == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,submoduleChanges: null == submoduleChanges ? _self._submoduleChanges : submoduleChanges // ignore: cast_nullable_to_non_nullable
as List<SubmoduleChange>,
  ));
}


}


/// @nodoc
mixin _$GitBranch {

 String get name; bool get isCurrent;
/// Create a copy of GitBranch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitBranchCopyWith<GitBranch> get copyWith => _$GitBranchCopyWithImpl<GitBranch>(this as GitBranch, _$identity);

  /// Serializes this GitBranch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GitBranch;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitBranch&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.isCurrent, _this.isCurrent) || other.isCurrent == _this.isCurrent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GitBranch;
  return Object.hash(runtimeType,_this.name,_this.isCurrent);
}

@override
String toString() {
  final _this = this as GitBranch;
  return 'GitBranch(name: ${_this.name}, isCurrent: ${_this.isCurrent})';
}


}

/// @nodoc
abstract mixin class $GitBranchCopyWith<$Res>  {
  factory $GitBranchCopyWith(GitBranch value, $Res Function(GitBranch) _then) = _$GitBranchCopyWithImpl;
@useResult
$Res call({
 String name, bool isCurrent
});




}
/// @nodoc
class _$GitBranchCopyWithImpl<$Res>
    implements $GitBranchCopyWith<$Res> {
  _$GitBranchCopyWithImpl(this._self, this._then);

  final GitBranch _self;
  final $Res Function(GitBranch) _then;

/// Create a copy of GitBranch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? isCurrent = null,}) {
  return _then(GitBranch(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GitBranch].
extension GitBranchPatterns on GitBranch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitBranch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitBranch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitBranch value)  $default,){
final _that = this;
switch (_that) {
case _GitBranch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitBranch value)?  $default,){
final _that = this;
switch (_that) {
case _GitBranch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  bool isCurrent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitBranch() when $default != null:
return $default(_that.name,_that.isCurrent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  bool isCurrent)  $default,) {final _that = this;
switch (_that) {
case _GitBranch():
return $default(_that.name,_that.isCurrent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  bool isCurrent)?  $default,) {final _that = this;
switch (_that) {
case _GitBranch() when $default != null:
return $default(_that.name,_that.isCurrent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GitBranch implements GitBranch {
  const _GitBranch({required this.name, this.isCurrent = false});
  factory _GitBranch.fromJson(Map<String, dynamic> json) => _$GitBranchFromJson(json);

@override final  String name;
@override@JsonKey() final  bool isCurrent;

/// Create a copy of GitBranch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitBranchCopyWith<_GitBranch> get copyWith => __$GitBranchCopyWithImpl<_GitBranch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GitBranchToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitBranch&&(identical(other.name, name) || other.name == name)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,isCurrent);
}

@override
String toString() {
    return 'GitBranch(name: $name, isCurrent: $isCurrent)';
}


}

/// @nodoc
abstract mixin class _$GitBranchCopyWith<$Res> implements $GitBranchCopyWith<$Res> {
  factory _$GitBranchCopyWith(_GitBranch value, $Res Function(_GitBranch) _then) = __$GitBranchCopyWithImpl;
@override @useResult
$Res call({
 String name, bool isCurrent
});




}
/// @nodoc
class __$GitBranchCopyWithImpl<$Res>
    implements _$GitBranchCopyWith<$Res> {
  __$GitBranchCopyWithImpl(this._self, this._then);

  final _GitBranch _self;
  final $Res Function(_GitBranch) _then;

/// Create a copy of GitBranch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? isCurrent = null,}) {
  return _then(_GitBranch(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$SubmoduleRecord {

 String get sha; String? get author; String? get date; String? get subject; bool get isMerge;
/// Create a copy of SubmoduleRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubmoduleRecordCopyWith<SubmoduleRecord> get copyWith => _$SubmoduleRecordCopyWithImpl<SubmoduleRecord>(this as SubmoduleRecord, _$identity);

  /// Serializes this SubmoduleRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SubmoduleRecord;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubmoduleRecord&&(identical(other.sha, _this.sha) || other.sha == _this.sha)&&(identical(other.author, _this.author) || other.author == _this.author)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.subject, _this.subject) || other.subject == _this.subject)&&(identical(other.isMerge, _this.isMerge) || other.isMerge == _this.isMerge));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SubmoduleRecord;
  return Object.hash(runtimeType,_this.sha,_this.author,_this.date,_this.subject,_this.isMerge);
}

@override
String toString() {
  final _this = this as SubmoduleRecord;
  return 'SubmoduleRecord(sha: ${_this.sha}, author: ${_this.author}, date: ${_this.date}, subject: ${_this.subject}, isMerge: ${_this.isMerge})';
}


}

/// @nodoc
abstract mixin class $SubmoduleRecordCopyWith<$Res>  {
  factory $SubmoduleRecordCopyWith(SubmoduleRecord value, $Res Function(SubmoduleRecord) _then) = _$SubmoduleRecordCopyWithImpl;
@useResult
$Res call({
 String sha, String? author, String? date, String? subject, bool isMerge
});




}
/// @nodoc
class _$SubmoduleRecordCopyWithImpl<$Res>
    implements $SubmoduleRecordCopyWith<$Res> {
  _$SubmoduleRecordCopyWithImpl(this._self, this._then);

  final SubmoduleRecord _self;
  final $Res Function(SubmoduleRecord) _then;

/// Create a copy of SubmoduleRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sha = null,Object? author = freezed,Object? date = freezed,Object? subject = freezed,Object? isMerge = null,}) {
  return _then(SubmoduleRecord(
sha: null == sha ? _self.sha : sha // ignore: cast_nullable_to_non_nullable
as String,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,subject: freezed == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String?,isMerge: null == isMerge ? _self.isMerge : isMerge // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SubmoduleRecord].
extension SubmoduleRecordPatterns on SubmoduleRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubmoduleRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubmoduleRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubmoduleRecord value)  $default,){
final _that = this;
switch (_that) {
case _SubmoduleRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubmoduleRecord value)?  $default,){
final _that = this;
switch (_that) {
case _SubmoduleRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sha,  String? author,  String? date,  String? subject,  bool isMerge)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubmoduleRecord() when $default != null:
return $default(_that.sha,_that.author,_that.date,_that.subject,_that.isMerge);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sha,  String? author,  String? date,  String? subject,  bool isMerge)  $default,) {final _that = this;
switch (_that) {
case _SubmoduleRecord():
return $default(_that.sha,_that.author,_that.date,_that.subject,_that.isMerge);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sha,  String? author,  String? date,  String? subject,  bool isMerge)?  $default,) {final _that = this;
switch (_that) {
case _SubmoduleRecord() when $default != null:
return $default(_that.sha,_that.author,_that.date,_that.subject,_that.isMerge);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubmoduleRecord implements SubmoduleRecord {
  const _SubmoduleRecord({required this.sha, this.author, this.date, this.subject, this.isMerge = false});
  factory _SubmoduleRecord.fromJson(Map<String, dynamic> json) => _$SubmoduleRecordFromJson(json);

@override final  String sha;
@override final  String? author;
@override final  String? date;
@override final  String? subject;
@override@JsonKey() final  bool isMerge;

/// Create a copy of SubmoduleRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubmoduleRecordCopyWith<_SubmoduleRecord> get copyWith => __$SubmoduleRecordCopyWithImpl<_SubmoduleRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubmoduleRecordToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubmoduleRecord&&(identical(other.sha, sha) || other.sha == sha)&&(identical(other.author, author) || other.author == author)&&(identical(other.date, date) || other.date == date)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.isMerge, isMerge) || other.isMerge == isMerge));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,sha,author,date,subject,isMerge);
}

@override
String toString() {
    return 'SubmoduleRecord(sha: $sha, author: $author, date: $date, subject: $subject, isMerge: $isMerge)';
}


}

/// @nodoc
abstract mixin class _$SubmoduleRecordCopyWith<$Res> implements $SubmoduleRecordCopyWith<$Res> {
  factory _$SubmoduleRecordCopyWith(_SubmoduleRecord value, $Res Function(_SubmoduleRecord) _then) = __$SubmoduleRecordCopyWithImpl;
@override @useResult
$Res call({
 String sha, String? author, String? date, String? subject, bool isMerge
});




}
/// @nodoc
class __$SubmoduleRecordCopyWithImpl<$Res>
    implements _$SubmoduleRecordCopyWith<$Res> {
  __$SubmoduleRecordCopyWithImpl(this._self, this._then);

  final _SubmoduleRecord _self;
  final $Res Function(_SubmoduleRecord) _then;

/// Create a copy of SubmoduleRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sha = null,Object? author = freezed,Object? date = freezed,Object? subject = freezed,Object? isMerge = null,}) {
  return _then(_SubmoduleRecord(
sha: null == sha ? _self.sha : sha // ignore: cast_nullable_to_non_nullable
as String,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,subject: freezed == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String?,isMerge: null == isMerge ? _self.isMerge : isMerge // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$SubmoduleChange {

 String get path; String? get oldSha; String? get newSha; String? get oldAuthor; String? get oldDate; String? get oldSubject; String? get newAuthor; String? get newDate; String? get newSubject; SubmoduleRecord? get recordedBy; SubmoduleRecord? get actualSwitchBy; bool get resolvedInMerge; bool get silentlyDropped; String? get droppedSha; String? get droppedFromParent;
/// Create a copy of SubmoduleChange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubmoduleChangeCopyWith<SubmoduleChange> get copyWith => _$SubmoduleChangeCopyWithImpl<SubmoduleChange>(this as SubmoduleChange, _$identity);

  /// Serializes this SubmoduleChange to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SubmoduleChange;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubmoduleChange&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.oldSha, _this.oldSha) || other.oldSha == _this.oldSha)&&(identical(other.newSha, _this.newSha) || other.newSha == _this.newSha)&&(identical(other.oldAuthor, _this.oldAuthor) || other.oldAuthor == _this.oldAuthor)&&(identical(other.oldDate, _this.oldDate) || other.oldDate == _this.oldDate)&&(identical(other.oldSubject, _this.oldSubject) || other.oldSubject == _this.oldSubject)&&(identical(other.newAuthor, _this.newAuthor) || other.newAuthor == _this.newAuthor)&&(identical(other.newDate, _this.newDate) || other.newDate == _this.newDate)&&(identical(other.newSubject, _this.newSubject) || other.newSubject == _this.newSubject)&&(identical(other.recordedBy, _this.recordedBy) || other.recordedBy == _this.recordedBy)&&(identical(other.actualSwitchBy, _this.actualSwitchBy) || other.actualSwitchBy == _this.actualSwitchBy)&&(identical(other.resolvedInMerge, _this.resolvedInMerge) || other.resolvedInMerge == _this.resolvedInMerge)&&(identical(other.silentlyDropped, _this.silentlyDropped) || other.silentlyDropped == _this.silentlyDropped)&&(identical(other.droppedSha, _this.droppedSha) || other.droppedSha == _this.droppedSha)&&(identical(other.droppedFromParent, _this.droppedFromParent) || other.droppedFromParent == _this.droppedFromParent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SubmoduleChange;
  return Object.hash(runtimeType,_this.path,_this.oldSha,_this.newSha,_this.oldAuthor,_this.oldDate,_this.oldSubject,_this.newAuthor,_this.newDate,_this.newSubject,_this.recordedBy,_this.actualSwitchBy,_this.resolvedInMerge,_this.silentlyDropped,_this.droppedSha,_this.droppedFromParent);
}

@override
String toString() {
  final _this = this as SubmoduleChange;
  return 'SubmoduleChange(path: ${_this.path}, oldSha: ${_this.oldSha}, newSha: ${_this.newSha}, oldAuthor: ${_this.oldAuthor}, oldDate: ${_this.oldDate}, oldSubject: ${_this.oldSubject}, newAuthor: ${_this.newAuthor}, newDate: ${_this.newDate}, newSubject: ${_this.newSubject}, recordedBy: ${_this.recordedBy}, actualSwitchBy: ${_this.actualSwitchBy}, resolvedInMerge: ${_this.resolvedInMerge}, silentlyDropped: ${_this.silentlyDropped}, droppedSha: ${_this.droppedSha}, droppedFromParent: ${_this.droppedFromParent})';
}


}

/// @nodoc
abstract mixin class $SubmoduleChangeCopyWith<$Res>  {
  factory $SubmoduleChangeCopyWith(SubmoduleChange value, $Res Function(SubmoduleChange) _then) = _$SubmoduleChangeCopyWithImpl;
@useResult
$Res call({
 String path, String? oldSha, String? newSha, String? oldAuthor, String? oldDate, String? oldSubject, String? newAuthor, String? newDate, String? newSubject, SubmoduleRecord? recordedBy, SubmoduleRecord? actualSwitchBy, bool resolvedInMerge, bool silentlyDropped, String? droppedSha, String? droppedFromParent
});


$SubmoduleRecordCopyWith<$Res>? get recordedBy;$SubmoduleRecordCopyWith<$Res>? get actualSwitchBy;

}
/// @nodoc
class _$SubmoduleChangeCopyWithImpl<$Res>
    implements $SubmoduleChangeCopyWith<$Res> {
  _$SubmoduleChangeCopyWithImpl(this._self, this._then);

  final SubmoduleChange _self;
  final $Res Function(SubmoduleChange) _then;

/// Create a copy of SubmoduleChange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? oldSha = freezed,Object? newSha = freezed,Object? oldAuthor = freezed,Object? oldDate = freezed,Object? oldSubject = freezed,Object? newAuthor = freezed,Object? newDate = freezed,Object? newSubject = freezed,Object? recordedBy = freezed,Object? actualSwitchBy = freezed,Object? resolvedInMerge = null,Object? silentlyDropped = null,Object? droppedSha = freezed,Object? droppedFromParent = freezed,}) {
  return _then(SubmoduleChange(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,oldSha: freezed == oldSha ? _self.oldSha : oldSha // ignore: cast_nullable_to_non_nullable
as String?,newSha: freezed == newSha ? _self.newSha : newSha // ignore: cast_nullable_to_non_nullable
as String?,oldAuthor: freezed == oldAuthor ? _self.oldAuthor : oldAuthor // ignore: cast_nullable_to_non_nullable
as String?,oldDate: freezed == oldDate ? _self.oldDate : oldDate // ignore: cast_nullable_to_non_nullable
as String?,oldSubject: freezed == oldSubject ? _self.oldSubject : oldSubject // ignore: cast_nullable_to_non_nullable
as String?,newAuthor: freezed == newAuthor ? _self.newAuthor : newAuthor // ignore: cast_nullable_to_non_nullable
as String?,newDate: freezed == newDate ? _self.newDate : newDate // ignore: cast_nullable_to_non_nullable
as String?,newSubject: freezed == newSubject ? _self.newSubject : newSubject // ignore: cast_nullable_to_non_nullable
as String?,recordedBy: freezed == recordedBy ? _self.recordedBy : recordedBy // ignore: cast_nullable_to_non_nullable
as SubmoduleRecord?,actualSwitchBy: freezed == actualSwitchBy ? _self.actualSwitchBy : actualSwitchBy // ignore: cast_nullable_to_non_nullable
as SubmoduleRecord?,resolvedInMerge: null == resolvedInMerge ? _self.resolvedInMerge : resolvedInMerge // ignore: cast_nullable_to_non_nullable
as bool,silentlyDropped: null == silentlyDropped ? _self.silentlyDropped : silentlyDropped // ignore: cast_nullable_to_non_nullable
as bool,droppedSha: freezed == droppedSha ? _self.droppedSha : droppedSha // ignore: cast_nullable_to_non_nullable
as String?,droppedFromParent: freezed == droppedFromParent ? _self.droppedFromParent : droppedFromParent // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of SubmoduleChange
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubmoduleRecordCopyWith<$Res>? get recordedBy {
    if (_self.recordedBy == null) {
    return null;
  }

  return $SubmoduleRecordCopyWith<$Res>(_self.recordedBy!, (value) {
    return _then(_self.copyWith(recordedBy: value));
  });
}/// Create a copy of SubmoduleChange
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubmoduleRecordCopyWith<$Res>? get actualSwitchBy {
    if (_self.actualSwitchBy == null) {
    return null;
  }

  return $SubmoduleRecordCopyWith<$Res>(_self.actualSwitchBy!, (value) {
    return _then(_self.copyWith(actualSwitchBy: value));
  });
}
}


/// Adds pattern-matching-related methods to [SubmoduleChange].
extension SubmoduleChangePatterns on SubmoduleChange {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubmoduleChange value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubmoduleChange() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubmoduleChange value)  $default,){
final _that = this;
switch (_that) {
case _SubmoduleChange():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubmoduleChange value)?  $default,){
final _that = this;
switch (_that) {
case _SubmoduleChange() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  String? oldSha,  String? newSha,  String? oldAuthor,  String? oldDate,  String? oldSubject,  String? newAuthor,  String? newDate,  String? newSubject,  SubmoduleRecord? recordedBy,  SubmoduleRecord? actualSwitchBy,  bool resolvedInMerge,  bool silentlyDropped,  String? droppedSha,  String? droppedFromParent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubmoduleChange() when $default != null:
return $default(_that.path,_that.oldSha,_that.newSha,_that.oldAuthor,_that.oldDate,_that.oldSubject,_that.newAuthor,_that.newDate,_that.newSubject,_that.recordedBy,_that.actualSwitchBy,_that.resolvedInMerge,_that.silentlyDropped,_that.droppedSha,_that.droppedFromParent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  String? oldSha,  String? newSha,  String? oldAuthor,  String? oldDate,  String? oldSubject,  String? newAuthor,  String? newDate,  String? newSubject,  SubmoduleRecord? recordedBy,  SubmoduleRecord? actualSwitchBy,  bool resolvedInMerge,  bool silentlyDropped,  String? droppedSha,  String? droppedFromParent)  $default,) {final _that = this;
switch (_that) {
case _SubmoduleChange():
return $default(_that.path,_that.oldSha,_that.newSha,_that.oldAuthor,_that.oldDate,_that.oldSubject,_that.newAuthor,_that.newDate,_that.newSubject,_that.recordedBy,_that.actualSwitchBy,_that.resolvedInMerge,_that.silentlyDropped,_that.droppedSha,_that.droppedFromParent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  String? oldSha,  String? newSha,  String? oldAuthor,  String? oldDate,  String? oldSubject,  String? newAuthor,  String? newDate,  String? newSubject,  SubmoduleRecord? recordedBy,  SubmoduleRecord? actualSwitchBy,  bool resolvedInMerge,  bool silentlyDropped,  String? droppedSha,  String? droppedFromParent)?  $default,) {final _that = this;
switch (_that) {
case _SubmoduleChange() when $default != null:
return $default(_that.path,_that.oldSha,_that.newSha,_that.oldAuthor,_that.oldDate,_that.oldSubject,_that.newAuthor,_that.newDate,_that.newSubject,_that.recordedBy,_that.actualSwitchBy,_that.resolvedInMerge,_that.silentlyDropped,_that.droppedSha,_that.droppedFromParent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubmoduleChange implements SubmoduleChange {
  const _SubmoduleChange({required this.path, this.oldSha, this.newSha, this.oldAuthor, this.oldDate, this.oldSubject, this.newAuthor, this.newDate, this.newSubject, this.recordedBy, this.actualSwitchBy, this.resolvedInMerge = false, this.silentlyDropped = false, this.droppedSha, this.droppedFromParent});
  factory _SubmoduleChange.fromJson(Map<String, dynamic> json) => _$SubmoduleChangeFromJson(json);

@override final  String path;
@override final  String? oldSha;
@override final  String? newSha;
@override final  String? oldAuthor;
@override final  String? oldDate;
@override final  String? oldSubject;
@override final  String? newAuthor;
@override final  String? newDate;
@override final  String? newSubject;
@override final  SubmoduleRecord? recordedBy;
@override final  SubmoduleRecord? actualSwitchBy;
@override@JsonKey() final  bool resolvedInMerge;
@override@JsonKey() final  bool silentlyDropped;
@override final  String? droppedSha;
@override final  String? droppedFromParent;

/// Create a copy of SubmoduleChange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubmoduleChangeCopyWith<_SubmoduleChange> get copyWith => __$SubmoduleChangeCopyWithImpl<_SubmoduleChange>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubmoduleChangeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubmoduleChange&&(identical(other.path, path) || other.path == path)&&(identical(other.oldSha, oldSha) || other.oldSha == oldSha)&&(identical(other.newSha, newSha) || other.newSha == newSha)&&(identical(other.oldAuthor, oldAuthor) || other.oldAuthor == oldAuthor)&&(identical(other.oldDate, oldDate) || other.oldDate == oldDate)&&(identical(other.oldSubject, oldSubject) || other.oldSubject == oldSubject)&&(identical(other.newAuthor, newAuthor) || other.newAuthor == newAuthor)&&(identical(other.newDate, newDate) || other.newDate == newDate)&&(identical(other.newSubject, newSubject) || other.newSubject == newSubject)&&(identical(other.recordedBy, recordedBy) || other.recordedBy == recordedBy)&&(identical(other.actualSwitchBy, actualSwitchBy) || other.actualSwitchBy == actualSwitchBy)&&(identical(other.resolvedInMerge, resolvedInMerge) || other.resolvedInMerge == resolvedInMerge)&&(identical(other.silentlyDropped, silentlyDropped) || other.silentlyDropped == silentlyDropped)&&(identical(other.droppedSha, droppedSha) || other.droppedSha == droppedSha)&&(identical(other.droppedFromParent, droppedFromParent) || other.droppedFromParent == droppedFromParent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,path,oldSha,newSha,oldAuthor,oldDate,oldSubject,newAuthor,newDate,newSubject,recordedBy,actualSwitchBy,resolvedInMerge,silentlyDropped,droppedSha,droppedFromParent);
}

@override
String toString() {
    return 'SubmoduleChange(path: $path, oldSha: $oldSha, newSha: $newSha, oldAuthor: $oldAuthor, oldDate: $oldDate, oldSubject: $oldSubject, newAuthor: $newAuthor, newDate: $newDate, newSubject: $newSubject, recordedBy: $recordedBy, actualSwitchBy: $actualSwitchBy, resolvedInMerge: $resolvedInMerge, silentlyDropped: $silentlyDropped, droppedSha: $droppedSha, droppedFromParent: $droppedFromParent)';
}


}

/// @nodoc
abstract mixin class _$SubmoduleChangeCopyWith<$Res> implements $SubmoduleChangeCopyWith<$Res> {
  factory _$SubmoduleChangeCopyWith(_SubmoduleChange value, $Res Function(_SubmoduleChange) _then) = __$SubmoduleChangeCopyWithImpl;
@override @useResult
$Res call({
 String path, String? oldSha, String? newSha, String? oldAuthor, String? oldDate, String? oldSubject, String? newAuthor, String? newDate, String? newSubject, SubmoduleRecord? recordedBy, SubmoduleRecord? actualSwitchBy, bool resolvedInMerge, bool silentlyDropped, String? droppedSha, String? droppedFromParent
});


@override $SubmoduleRecordCopyWith<$Res>? get recordedBy;@override $SubmoduleRecordCopyWith<$Res>? get actualSwitchBy;

}
/// @nodoc
class __$SubmoduleChangeCopyWithImpl<$Res>
    implements _$SubmoduleChangeCopyWith<$Res> {
  __$SubmoduleChangeCopyWithImpl(this._self, this._then);

  final _SubmoduleChange _self;
  final $Res Function(_SubmoduleChange) _then;

/// Create a copy of SubmoduleChange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? oldSha = freezed,Object? newSha = freezed,Object? oldAuthor = freezed,Object? oldDate = freezed,Object? oldSubject = freezed,Object? newAuthor = freezed,Object? newDate = freezed,Object? newSubject = freezed,Object? recordedBy = freezed,Object? actualSwitchBy = freezed,Object? resolvedInMerge = null,Object? silentlyDropped = null,Object? droppedSha = freezed,Object? droppedFromParent = freezed,}) {
  return _then(_SubmoduleChange(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,oldSha: freezed == oldSha ? _self.oldSha : oldSha // ignore: cast_nullable_to_non_nullable
as String?,newSha: freezed == newSha ? _self.newSha : newSha // ignore: cast_nullable_to_non_nullable
as String?,oldAuthor: freezed == oldAuthor ? _self.oldAuthor : oldAuthor // ignore: cast_nullable_to_non_nullable
as String?,oldDate: freezed == oldDate ? _self.oldDate : oldDate // ignore: cast_nullable_to_non_nullable
as String?,oldSubject: freezed == oldSubject ? _self.oldSubject : oldSubject // ignore: cast_nullable_to_non_nullable
as String?,newAuthor: freezed == newAuthor ? _self.newAuthor : newAuthor // ignore: cast_nullable_to_non_nullable
as String?,newDate: freezed == newDate ? _self.newDate : newDate // ignore: cast_nullable_to_non_nullable
as String?,newSubject: freezed == newSubject ? _self.newSubject : newSubject // ignore: cast_nullable_to_non_nullable
as String?,recordedBy: freezed == recordedBy ? _self.recordedBy : recordedBy // ignore: cast_nullable_to_non_nullable
as SubmoduleRecord?,actualSwitchBy: freezed == actualSwitchBy ? _self.actualSwitchBy : actualSwitchBy // ignore: cast_nullable_to_non_nullable
as SubmoduleRecord?,resolvedInMerge: null == resolvedInMerge ? _self.resolvedInMerge : resolvedInMerge // ignore: cast_nullable_to_non_nullable
as bool,silentlyDropped: null == silentlyDropped ? _self.silentlyDropped : silentlyDropped // ignore: cast_nullable_to_non_nullable
as bool,droppedSha: freezed == droppedSha ? _self.droppedSha : droppedSha // ignore: cast_nullable_to_non_nullable
as String?,droppedFromParent: freezed == droppedFromParent ? _self.droppedFromParent : droppedFromParent // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of SubmoduleChange
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubmoduleRecordCopyWith<$Res>? get recordedBy {
    if (_self.recordedBy == null) {
    return null;
  }

  return $SubmoduleRecordCopyWith<$Res>(_self.recordedBy!, (value) {
    return _then(_self.copyWith(recordedBy: value));
  });
}/// Create a copy of SubmoduleChange
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubmoduleRecordCopyWith<$Res>? get actualSwitchBy {
    if (_self.actualSwitchBy == null) {
    return null;
  }

  return $SubmoduleRecordCopyWith<$Res>(_self.actualSwitchBy!, (value) {
    return _then(_self.copyWith(actualSwitchBy: value));
  });
}
}


/// @nodoc
mixin _$GitSubmodule {

 String get path; String? get sha; String? get branch; SubmoduleStatus get status;
/// Create a copy of GitSubmodule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitSubmoduleCopyWith<GitSubmodule> get copyWith => _$GitSubmoduleCopyWithImpl<GitSubmodule>(this as GitSubmodule, _$identity);

  /// Serializes this GitSubmodule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GitSubmodule;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitSubmodule&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.sha, _this.sha) || other.sha == _this.sha)&&(identical(other.branch, _this.branch) || other.branch == _this.branch)&&(identical(other.status, _this.status) || other.status == _this.status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GitSubmodule;
  return Object.hash(runtimeType,_this.path,_this.sha,_this.branch,_this.status);
}

@override
String toString() {
  final _this = this as GitSubmodule;
  return 'GitSubmodule(path: ${_this.path}, sha: ${_this.sha}, branch: ${_this.branch}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $GitSubmoduleCopyWith<$Res>  {
  factory $GitSubmoduleCopyWith(GitSubmodule value, $Res Function(GitSubmodule) _then) = _$GitSubmoduleCopyWithImpl;
@useResult
$Res call({
 String path, String? sha, String? branch, SubmoduleStatus status
});




}
/// @nodoc
class _$GitSubmoduleCopyWithImpl<$Res>
    implements $GitSubmoduleCopyWith<$Res> {
  _$GitSubmoduleCopyWithImpl(this._self, this._then);

  final GitSubmodule _self;
  final $Res Function(GitSubmodule) _then;

/// Create a copy of GitSubmodule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? sha = freezed,Object? branch = freezed,Object? status = null,}) {
  return _then(GitSubmodule(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,sha: freezed == sha ? _self.sha : sha // ignore: cast_nullable_to_non_nullable
as String?,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SubmoduleStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [GitSubmodule].
extension GitSubmodulePatterns on GitSubmodule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitSubmodule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitSubmodule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitSubmodule value)  $default,){
final _that = this;
switch (_that) {
case _GitSubmodule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitSubmodule value)?  $default,){
final _that = this;
switch (_that) {
case _GitSubmodule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  String? sha,  String? branch,  SubmoduleStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitSubmodule() when $default != null:
return $default(_that.path,_that.sha,_that.branch,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  String? sha,  String? branch,  SubmoduleStatus status)  $default,) {final _that = this;
switch (_that) {
case _GitSubmodule():
return $default(_that.path,_that.sha,_that.branch,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  String? sha,  String? branch,  SubmoduleStatus status)?  $default,) {final _that = this;
switch (_that) {
case _GitSubmodule() when $default != null:
return $default(_that.path,_that.sha,_that.branch,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GitSubmodule implements GitSubmodule {
  const _GitSubmodule({required this.path, this.sha, this.branch, this.status = SubmoduleStatus.ok});
  factory _GitSubmodule.fromJson(Map<String, dynamic> json) => _$GitSubmoduleFromJson(json);

@override final  String path;
@override final  String? sha;
@override final  String? branch;
@override@JsonKey() final  SubmoduleStatus status;

/// Create a copy of GitSubmodule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitSubmoduleCopyWith<_GitSubmodule> get copyWith => __$GitSubmoduleCopyWithImpl<_GitSubmodule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GitSubmoduleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitSubmodule&&(identical(other.path, path) || other.path == path)&&(identical(other.sha, sha) || other.sha == sha)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,path,sha,branch,status);
}

@override
String toString() {
    return 'GitSubmodule(path: $path, sha: $sha, branch: $branch, status: $status)';
}


}

/// @nodoc
abstract mixin class _$GitSubmoduleCopyWith<$Res> implements $GitSubmoduleCopyWith<$Res> {
  factory _$GitSubmoduleCopyWith(_GitSubmodule value, $Res Function(_GitSubmodule) _then) = __$GitSubmoduleCopyWithImpl;
@override @useResult
$Res call({
 String path, String? sha, String? branch, SubmoduleStatus status
});




}
/// @nodoc
class __$GitSubmoduleCopyWithImpl<$Res>
    implements _$GitSubmoduleCopyWith<$Res> {
  __$GitSubmoduleCopyWithImpl(this._self, this._then);

  final _GitSubmodule _self;
  final $Res Function(_GitSubmodule) _then;

/// Create a copy of GitSubmodule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? sha = freezed,Object? branch = freezed,Object? status = null,}) {
  return _then(_GitSubmodule(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,sha: freezed == sha ? _self.sha : sha // ignore: cast_nullable_to_non_nullable
as String?,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SubmoduleStatus,
  ));
}


}

// dart format on
