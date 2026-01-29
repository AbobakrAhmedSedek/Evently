import 'package:evently/data/repositories/event_repository.dart';
import 'package:evently/domain/model/event.dart';
import 'package:evently/ui/home/tabs/home_tab/models/event_data_model.dart';
import 'package:evently/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EventListProvider with ChangeNotifier {
  // ✅ استخدام EventRepository بدلاً من FirebaseUtils
  final EventRepository _eventRepository = EventRepository();

  List<Event> eventsList = [];
  List<Event> eventsFiltered = [];
  List<EventData> eventsDataList = [];
  List<Event> favoriteEventsList = [];
  int selectedIndex = 0;

  // ============================================
  // 📊 Events Data (Tabs/Categories)
  // ============================================

  /// إنشاء Tabs (أنواع الأحداث)
  void getEventsDataList(BuildContext context) {
    eventsDataList = [
      EventData(
        name: AppLocalizations.of(context)!.all,
        icon: Bootstrap.house,
        categoryKey: 'all',
      ),
      EventData(
        name: AppLocalizations.of(context)!.sport,
        icon: FontAwesome.futbol_solid,
        categoryKey: 'sport',
      ),
      EventData(
        name: AppLocalizations.of(context)!.birthday,
        icon: Iconsax.cake_bold,
        categoryKey: 'birthday',
      ),
      EventData(
        name: AppLocalizations.of(context)!.meeting,
        icon: EvaIcons.people,
        categoryKey: 'meeting',
      ),
      EventData(
        name: AppLocalizations.of(context)!.gaming,
        icon: Bootstrap.controller,
        categoryKey: 'gaming',
      ),
      EventData(
        name: AppLocalizations.of(context)!.workshop,
        icon: LineAwesome.toolbox_solid,
        categoryKey: 'workshop',
      ),
      EventData(
        name: AppLocalizations.of(context)!.book_club,
        icon: MingCute.book_2_fill,
        categoryKey: 'book_club',
      ),
      EventData(
        name: AppLocalizations.of(context)!.exhibition,
        icon: Clarity.picture_line,
        categoryKey: 'exhibition',
      ),
      EventData(
        name: AppLocalizations.of(context)!.holiday,
        icon: LineAwesome.hotel_solid,
        categoryKey: 'holiday',
      ),
      EventData(
        name: AppLocalizations.of(context)!.eating,
        icon: IonIcons.fast_food,
        categoryKey: 'eating',
      ),
    ];
    notifyListeners();
  }

  // ============================================
  // 📖 Read Operations
  // ============================================

  /// جلب جميع الأحداث من Firebase
  Future<void> getAllEvents(String userId) async {
    try {
      // ✅ استخدام Repository
      eventsList = await _eventRepository.getAllEvents(userId);

      // إضافة الـ id لكل حدث (إذا لم يكن موجوداً)
      eventsFiltered = eventsList;
      eventsFiltered.sort((a, b) => a.date.compareTo(b.date));

      notifyListeners();
    } catch (e) {
      print('❌ Error getting events: $e');
      eventsList = [];
      eventsFiltered = [];
      notifyListeners();
    }
  }

  /// جلب الأحداث المفضلة فقط
  Future<void> getAllFavoriteEvents(String userId) async {
    try {
      // ✅ يمكن استخدام query مخصص أو فلترة محلية
      //    
      final allEvents = await _eventRepository.getAllEvents(userId);
      favoriteEventsList = allEvents.where((e) => e.isFavorite).toList();
      favoriteEventsList.sort((a, b) => a.date.compareTo(b.date));

      notifyListeners();
    } catch (e) {
      print('❌ Error getting favorite events: $e');
      favoriteEventsList = [];
      notifyListeners();
    }
  }

  /// جلب أحداث اليوم
  Future<void> getTodayEvents(String userId) async {
    try {
      eventsList = await _eventRepository.getTodayEvents(userId);
      eventsFiltered = eventsList;
      notifyListeners();
    } catch (e) {
      print('❌ Error getting today events: $e');
    }
  }

  /// جلب الأحداث القادمة
  Future<void> getUpcomingEvents(String userId) async {
    try {
      eventsList = await _eventRepository.getUpcomingEvents(userId);
      eventsFiltered = eventsList;
      notifyListeners();
    } catch (e) {
      print('❌ Error getting upcoming events: $e');
    }
  }

  // ============================================
  // 🔍 Filter & Search
  // ============================================

  /// فلترة الأحداث حسب التاب المختارة
  void getFilterEvents() {
    if (selectedIndex == 0) {
      // "All" tab
      eventsFiltered = eventsList;
    } else {
      // فلترة حسب الفئة
      eventsFiltered =
          eventsList
              .where(
                (event) =>
                    event.category == eventsDataList[selectedIndex].categoryKey,
              )
              .toList();
    }
    eventsFiltered.sort((a, b) => a.date.compareTo(b.date));
    notifyListeners();
  }

  /// تغيير التاب المختارة
  void changeSelectedIndex(int newIndex) {
    selectedIndex = newIndex;
    getFilterEvents();
  }

  /// البحث في الأحداث
  Future<void> searchEvents(String userId, String query) async {
    try {
      if (query.isEmpty) {
        await getAllEvents(userId);
        return;
      }

      eventsList = await _eventRepository.searchEventsByTitle(userId, query);
      eventsFiltered = eventsList;
      notifyListeners();
    } catch (e) {
      print('❌ Error searching events: $e');
    }
  }

  // ============================================
  // ✍️ Create & Update
  // ============================================
  
  // ✅ إضافة هذه الدالة في EventListProvider
  /// تحديث القوائم من Firebase Snapshot
  void updateEventsFromSnapshot(QuerySnapshot<Event> snapshot) {
    // 📝 شرح: QuerySnapshot يحتوي على مجموعة من الـ Documents
    // كل Document يمثل Event واحد

    eventsList =
        snapshot.docs.map((doc) {
          //  doc.data() تعطينا Event object
          Event e = doc.data();

          //  doc.id يعطينا الـ ID من Firebase
          // نستخدم copyWith لإضافة الـ ID للـ Event
          return e.copyWith(id: doc.id);
        }).toList();

         getFilterEvents();

  }

  ///   إضافة حدث جديد الى Firebase
  Future<bool> addEvent(Event event, String userId) async {
    try {
      await _eventRepository.addEvent(event, userId);

      // تحديث القائمة المحلية
      await getAllEvents(userId);

      return true;
    } catch (e) {
      print('❌ Error adding event: $e');
      return false;
    }
  }

  /// تحديث حدث
  Future<bool> updateEvent(Event event, String userId) async {
    try {
      await _eventRepository.updateEvent(event, userId);

      // تحديث القائمة المحلية
      await getAllEvents(userId);

      return true;
    } catch (e) {
      print('❌ Error updating event: $e');
      return false;
    }
  }

  /// تحديث حالة المفضلة (Optimistic Update)
  Future<void> updateIsFavoriteEvents(
    Event event,
    BuildContext context,
    String userId,
  ) async {
    final bool oldValue = event.isFavorite;
    final String docId = event.id;

    if (docId.isEmpty) {
      print('❌ Cannot update favorite: event.id is empty');
      ToastUtils.showToast(
        message: 'Invalid event ID',
        backgroundColor: Colors.red,
      );
      return;
    }

    // 🔹 1. تعديل محلي (Optimistic Update)
    final updatedEvent = event.copyWith(isFavorite: !oldValue);

    int idxAll = eventsList.indexWhere((e) => e.id == docId);
    if (idxAll != -1) eventsList[idxAll] = updatedEvent;

    int idxFiltered = eventsFiltered.indexWhere((e) => e.id == docId);
    if (idxFiltered != -1) eventsFiltered[idxFiltered] = updatedEvent;

    notifyListeners();

    // 🔹 2. تحديث في Firebase
    try {
      await _eventRepository.updateEventField(
        userId,
        docId,
        'isFavorite',
        !oldValue,
      );

      // تحديث قائمة المفضلة
      await getAllFavoriteEvents(userId);

      if (!context.mounted) return;

      String message =
          !oldValue
              ? AppLocalizations.of(context)!.added_to_favorites
              : AppLocalizations.of(context)!.removed_from_favorites;

      ToastUtils.showToast(
        message: message,
        backgroundColor: !oldValue ? Colors.green : Colors.red,
      );
    } catch (error) {
      // 🔹 3. رجوع للحالة القديمة في حال فشل Firebase
      if (idxAll != -1) eventsList[idxAll] = event;
      if (idxFiltered != -1) eventsFiltered[idxFiltered] = event;
      notifyListeners();

      print("❌ Error updating favorite: $error");

      if (context.mounted) {
        ToastUtils.showToast(
          message: 'Failed to update favorite',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  // ============================================
  // 🗑️ Delete Operations
  // ============================================

  /// حذف حدث
  Future<bool> deleteEvent(String userId, String eventId) async {
    try {
      await _eventRepository.deleteEvent(userId, eventId);

      // تحديث القائمة المحلية
      eventsList.removeWhere((e) => e.id == eventId);
      eventsFiltered.removeWhere((e) => e.id == eventId);
      favoriteEventsList.removeWhere((e) => e.id == eventId);

      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error deleting event: $e');
      return false;
    }
  }

  /// حذف جميع الأحداث
  Future<bool> deleteAllEvents(String userId) async {
    try {
      await _eventRepository.deleteAllEvents(userId);
      clearEvents();
      return true;
    } catch (e) {
      print('❌ Error deleting all events: $e');
      return false;
    }
  }

  // ============================================
  // 🧹 Clear & Reset
  // ============================================

  /// مسح جميع البيانات المحلية
  void clearEvents()  {
     eventsList.clear();
    eventsFiltered.clear();
    favoriteEventsList.clear();
    selectedIndex = 0;
    notifyListeners();
  }

  // ============================================
  // 📊 Statistics & Info
  // ============================================

  /// عدد الأحداث الكلي
  int get totalEventsCount => eventsList.length;

  /// عدد الأحداث المفضلة
  int get favoriteEventsCount => favoriteEventsList.length;

  /// عدد الأحداث المفلترة
  int get filteredEventsCount => eventsFiltered.length;

  /// التحقق من وجود أحداث
  bool get hasEvents => eventsList.isNotEmpty;

  /// التحقق من وجود أحداث مفلترة
  bool get hasFilteredEvents => eventsFiltered.isNotEmpty;

  /// الحصول على الفئة الحالية
  String get currentCategory {
    if (selectedIndex == 0) return 'all';
    return eventsDataList[selectedIndex].categoryKey;
  }

}

