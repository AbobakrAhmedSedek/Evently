
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_state.freezed.dart';

@freezed
class EventsState with _$EventsState {
  const factory EventsState.initial() = _Initial;

  const factory EventsState.loading({
    @Default(0) int selectedIndex,
  }) = _Loading;

  const factory EventsState.success({
    required List events,
    required int selectedIndex,
  }) = _Success;

  const factory EventsState.error({
    required String message,
    @Default(0) int selectedIndex,
  }) = _Error;
}