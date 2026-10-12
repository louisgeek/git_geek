// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'commits_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CommitsState {

 List<GitCommit> get commits; List<GitBranch> get branches; List<GitSubmodule> get submodules; Map<String, String> get submoduleBranches; String get remoteUrl;/// 当前分支（'' = 当前 HEAD）
 String get branch; String get commitLimit; String get commitQuery; bool get newestFirst; bool get isLoadingCommits; bool get isLoadingBranches; bool get isLoadingSubmodules; bool get isCloning; String get cloningInfo; String? get commitError; String? get branchError; String? get submoduleError; String get lastRefreshInfo;/// 子模块范围（'' = 主仓库）；与 controller 的 selectedScope 同步。
 String get scope;/// remote 名（与 controller 的 remote 同步，用于 fetchRemoteUrl）。
 String get remoteName;/// 各子模块最近提交（参照面板用），key = 子模块 path。
 Map<String, List<GitCommit>> get submoduleLogs; bool get isLoadingSubmoduleLogs;
/// Create a copy of CommitsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommitsStateCopyWith<CommitsState> get copyWith => _$CommitsStateCopyWithImpl<CommitsState>(this as CommitsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CommitsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommitsState&&const DeepCollectionEquality().equals(other.commits, _this.commits)&&const DeepCollectionEquality().equals(other.branches, _this.branches)&&const DeepCollectionEquality().equals(other.submodules, _this.submodules)&&const DeepCollectionEquality().equals(other.submoduleBranches, _this.submoduleBranches)&&(identical(other.remoteUrl, _this.remoteUrl) || other.remoteUrl == _this.remoteUrl)&&(identical(other.branch, _this.branch) || other.branch == _this.branch)&&(identical(other.commitLimit, _this.commitLimit) || other.commitLimit == _this.commitLimit)&&(identical(other.commitQuery, _this.commitQuery) || other.commitQuery == _this.commitQuery)&&(identical(other.newestFirst, _this.newestFirst) || other.newestFirst == _this.newestFirst)&&(identical(other.isLoadingCommits, _this.isLoadingCommits) || other.isLoadingCommits == _this.isLoadingCommits)&&(identical(other.isLoadingBranches, _this.isLoadingBranches) || other.isLoadingBranches == _this.isLoadingBranches)&&(identical(other.isLoadingSubmodules, _this.isLoadingSubmodules) || other.isLoadingSubmodules == _this.isLoadingSubmodules)&&(identical(other.isCloning, _this.isCloning) || other.isCloning == _this.isCloning)&&(identical(other.cloningInfo, _this.cloningInfo) || other.cloningInfo == _this.cloningInfo)&&(identical(other.commitError, _this.commitError) || other.commitError == _this.commitError)&&(identical(other.branchError, _this.branchError) || other.branchError == _this.branchError)&&(identical(other.submoduleError, _this.submoduleError) || other.submoduleError == _this.submoduleError)&&(identical(other.lastRefreshInfo, _this.lastRefreshInfo) || other.lastRefreshInfo == _this.lastRefreshInfo)&&(identical(other.scope, _this.scope) || other.scope == _this.scope)&&(identical(other.remoteName, _this.remoteName) || other.remoteName == _this.remoteName)&&const DeepCollectionEquality().equals(other.submoduleLogs, _this.submoduleLogs)&&(identical(other.isLoadingSubmoduleLogs, _this.isLoadingSubmoduleLogs) || other.isLoadingSubmoduleLogs == _this.isLoadingSubmoduleLogs));
}


@override
int get hashCode {
  final _this = this as CommitsState;
  return Object.hashAll([runtimeType,const DeepCollectionEquality().hash(_this.commits),const DeepCollectionEquality().hash(_this.branches),const DeepCollectionEquality().hash(_this.submodules),const DeepCollectionEquality().hash(_this.submoduleBranches),_this.remoteUrl,_this.branch,_this.commitLimit,_this.commitQuery,_this.newestFirst,_this.isLoadingCommits,_this.isLoadingBranches,_this.isLoadingSubmodules,_this.isCloning,_this.cloningInfo,_this.commitError,_this.branchError,_this.submoduleError,_this.lastRefreshInfo,_this.scope,_this.remoteName,const DeepCollectionEquality().hash(_this.submoduleLogs),_this.isLoadingSubmoduleLogs]);
}

