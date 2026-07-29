import 'dart:async';

import 'package:evently/data/repositories/auth_repository.dart';
import 'package:evently/data/repositories/event_repository.dart';
import 'package:evently/domain/model/event.dart';
import 'package:evently/ui/home/tabs/favorite_tab/cubit/favorite_action.dart';
import 'package:evently/ui/home/tabs/favorite_tab/cubit/favorite_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

class FavoriteCubit extends Cubit<FavoriteState> {
  FavoriteCubit(this._eventRepository, this._authRepository)
    : super(FavoriteState.initial());

  List<Event> _favoritesList = [];
  final AuthRepository _authRepository;
  final EventRepository _eventRepository;

  final _actions = PublishSubject<FavoriteAction>();
  Stream<FavoriteAction> get actions => _actions.stream;

  StreamSubscription<List<Event>>? _streamSubscription;

  void _emitSuccess() {
    emit(FavoriteState.success(events: List.unmodifiable(_favoritesList)));
  }

  void listenToFavorites() {
    final userId = _authRepository.currentUserId;
    if (userId == null) {
      emit(FavoriteState.error(message: 'User not found'));
      return;
    }

    emit(FavoriteState.loading());
    if (_streamSubscription != null) return;
    _streamSubscription = _eventRepository
        .getEventsStream(userId)
        .listen(
          (events) {
            debugPrint("🔥 Favorite Stream callback");
            debugPrint(
              "Favorites: ${events.where((e) => e.isFavorite).length}",
            );

            _favoritesList = events.where((event) => event.isFavorite).toList();

            _emitSuccess();
          },
          onError: (error) {
            emit(FavoriteState.error(message: error.toString()));
          },
        );
  }

  Future<void> updateIsFavoriteEvents(Event event, String userId) async {
    final removedIndex = _favoritesList.indexWhere((e) => e.id == event.id);
    if (removedIndex == -1) return;

    final removedEvent = _favoritesList[removedIndex];

    debugPrint("Before remove: ${_favoritesList.length}");

    _favoritesList.removeAt(removedIndex);

    debugPrint("After remove: ${_favoritesList.length}");

    _emitSuccess();

    debugPrint("Emit success");
    try {
      await _eventRepository.updateEventField(
        userId,
        event.id,
        'isFavorite',
        !event.isFavorite,
      );
    } catch (error) {
      _favoritesList.insert(removedIndex, removedEvent);
      _actions.add(const FavoriteAction.updateFavoriteFailed());

      debugPrint("Before emit state: $state");

      _emitSuccess();

      debugPrint("After emit state: $state");
    }
  }

  @override
  Future<void> close() async {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _actions.close();
    return super.close();
  }
}
