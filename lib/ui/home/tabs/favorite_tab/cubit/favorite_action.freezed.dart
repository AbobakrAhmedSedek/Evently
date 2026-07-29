// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favorite_action.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FavoriteAction {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() updateFavoriteFailed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? updateFavoriteFailed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? updateFavoriteFailed,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_UpdateFavoriteFailed value) updateFavoriteFailed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_UpdateFavoriteFailed value)? updateFavoriteFailed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_UpdateFavoriteFailed value)? updateFavoriteFailed,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FavoriteActionCopyWith<$Res> {
  factory $FavoriteActionCopyWith(
    FavoriteAction value,
    $Res Function(FavoriteAction) then,
  ) = _$FavoriteActionCopyWithImpl<$Res, FavoriteAction>;
}

/// @nodoc
class _$FavoriteActionCopyWithImpl<$Res, $Val extends FavoriteAction>
    implements $FavoriteActionCopyWith<$Res> {
  _$FavoriteActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FavoriteAction
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$UpdateFavoriteFailedImplCopyWith<$Res> {
  factory _$$UpdateFavoriteFailedImplCopyWith(
    _$UpdateFavoriteFailedImpl value,
    $Res Function(_$UpdateFavoriteFailedImpl) then,
  ) = __$$UpdateFavoriteFailedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$UpdateFavoriteFailedImplCopyWithImpl<$Res>
    extends _$FavoriteActionCopyWithImpl<$Res, _$UpdateFavoriteFailedImpl>
    implements _$$UpdateFavoriteFailedImplCopyWith<$Res> {
  __$$UpdateFavoriteFailedImplCopyWithImpl(
    _$UpdateFavoriteFailedImpl _value,
    $Res Function(_$UpdateFavoriteFailedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FavoriteAction
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$UpdateFavoriteFailedImpl implements _UpdateFavoriteFailed {
  const _$UpdateFavoriteFailedImpl();

  @override
  String toString() {
    return 'FavoriteAction.updateFavoriteFailed()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateFavoriteFailedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() updateFavoriteFailed,
  }) {
    return updateFavoriteFailed();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? updateFavoriteFailed,
  }) {
    return updateFavoriteFailed?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? updateFavoriteFailed,
    required TResult orElse(),
  }) {
    if (updateFavoriteFailed != null) {
      return updateFavoriteFailed();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_UpdateFavoriteFailed value) updateFavoriteFailed,
  }) {
    return updateFavoriteFailed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_UpdateFavoriteFailed value)? updateFavoriteFailed,
  }) {
    return updateFavoriteFailed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_UpdateFavoriteFailed value)? updateFavoriteFailed,
    required TResult orElse(),
  }) {
    if (updateFavoriteFailed != null) {
      return updateFavoriteFailed(this);
    }
    return orElse();
  }
}

abstract class _UpdateFavoriteFailed implements FavoriteAction {
  const factory _UpdateFavoriteFailed() = _$UpdateFavoriteFailedImpl;
}