@override
String toString() {
  final _this = this as CommitsState;
  return 'CommitsState(commits: ${_this.commits}, branches: ${_this.branches}, submodules: ${_this.submodules}, submoduleBranches: ${_this.submoduleBranches}, remoteUrl: ${_this.remoteUrl}, branch: ${_this.branch}, commitLimit: ${_this.commitLimit}, commitQuery: ${_this.commitQuery}, newestFirst: ${_this.newestFirst}, isLoadingCommits: ${_this.isLoadingCommits}, isLoadingBranches: ${_this.isLoadingBranches}, isLoadingSubmodules: ${_this.isLoadingSubmodules}, isCloning: ${_this.isCloning}, cloningInfo: ${_this.cloningInfo}, commitError: ${_this.commitError}, branchError: ${_this.branchError}, submoduleError: ${_this.submoduleError}, lastRefreshInfo: ${_this.lastRefreshInfo}, scope: ${_this.scope}, remoteName: ${_this.remoteName}, submoduleLogs: ${_this.submoduleLogs}, isLoadingSubmoduleLogs: ${_this.isLoadingSubmoduleLogs})';
}


}

/// @nodoc
abstract mixin class $CommitsStateCopyWith<$Res>  {
  factory $CommitsStateCopyWith(CommitsState value, $Res Function(CommitsState) _then) = _$CommitsStateCopyWithImpl;
@useResult
$Res call({
 List<GitCommit> commits, List<GitBranch> branches, List<GitSubmodule> submodules, Map<String, String> submoduleBranches, String remoteUrl, String branch, String commitLimit, String commitQuery, bool newestFirst, bool isLoadingCommits, bool isLoadingBranches, bool isLoadingSubmodules, bool isCloning, String cloningInfo, String? commitError, String? branchError, String? submoduleError, String lastRefreshInfo, String scope, String remoteName, Map<String, List<GitCommit>> submoduleLogs, bool isLoadingSubmoduleLogs
});




}
/// @nodoc
class _$CommitsStateCopyWithImpl<$Res>
    implements $CommitsStateCopyWith<$Res> {
  _$CommitsStateCopyWithImpl(this._self, this._then);

  final CommitsState _self;
  final $Res Function(CommitsState) _then;

/// Create a copy of CommitsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? commits = null,Object? branches = null,Object? submodules = null,Object? submoduleBranches = null,Object? remoteUrl = null,Object? branch = null,Object? commitLimit = null,Object? commitQuery = null,Object? newestFirst = null,Object? isLoadingCommits = null,Object? isLoadingBranches = null,Object? isLoadingSubmodules = null,Object? isCloning = null,Object? cloningInfo = null,Object? commitError = freezed,Object? branchError = freezed,Object? submoduleError = freezed,Object? lastRefreshInfo = null,Object? scope = null,Object? remoteName = null,Object? submoduleLogs = null,Object? isLoadingSubmoduleLogs = null,}) {
  return _then(CommitsState(
commits: null == commits ? _self.commits : commits // ignore: cast_nullable_to_non_nullable
as List<GitCommit>,branches: null == branches ? _self.branches : branches // ignore: cast_nullable_to_non_nullable
as List<GitBranch>,submodules: null == submodules ? _self.submodules : submodules // ignore: cast_nullable_to_non_nullable
as List<GitSubmodule>,submoduleBranches: null == submoduleBranches ? _self.submoduleBranches : submoduleBranches // ignore: cast_nullable_to_non_nullable
as Map<String, String>,remoteUrl: null == remoteUrl ? _self.remoteUrl : remoteUrl // ignore: cast_nullable_to_non_nullable
as String,branch: null == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String,commitLimit: null == commitLimit ? _self.commitLimit : commitLimit // ignore: cast_nullable_to_non_nullable
as String,commitQuery: null == commitQuery ? _self.commitQuery : commitQuery // ignore: cast_nullable_to_non_nullable
as String,newestFirst: null == newestFirst ? _self.newestFirst : newestFirst // ignore: cast_nullable_to_non_nullable
as bool,isLoadingCommits: null == isLoadingCommits ? _self.isLoadingCommits : isLoadingCommits // ignore: cast_nullable_to_non_nullable
as bool,isLoadingBranches: null == isLoadingBranches ? _self.isLoadingBranches : isLoadingBranches // ignore: cast_nullable_to_non_nullable
as bool,isLoadingSubmodules: null == isLoadingSubmodules ? _self.isLoadingSubmodules : isLoadingSubmodules // ignore: cast_nullable_to_non_nullable
as bool,isCloning: null == isCloning ? _self.isCloning : isCloning // ignore: cast_nullable_to_non_nullable
as bool,cloningInfo: null == cloningInfo ? _self.cloningInfo : cloningInfo // ignore: cast_nullable_to_non_nullable
as String,commitError: freezed == commitError ? _self.commitError : commitError // ignore: cast_nullable_to_non_nullable
as String?,branchError: freezed == branchError ? _self.branchError : branchError // ignore: cast_nullable_to_non_nullable
as String?,submoduleError: freezed == submoduleError ? _self.submoduleError : submoduleError // ignore: cast_nullable_to_non_nullable
as String?,lastRefreshInfo: null == lastRefreshInfo ? _self.lastRefreshInfo : lastRefreshInfo // ignore: cast_nullable_to_non_nullable
as String,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String,remoteName: null == remoteName ? _self.remoteName : remoteName // ignore: cast_nullable_to_non_nullable
as String,submoduleLogs: null == submoduleLogs ? _self.submoduleLogs : submoduleLogs // ignore: cast_nullable_to_non_nullable
as Map<String, List<GitCommit>>,isLoadingSubmoduleLogs: null == isLoadingSubmoduleLogs ? _self.isLoadingSubmoduleLogs : isLoadingSubmoduleLogs // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CommitsState].
extension CommitsStatePatterns on CommitsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommitsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommitsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommitsState value)  $default,){
final _that = this;
switch (_that) {
case _CommitsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommitsState value)?  $default,){
final _that = this;
switch (_that) {
case _CommitsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<GitCommit> commits,  List<GitBranch> branches,  List<GitSubmodule> submodules,  Map<String, String> submoduleBranches,  String remoteUrl,  String branch,  String commitLimit,  String commitQuery,  bool newestFirst,  bool isLoadingCommits,  bool isLoadingBranches,  bool isLoadingSubmodules,  bool isCloning,  String cloningInfo,  String? commitError,  String? branchError,  String? submoduleError,  String lastRefreshInfo,  String scope,  String remoteName,  Map<String, List<GitCommit>> submoduleLogs,  bool isLoadingSubmoduleLogs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommitsState() when $default != null:
return $default(_that.commits,_that.branches,_that.submodules,_that.submoduleBranches,_that.remoteUrl,_that.branch,_that.commitLimit,_that.commitQuery,_that.newestFirst,_that.isLoadingCommits,_that.isLoadingBranches,_that.isLoadingSubmodules,_that.isCloning,_that.cloningInfo,_that.commitError,_that.branchError,_that.submoduleError,_that.lastRefreshInfo,_that.scope,_that.remoteName,_that.submoduleLogs,_that.isLoadingSubmoduleLogs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<GitCommit> commits,  List<GitBranch> branches,  List<GitSubmodule> submodules,  Map<String, String> submoduleBranches,  String remoteUrl,  String branch,  String commitLimit,  String commitQuery,  bool newestFirst,  bool isLoadingCommits,  bool isLoadingBranches,  bool isLoadingSubmodules,  bool isCloning,  String cloningInfo,  String? commitError,  String? branchError,  String? submoduleError,  String lastRefreshInfo,  String scope,  String remoteName,  Map<String, List<GitCommit>> submoduleLogs,  bool isLoadingSubmoduleLogs)  $default,) {final _that = this;
switch (_that) {
case _CommitsState():
return $default(_that.commits,_that.branches,_that.submodules,_that.submoduleBranches,_that.remoteUrl,_that.branch,_that.commitLimit,_that.commitQuery,_that.newestFirst,_that.isLoadingCommits,_that.isLoadingBranches,_that.isLoadingSubmodules,_that.isCloning,_that.cloningInfo,_that.commitError,_that.branchError,_that.submoduleError,_that.lastRefreshInfo,_that.scope,_that.remoteName,_that.submoduleLogs,_that.isLoadingSubmoduleLogs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<GitCommit> commits,  List<GitBranch> branches,  List<GitSubmodule> submodules,  Map<String, String> submoduleBranches,  String remoteUrl,  String branch,  String commitLimit,  String commitQuery,  bool newestFirst,  bool isLoadingCommits,  bool isLoadingBranches,  bool isLoadingSubmodules,  bool isCloning,  String cloningInfo,  String? commitError,  String? branchError,  String? submoduleError,  String lastRefreshInfo,  String scope,  String remoteName,  Map<String, List<GitCommit>> submoduleLogs,  bool isLoadingSubmoduleLogs)?  $default,) {final _that = this;
switch (_that) {
case _CommitsState() when $default != null:
return $default(_that.commits,_that.branches,_that.submodules,_that.submoduleBranches,_that.remoteUrl,_that.branch,_that.commitLimit,_that.commitQuery,_that.newestFirst,_that.isLoadingCommits,_that.isLoadingBranches,_that.isLoadingSubmodules,_that.isCloning,_that.cloningInfo,_that.commitError,_that.branchError,_that.submoduleError,_that.lastRefreshInfo,_that.scope,_that.remoteName,_that.submoduleLogs,_that.isLoadingSubmoduleLogs);case _:
  return null;

}
}

}

/// @nodoc


class _CommitsState implements CommitsState {
  const _CommitsState({ List<GitCommit> commits = const [],  List<GitBranch> branches = const [],  List<GitSubmodule> submodules = const [],  Map<String, String> submoduleBranches = const {}, this.remoteUrl = '', this.branch = '', this.commitLimit = '100', this.commitQuery = '', this.newestFirst = true, this.isLoadingCommits = false, this.isLoadingBranches = false, this.isLoadingSubmodules = false, this.isCloning = false, this.cloningInfo = '', this.commitError, this.branchError, this.submoduleError, this.lastRefreshInfo = '', this.scope = '', this.remoteName = 'origin',  Map<String, List<GitCommit>> submoduleLogs = const {}, this.isLoadingSubmoduleLogs = false}): _commits = commits,_branches = branches,_submodules = submodules,_submoduleBranches = submoduleBranches,_submoduleLogs = submoduleLogs;
  

 final  List<GitCommit> _commits;
@override@JsonKey() List<GitCommit> get commits {
  if (_commits is EqualUnmodifiableListView) return _commits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_commits);
}

 final  List<GitBranch> _branches;
@override@JsonKey() List<GitBranch> get branches {
  if (_branches is EqualUnmodifiableListView) return _branches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_branches);
}

 final  List<GitSubmodule> _submodules;
@override@JsonKey() List<GitSubmodule> get submodules {
  if (_submodules is EqualUnmodifiableListView) return _submodules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_submodules);
}

 final  Map<String, String> _submoduleBranches;
