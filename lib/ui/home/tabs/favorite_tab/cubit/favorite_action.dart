import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorite_action.freezed.dart';

@freezed
class FavoriteAction with _$FavoriteAction {
  const factory FavoriteAction.updateFavoriteFailed() = _UpdateFavoriteFailed;
}
