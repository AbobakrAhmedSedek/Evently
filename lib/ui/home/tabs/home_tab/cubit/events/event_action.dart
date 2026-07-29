import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_action.freezed.dart';

@freezed
class EventAction with _$EventAction {
  const factory EventAction.deleteSuccess() = DeleteSuccess;
}