@override@JsonKey() Map<String, String> get submoduleBranches {
  if (_submoduleBranches is EqualUnmodifiableMapView) return _submoduleBranches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_submoduleBranches);
}

@override@JsonKey() final  String remoteUrl;
/// 当前分支（'' = 当前 HEAD）
@override@JsonKey() final  String branch;
@override@JsonKey() final  String commitLimit;
@override@JsonKey() final  String commitQuery;
@override@JsonKey() final  bool newestFirst;
@override@JsonKey() final  bool isLoadingCommits;
@override@JsonKey() final  bool isLoadingBranches;
@override@JsonKey() final  bool isLoadingSubmodules;
@override@JsonKey() final  bool isCloning;
@override@JsonKey() final  String cloningInfo;
@override final  String? commitError;
@override final  String? branchError;
@override final  String? submoduleError;
@override@JsonKey() final  String lastRefreshInfo;
/// 子模块范围（'' = 主仓库）；与 controller 的 selectedScope 同步。
@override@JsonKey() final  String scope;
/// remote 名（与 controller 的 remote 同步，用于 fetchRemoteUrl）。
@override@JsonKey() final  String remoteName;
/// 各子模块最近提交（参照面板用），key = 子模块 path。
 final  Map<String, List<GitCommit>> _submoduleLogs;
