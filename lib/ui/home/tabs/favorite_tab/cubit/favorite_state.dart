import 'package:evently/domain/model/event.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorite_state.freezed.dart';

@freezed
sealed class FavoriteState with _$FavoriteState {
  const factory FavoriteState.initial() = _Initial;

  const factory FavoriteState.loading() = _Loading;

  const factory FavoriteState.success({
    required List<Event> events,
  }) = _Success;

  const factory FavoriteState.error({
    required String message,
  }) = _Error;
}