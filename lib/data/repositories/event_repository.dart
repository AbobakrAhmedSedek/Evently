import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evently/domain/model/event.dart';
import 'package:evently/domain/model/my_user.dart';
import 'package:evently/ui/home/home_screen.dart';
import 'package:evently/utils/toast_utils.dart';
import 'package:flutter/material.dart';

/// Repository للتعامل مع Events في Firestore
/// مسؤول فقط عن CRUD operations للـ Events
class EventRepository {
  final FirebaseFirestore _firestore;

  EventRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// الحصول على Collection الـ Events لمستخدم معين
  CollectionReference<Event> getEventsCollection(String userId) {
    return _firestore
        .collection(MyUser.collectionName)
        .doc(userId)
        .collection(Event.collectionName)
        .withConverter<Event>(
          fromFirestore: (snapshot, _) => Event.fromJson(snapshot.data()!),
          toFirestore: (event, _) => event.toJson(),
        );
  }

  // ============================================
  // ✍️ Create
  // ============================================

  /// إضافة Event جديد
  Future<void> addEvent(Event event, String userId) async {
    // ✅ إنشاء DocumentReference مع ID تلقائي
    final docRef = getEventsCollection(userId).doc();

    // ✅ تحديث الـ ID في الـ Event object
    event.id = docRef.id;

    // ✅ حفظ البيانات
    return docRef.set(event);
  }

  /// إضافة Event مع ID محدد
  Future<void> addEventWithId(
    Event event,
    String userId,
    String eventId,
  ) async {
    event.id = eventId;
    return getEventsCollection(userId).doc(eventId).set(event);
  }

  // ============================================
  // 📖 Read
  // ============================================

  /// الحصول على Event معين بـ ID
  Future<Event?> getEventById(String userId, String eventId) async {
    final docSnapshot = await getEventsCollection(userId).doc(eventId).get();
    return docSnapshot.exists ? docSnapshot.data() : null;
  }

  /// الحصول على جميع Events للمستخدم
  Future<List<Event>> getAllEvents(String userId) async {
    final querySnapshot = await getEventsCollection(userId).get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Stream للاستماع لجميع Events
  Stream<List<Event>> getEventsStream(String userId) {
    return getEventsCollection(userId).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
    );
  }

  /// الحصول على Events بناءً على التاريخ
  Future<List<Event>> getEventsByDate(String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final querySnapshot =
        await getEventsCollection(userId)
            .where(
              'date',
              isGreaterThanOrEqualTo: startOfDay.millisecondsSinceEpoch,
            )
            .where('date', isLessThanOrEqualTo: endOfDay.millisecondsSinceEpoch)
            .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  /// الحصول على Events لشهر معين
  Future<List<Event>> getEventsByMonth(
    String userId,
    int year,
    int month,
  ) async {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

    final querySnapshot =
        await getEventsCollection(userId)
            .where(
              'date',
              isGreaterThanOrEqualTo: startOfMonth.millisecondsSinceEpoch,
            )
            .where(
              'date',
              isLessThanOrEqualTo: endOfMonth.millisecondsSinceEpoch,
            )
            .orderBy('date')
            .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  // ============================================
  // 🔄 Update
  // ============================================

  /// تحديث Event
  Future<bool> editEvent(Event event, String userId) async {
    try {
      await getEventsCollection(userId).doc(event.id).update(event.toJson());
      ToastUtils.showToast(
        message: 'Event updated successfully',
        backgroundColor: Colors.green,
      );

      return true;
    } catch (e) {
      ToastUtils.showToast(
        message: 'Failed to update event',
        backgroundColor: Colors.red,
      );
      
      return false;
    }
  }

  /// تحديث حقل معين في Event
  Future<void> updateEventField(
    String userId,
    String eventId,
    String field,
    dynamic value,
  ) async {
    return getEventsCollection(userId).doc(eventId).update({field: value});
  }

  // ============================================
  // 🗑️ Delete
  // ============================================

  /// حذف Event
  Future<void> deleteEvent(String userId, String eventId) async {
    return getEventsCollection(userId).doc(eventId).delete();
  }

  /// حذف جميع Events للمستخدم
  Future<void> deleteAllEvents(String userId) async {
    final querySnapshot = await getEventsCollection(userId).get();
    final batch = _firestore.batch();

    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }

    return batch.commit();
  }

  // ============================================
  // 🔍 Query Methods
  // ============================================

  /// البحث عن Events بالعنوان
  Future<List<Event>> searchEventsByTitle(String userId, String title) async {
    final querySnapshot =
        await getEventsCollection(userId)
            .where('title', isGreaterThanOrEqualTo: title)
            .where('title', isLessThanOrEqualTo: '$title\uf8ff')
            .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  /// الحصول على Events القادمة
  Future<List<Event>> getUpcomingEvents(String userId) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final querySnapshot =
        await getEventsCollection(
          userId,
        ).where('date', isGreaterThanOrEqualTo: now).orderBy('date').get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  /// الحصول على Events السابقة
  Future<List<Event>> getPastEvents(String userId) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final querySnapshot =
        await getEventsCollection(userId)
            .where('date', isLessThan: now)
            .orderBy('date', descending: true)
            .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  /// الحصول على Events اليوم
  Future<List<Event>> getTodayEvents(String userId) async {
    final now = DateTime.now();
    return getEventsByDate(userId, now);
  }

  /// عد عدد Events للمستخدم
  Future<int> getEventsCount(String userId) async {
    final querySnapshot = await getEventsCollection(userId).get();
    return querySnapshot.docs.length;
  }

  /// الحصول على Events المفضلة للمستخدم
  Future<List<Event>> getAllfavoriteEvents(String userId) async {
    final querySnapshot =
        await getEventsCollection(
          userId,
        ).where("isFavorite", isEqualTo: true).get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }
}