/// 各子模块最近提交（参照面板用），key = 子模块 path。
@override@JsonKey() Map<String, List<GitCommit>> get submoduleLogs {
  if (_submoduleLogs is EqualUnmodifiableMapView) return _submoduleLogs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_submoduleLogs);
}

@override@JsonKey() final  bool isLoadingSubmoduleLogs;

/// Create a copy of CommitsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommitsStateCopyWith<_CommitsState> get copyWith => __$CommitsStateCopyWithImpl<_CommitsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommitsState&&const DeepCollectionEquality().equals(other.commits, _commits)&&const DeepCollectionEquality().equals(other.branches, _branches)&&const DeepCollectionEquality().equals(other.submodules, _submodules)&&const DeepCollectionEquality().equals(other.submoduleBranches, _submoduleBranches)&&(identical(other.remoteUrl, remoteUrl) || other.remoteUrl == remoteUrl)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.commitLimit, commitLimit) || other.commitLimit == commitLimit)&&(identical(other.commitQuery, commitQuery) || other.commitQuery == commitQuery)&&(identical(other.newestFirst, newestFirst) || other.newestFirst == newestFirst)&&(identical(other.isLoadingCommits, isLoadingCommits) || other.isLoadingCommits == isLoadingCommits)&&(identical(other.isLoadingBranches, isLoadingBranches) || other.isLoadingBranches == isLoadingBranches)&&(identical(other.isLoadingSubmodules, isLoadingSubmodules) || other.isLoadingSubmodules == isLoadingSubmodules)&&(identical(other.isCloning, isCloning) || other.isCloning == isCloning)&&(identical(other.cloningInfo, cloningInfo) || other.cloningInfo == cloningInfo)&&(identical(other.commitError, commitError) || other.commitError == commitError)&&(identical(other.branchError, branchError) || other.branchError == branchError)&&(identical(other.submoduleError, submoduleError) || other.submoduleError == submoduleError)&&(identical(other.lastRefreshInfo, lastRefreshInfo) || other.lastRefreshInfo == lastRefreshInfo)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.remoteName, remoteName) || other.remoteName == remoteName)&&const DeepCollectionEquality().equals(other.submoduleLogs, _submoduleLogs)&&(identical(other.isLoadingSubmoduleLogs, isLoadingSubmoduleLogs) || other.isLoadingSubmoduleLogs == isLoadingSubmoduleLogs));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,const DeepCollectionEquality().hash(_commits),const DeepCollectionEquality().hash(_branches),const DeepCollectionEquality().hash(_submodules),const DeepCollectionEquality().hash(_submoduleBranches),remoteUrl,branch,commitLimit,commitQuery,newestFirst,isLoadingCommits,isLoadingBranches,isLoadingSubmodules,isCloning,cloningInfo,commitError,branchError,submoduleError,lastRefreshInfo,scope,remoteName,const DeepCollectionEquality().hash(_submoduleLogs),isLoadingSubmoduleLogs]);
}

