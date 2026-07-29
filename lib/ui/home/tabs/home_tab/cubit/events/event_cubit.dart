import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
// import 'package:collection/collection.dart';
import 'package:evently/constants/event_categories.dart';
import 'package:evently/data/repositories/event_repository.dart';
import 'package:evently/domain/model/event.dart';
import 'package:evently/ui/home/tabs/home_tab/cubit/events/event_action.dart';
import 'package:evently/ui/home/tabs/home_tab/cubit/events/event_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:evently/data/repositories/auth_repository.dart';

class EventCubit extends Cubit<EventsState> {
  final EventRepository _eventRepository;
  EventCubit(this._eventRepository, this._authRepository)
    : super(EventsState.initial());
  List<Event> _eventsList = [];
  final AuthRepository _authRepository;

  StreamSubscription<List<Event>>? _streamSubscription;

  final _actions = PublishSubject<EventAction>();

  Stream<EventAction> get actions => _actions.stream;

  Future<void> getAllEvents(String userId) async {
    emit(EventsState.loading(selectedIndex: 0));

    try {
      _eventsList = await _eventRepository.getAllEvents(userId);
      _eventsList.sort((a, b) => a.date.compareTo(b.date));
      emit(EventsState.success(events: _eventsList, selectedIndex: 0));
    } catch (e) {
      emit(EventsState.error(message: e.toString(), selectedIndex: 0));
    }
  }

  void getFilterEvents(int selectedIndex) {
    List<Event> eventsFiltered = [];
    if (selectedIndex == 0) {
      eventsFiltered = _eventsList;
    } else {
      // فلترة حسب الفئة
      eventsFiltered =
          _eventsList
              .where(
                (event) =>
                    event.category ==
                    EventCategories.categories[selectedIndex].categoryKey,
              )
              .toList();
    }

    eventsFiltered.sort((a, b) => a.date.compareTo(b.date));
    emit(
      EventsState.success(events: eventsFiltered, selectedIndex: selectedIndex),
    );
  }

  void changeSelectedIndex(int newIndex) {
    getFilterEvents(newIndex);
  }

  Future<void> updateIsFavoriteEvents(Event event, String userId) async {
    final bool oldValue = event.isFavorite;
    final String docId = event.id;

    // 🔹 1. تعديل محلي (Optimistic Update)
    final updatedEvent = event.copyWith(isFavorite: !oldValue);

    int eventIndexAll = _eventsList.indexWhere((e) => e.id == docId);

    if (eventIndexAll != -1) _eventsList[eventIndexAll] = updatedEvent;
    final currentIndex = state.map(
      initial: (_) => 0,
      loading: (s) => s.selectedIndex,
      success: (s) => s.selectedIndex,
      error: (s) => s.selectedIndex,
    );

    // final newList = List<Event>.from(_eventsList);
    // newList[eventIndexAll] = updatedEvent;
    getFilterEvents(currentIndex);

    // 🔹 2. تحديث في Firebase
    try {
      await _eventRepository.updateEventField(
        userId,
        docId,
        'isFavorite',
        !oldValue,
      );
    } catch (error) {
      // 🔹 3. رجوع للحالة القديمة في حال فشل Firebase
      if (eventIndexAll != -1) _eventsList[eventIndexAll] = event;

      emit(
        EventsState.success(events: _eventsList, selectedIndex: currentIndex),
      );
    }
  }

  Future<void> deleteEvent(Event event) async {
    debugPrint("Cubit hashCode(deleteEvent): $hashCode");
    final currentIndex = state.map(
      initial: (_) => 0,
      loading: (s) => s.selectedIndex,
      success: (s) => s.selectedIndex,
      error: (s) => s.selectedIndex,
    );
    try {
      debugPrint("Before await delete");

      await _eventRepository.deleteEvent(event.userId, event.id);

      debugPrint("Before add action");

      _actions.add(const EventAction.deleteSuccess());

      debugPrint("After add action");
    } catch (error) {
      emit(
        EventsState.error(
          message: error.toString(),
          selectedIndex: currentIndex,
        ),
      );
    }
  }

  Future<void> editEvent(Event event) async {
    final currentIndex = state.map(
      initial: (_) => 0,
      loading: (s) => s.selectedIndex,
      success: (s) => s.selectedIndex,
      error: (s) => s.selectedIndex,
    );
    final eventIndex = _eventsList.indexWhere((e) => e.id == event.id);
    if (eventIndex == -1) {
      emit(
        EventsState.error(
          message: 'Event not found',
          selectedIndex: currentIndex,
        ),
      );
      return;
    }
    final oldEvent = _eventsList[eventIndex];
    try {
      _eventsList[eventIndex] = event;
      getFilterEvents(currentIndex);
      await _eventRepository.editEvent(event, event.userId);
    } catch (error) {
      // emit(
      //   EventsState.error(
      //     message: error.toString(),
      //     selectedIndex: currentIndex,
      //   ),
      // );
      _eventsList[eventIndex] = oldEvent;
      getFilterEvents(currentIndex);
    }
  }

  void listenToEvents() {
    final userId = _authRepository.currentUserId;
    if (userId == null) {
      emit(EventsState.error(message: 'User not found', selectedIndex: 0));
      return;
    }

    emit(
      EventsState.loading(
        selectedIndex: state.map(
          initial: (_) => 0,
          loading: (s) => s.selectedIndex,
          success: (s) => s.selectedIndex,
          error: (s) => s.selectedIndex,
        ),
      ),
    );
    if (_streamSubscription != null) return;
    _streamSubscription = _eventRepository
        .getEventsStream(userId)
        .listen(
          (events) {
            debugPrint("Stream callback start");
            _eventsList = events;

            final currentIndex = state.map(
              initial: (_) => 0,
              loading: (s) => s.selectedIndex,
              success: (s) => s.selectedIndex,
              error: (s) => s.selectedIndex,
            );

            debugPrint("Before emit");

            getFilterEvents(currentIndex);

            debugPrint("After emit");
          },
          onError: (error) {
            emit(
              EventsState.error(
                message: error.toString(),
                selectedIndex: state.map(
                  initial: (_) => 0,
                  loading: (s) => s.selectedIndex,
                  success: (s) => s.selectedIndex,
                  error: (s) => s.selectedIndex,
                ),
              ),
            );
          },
        );
  }

  Event getEventById(String id) {
    return _eventsList.firstWhere((e) => e.id == id);
  }

  void getFavoriteEvents() {
    List<Event> favoriteEvents = [];
    favoriteEvents = _eventsList.where((event) => event.isFavorite).toList();
    EventsState.success(events: favoriteEvents, selectedIndex: 0);                            
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _actions.close();
    return super.close();
  }
}