@override
String toString() {
    return 'CommitsState(commits: $commits, branches: $branches, submodules: $submodules, submoduleBranches: $submoduleBranches, remoteUrl: $remoteUrl, branch: $branch, commitLimit: $commitLimit, commitQuery: $commitQuery, newestFirst: $newestFirst, isLoadingCommits: $isLoadingCommits, isLoadingBranches: $isLoadingBranches, isLoadingSubmodules: $isLoadingSubmodules, isCloning: $isCloning, cloningInfo: $cloningInfo, commitError: $commitError, branchError: $branchError, submoduleError: $submoduleError, lastRefreshInfo: $lastRefreshInfo, scope: $scope, remoteName: $remoteName, submoduleLogs: $submoduleLogs, isLoadingSubmoduleLogs: $isLoadingSubmoduleLogs)';
}


}

/// @nodoc
abstract mixin class _$CommitsStateCopyWith<$Res> implements $CommitsStateCopyWith<$Res> {
  factory _$CommitsStateCopyWith(_CommitsState value, $Res Function(_CommitsState) _then) = __$CommitsStateCopyWithImpl;
@override @useResult
$Res call({
 List<GitCommit> commits, List<GitBranch> branches, List<GitSubmodule> submodules, Map<String, String> submoduleBranches, String remoteUrl, String branch, String commitLimit, String commitQuery, bool newestFirst, bool isLoadingCommits, bool isLoadingBranches, bool isLoadingSubmodules, bool isCloning, String cloningInfo, String? commitError, String? branchError, String? submoduleError, String lastRefreshInfo, String scope, String remoteName, Map<String, List<GitCommit>> submoduleLogs, bool isLoadingSubmoduleLogs
});




}
/// @nodoc
class __$CommitsStateCopyWithImpl<$Res>
    implements _$CommitsStateCopyWith<$Res> {
  __$CommitsStateCopyWithImpl(this._self, this._then);

  final _CommitsState _self;
  final $Res Function(_CommitsState) _then;

/// Create a copy of CommitsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? commits = null,Object? branches = null,Object? submodules = null,Object? submoduleBranches = null,Object? remoteUrl = null,Object? branch = null,Object? commitLimit = null,Object? commitQuery = null,Object? newestFirst = null,Object? isLoadingCommits = null,Object? isLoadingBranches = null,Object? isLoadingSubmodules = null,Object? isCloning = null,Object? cloningInfo = null,Object? commitError = freezed,Object? branchError = freezed,Object? submoduleError = freezed,Object? lastRefreshInfo = null,Object? scope = null,Object? remoteName = null,Object? submoduleLogs = null,Object? isLoadingSubmoduleLogs = null,}) {
  return _then(_CommitsState(
commits: null == commits ? _self._commits : commits // ignore: cast_nullable_to_non_nullable
as List<GitCommit>,branches: null == branches ? _self._branches : branches // ignore: cast_nullable_to_non_nullable
as List<GitBranch>,submodules: null == submodules ? _self._submodules : submodules // ignore: cast_nullable_to_non_nullable
as List<GitSubmodule>,submoduleBranches: null == submoduleBranches ? _self._submoduleBranches : submoduleBranches // ignore: cast_nullable_to_non_nullable
as Map<String, String>,remoteUrl: null == remoteUrl ? _self.remoteUrl : remoteUrl // ignore: cast_nullable_to_non_nullable
as String,branch: null == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String,commitLimit: null == commitLimit ? _self.commitLimit : commitLimit // ignore: cast_nullable_to_non_nullable
as String,commitQuery: null == commitQuery ? _self.commitQuery : commitQuery // ignore: cast_nullable_to_non_nullable
as String,newestFirst: null == newestFirst ? _self.newestFirst : newestFirst // ignore: cast_nullable_to_non_nullable
as bool,isLoadingCommits: null == isLoadingCommits ? _self.isLoadingCommits : isLoadingCommits // ignore: cast_nullable_to_non_nullable
as bool,isLoadingBranches: null == isLoadingBranches ? _self.isLoadingBranches : isLoadingBranches // ignore: cast_nullable_to_non_nullable
as bool,isLoadingSubmodules: null == isLoadingSubmodules ? _self.isLoadingSubmodules : isLoadingSubmodules // ignore: cast_nullable_to_non_nullable
as bool,isCloning: null == isCloning ? _self.isCloning : isCloning // ignore: cast_nullable_to_non_nullable
as bool,cloningInfo: null == cloningInfo ? _self.cloningInfo : cloningInfo // ignore: cast_nullable_to_non_nullable
as String,commitError: freezed == commitError ? _self.commitError : commitError // ignore: cast_nullable_to_non_nullable
as String?,branchError: freezed == branchError ? _self.branchError : branchError // ignore: cast_nullable_to_non_nullable
as String?,submoduleError: freezed == submoduleError ? _self.submoduleError : submoduleError // ignore: cast_nullable_to_non_nullable
as String?,lastRefreshInfo: null == lastRefreshInfo ? _self.lastRefreshInfo : lastRefreshInfo // ignore: cast_nullable_to_non_nullable
as String,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String,remoteName: null == remoteName ? _self.remoteName : remoteName // ignore: cast_nullable_to_non_nullable
as String,submoduleLogs: null == submoduleLogs ? _self._submoduleLogs : submoduleLogs // ignore: cast_nullable_to_non_nullable
as Map<String, List<GitCommit>>,isLoadingSubmoduleLogs: null == isLoadingSubmoduleLogs ? _self.isLoadingSubmoduleLogs : isLoadingSubmoduleLogs // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
