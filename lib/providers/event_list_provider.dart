import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evently/model/event.dart';
import 'package:evently/ui/home/tabs/home_tab/models/event_data_model.dart';
import 'package:evently/utils/firebase_utils.dart';
import 'package:evently/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EventListProvider with ChangeNotifier {
  List<Event> eventsList = [];
  List<Event> eventsFiltered = [];
  List<EventData> eventsDataList = [];
  List<Event> favoriteEventsList = [];
  int selectedIndex = 0;

  /// ✅ إنشاء Tabs (أنواع الأحداث)
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

  /// ✅ جلب جميع الأحداث من Firebase
  Future<void> getAllEvents(String uId) async {
    QuerySnapshot<Event> querySnapshot =
        await FirebaseUtils.getEventsCollection(uId).get();

    /// إضافة id لكل حدث من doc.id
    eventsList =
        querySnapshot.docs.map((doc) {
          Event e = doc.data();
          return e.copyWith(id: doc.id);
        }).toList();

    eventsFiltered = eventsList;
    eventsFiltered.sort((a, b) => a.date.compareTo(b.date));
    notifyListeners();
  }

  /// ✅ فلترة الأحداث حسب التاب المختارة
  void getFilterEvents() {
    if (selectedIndex == 0) {
      eventsFiltered = eventsList;
    } else {
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

  /// ✅ عند تغيير التاب
  void changeSelectedIndex(int newIndex) {
    selectedIndex = newIndex;
    getFilterEvents();
  }

  /// ✅ تحديث حالة المفضلة
  void updateIsFavoriteEvents(
    Event event,
    BuildContext context,
    String uId,
  ) async {
    final bool oldValue = event.isFavorite;
    final String docId = event.id;

    if (docId.isEmpty) {
      print('Cannot update favorite: event.id is empty');
      return;
    }
    getAllfavoriteEvents(uId);

    // 🔹 1. تعديل محلي (Optimistic Update)
    final updatedEvent = event.copyWith(isFavorite: !oldValue);

    int idxAll = eventsList.indexWhere((e) => e.id == docId);
    if (idxAll != -1) eventsList[idxAll] = updatedEvent;

    int idxFiltered = eventsFiltered.indexWhere((e) => e.id == docId);
    if (idxFiltered != -1) eventsFiltered[idxFiltered] = updatedEvent;

    notifyListeners();

    // 🔹 2. تحديث في Firebase
    try {
      await FirebaseUtils.getEventsCollection(
        uId,
      ).doc(docId).update({'isFavorite': !oldValue});
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

      print("Error updating favorite: $error");
      ToastUtils.showToast(
        message: 'Failed to update favorite',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> getAllfavoriteEvents(String uId) async {
    var querySnapshot =
        await FirebaseUtils.getEventsCollection(
          uId,
        ).where('isFavorite', isEqualTo: true).orderBy('date').get();
    favoriteEventsList =
        querySnapshot.docs.map((doc) {
          return doc.data().copyWith(id: doc.id);
        }).toList();

    notifyListeners();
  }

  void clearEvents() {
    eventsList.clear();
    eventsFiltered.clear();
    selectedIndex = 0;
    notifyListeners();
  }

  // eventsList = [];
  // eventsFiltered = [];
  // favoriteEventsList = [];
}

//  ---------------------------------------------------------------------------------------------------------------

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:evently/model/event.dart';
// import 'package:evently/ui/home/tabs/home_tab/models/event_data_model.dart';
// import 'package:evently/utils/firebase_utils.dart';
// import 'package:evently/utils/toast_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:icons_plus/icons_plus.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// class EventListProvider with ChangeNotifier {
//   List<Event> eventsList = [];
//   List<Event> eventsFiltered = [];
//   List<EventData> eventsDataList = [];
//   int selectedIndex = 0;

//   void getEventsDataList(BuildContext context) {
//     eventsDataList = [
//       EventData(
//         name: AppLocalizations.of(context)!.all,
//         icon: Bootstrap.house,
//         categoryKey: 'all',
//       ),
//       EventData(
//         name: AppLocalizations.of(context)!.sport,
//         icon: FontAwesome.futbol_solid,
//         categoryKey: 'sport',
//       ),
//       EventData(
//         name: AppLocalizations.of(context)!.birthday,
//         icon: Icons.cake,
//         categoryKey: 'birthday',
//       ),
//       EventData(
//         name: AppLocalizations.of(context)!.meeting,
//         icon: Icons.people,
//         categoryKey: 'meeting',
//       ),
//       EventData(
//         name: AppLocalizations.of(context)!.gaming,
//         icon: Icons.sports_esports,
//         categoryKey: 'gaming',
//       ),
//       EventData(
//         name: AppLocalizations.of(context)!.workshop,
//         icon: Icons.work,
//         categoryKey: 'workshop',
//       ),
//       EventData(
//         name: AppLocalizations.of(context)!.book_club,
//         icon: Icons.book,
//         categoryKey: 'book_club',
//       ),
//       EventData(
//         name: AppLocalizations.of(context)!.exhibition,
//         icon: Icons.image,
//         categoryKey: 'exhibition',
//       ),
//       EventData(
//         name: AppLocalizations.of(context)!.holiday,
//         icon: Icons.beach_access,
//         categoryKey: 'holiday',
//       ),
//       EventData(
//         name: AppLocalizations.of(context)!.eating,
//         icon: Icons.fastfood,
//         categoryKey: 'eating',
//       ),
//     ];
//     notifyListeners();
//   }

//   Future<void> getAllEvents() async {
//     QuerySnapshot<Event> querySnapshot =
//         await FirebaseUtils.getEventsCollection().get();

//     eventsList = querySnapshot.docs.map((doc) {
//       Event e = doc.data();
//       e.id = doc.id; // ✅ إضافة id هنا
//       return e;
//     }).toList();

//     eventsFiltered = eventsList;
//     eventsFiltered.sort((a, b) => a.date.compareTo(b.date));
//     notifyListeners();
//   }

//   void getFilterEvents() {
//     if (selectedIndex == 0) {
//       eventsFiltered = eventsList;
//     } else {
//       eventsFiltered = eventsList
//           .where((event) =>
//               event.category == eventsDataList[selectedIndex].categoryKey)
//           .toList();
//     }
//     eventsFiltered.sort((a, b) => a.date.compareTo(b.date));
//     notifyListeners();
//   }

//   void changeSelectedIndex(int newIndex) {
//     selectedIndex = newIndex;
//     getFilterEvents();
//   }

//   /// ✅ تحديث حالة المفضلة مباشرة
//   void updateIsFavoriteEvents(Event event, BuildContext context) async {
//     final oldValue = event.isFavorite;
//     event.isFavorite = !event.isFavorite; // ✅ تعديل مباشر
//     notifyListeners();

//     try {
//       if (event.id.isEmpty) {
//         print('❌ حدث بدون id، لا يمكن التحديث في Firebase');
//         return;
//       }

//       await FirebaseUtils.getEventsCollection()
//           .doc(event.id)
//           .update({'isFavorite': event.isFavorite});

//       String message = event.isFavorite
//           ? AppLocalizations.of(context)!.added_to_favorites
//           : AppLocalizations.of(context)!.removed_from_favorites;

//       ToastUtils.showToast(
//         message: message,
//         backgroundColor: event.isFavorite ? Colors.green : Colors.red,
//       );
//     } catch (error) {
//       // 🔙 رجع القيمة القديمة إذا فشل التحديث
//       event.isFavorite = oldValue;
//       notifyListeners();
//       print('Error updating favorite: $error');
//       ToastUtils.showToast(
//         message: 'Failed to update favorite',
//         backgroundColor: Colors.red,
//       );
//     }
//   }
// }

//  ---------------------------------------------------------------------------------------------------------------
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:evently/model/event.dart';
// import 'package:evently/ui/home/tabs/home_tab/models/event_data_model.dart';
// import 'package:evently/utils/firebase_utils.dart';
// import 'package:evently/utils/toast_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:icons_plus/icons_plus.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// class EventListProvider with ChangeNotifier {
//   /// 🔹 قائمة كل الأحداث من Firebase
//   List<Event> eventsList = [];

//   /// 🔹 قائمة الأحداث بعد الفلترة
//   List<Event> eventsFiltered = [];

//   /// 🔹 بيانات التابات (الأنواع)
//   List<EventData> eventsDataList = [];

//   /// 🔹 التاب المحددة حاليًا
//   int selectedIndex = 0;

//   /// ✅ تهيئة Tabs عند بداية الصفحة
//   void getEventsDataList(BuildContext context) {
//     eventsDataList = [
//       EventData(
//         name: AppLocalizations.of(context)!.all,
//         icon: Bootstrap.house,
//         categoryKey: 'all',
//       ),
//       EventData(
//         name: AppLocalizations.of(context)!.sport,
//         icon: FontAwesome.futbol_solid,
//         categoryKey: 'sport',
//       ),
//       EventData(
//         name: AppLocalizations.of(context)!.birthday,
//         icon: Iconsax.cake_bold,
//         categoryKey: 'birthday',
//       ),
//       EventData(
//         name: AppLocalizations.of(context)!.meeting,
//         icon: EvaIcons.people,
//         categoryKey: 'meeting',
//       ),
//       EventData(
//         name: AppLocalizations.of(context)!.gaming,
//         icon: Bootstrap.controller,
//         categoryKey: 'gaming',
//       ),
//       EventData(
//         name: AppLocalizations.of(context)!.workshop,
//         icon: LineAwesome.toolbox_solid,
//         categoryKey: 'workshop',
//       ),
//       EventData(
//         name: AppLocalizations.of(context)!.book_club,
//         icon: MingCute.book_2_fill,
//         categoryKey: 'book_club',
//       ),
//       EventData(
//         name: AppLocalizations.of(context)!.exhibition,
//         icon: Clarity.picture_line,
//         categoryKey: 'exhibition',
//       ),
//       EventData(
//         name: AppLocalizations.of(context)!.holiday,
//         icon: LineAwesome.hotel_solid,
//         categoryKey: 'holiday',
//       ),
//       EventData(
//         name: AppLocalizations.of(context)!.eating,
//         icon: IonIcons.fast_food,
//         categoryKey: 'eating',
//       ),
//     ];
//     notifyListeners();
//   }

//   /// ✅ Firebase جلب جميع الأحداث من
//   Future<void> getAllEvents() async {
//     QuerySnapshot<Event> querySnapshot =
//         await FirebaseUtils.getEventsCollection().get();

//     /// 🔸 تعديل مهم:
//     /// لازم نضيف `doc.id` لكل حدث، لأن Firestore ما يرجع id تلقائيًا داخل data().
//     eventsList = querySnapshot.docs.map((doc) {
//       Event e = doc.data();
//       return Event(
//         id: doc.id, // ← هنا نضيف المعرف الصحيح
//         image: e.image,
//         description: e.description,
//         title: e.title,
//         date: e.date,
//         time: e.time,
//         eventName: e.eventName,
//         isFavorite: e.isFavorite,
//         category: e.category,
//       );
//     }).toList();

//     eventsFiltered = eventsList;
//     eventsFiltered.sort((a, b) => a.date.compareTo(b.date));
//     notifyListeners();
//   }

//   /// ✅ فلترة الأحداث حسب التاب المختارة
//   void getFilterEvents() {
//     if (selectedIndex == 0) {
//       eventsFiltered = eventsList;
//     } else {
//       eventsFiltered = eventsList
//           .where((event) =>
//               event.category == eventsDataList[selectedIndex].categoryKey)
//           .toList();
//     }
//     eventsFiltered.sort((a, b) => a.date.compareTo(b.date));
//     notifyListeners();
//   }

//   /// ✅ عند تغيير التاب
//   void changeSelectedIndex(int newIndex) {
//     selectedIndex = newIndex;
//     getFilterEvents();
//   }

//   /// ✅ تحديث حالة المفضلة
//   void updateIsFavoriteEvents(Event event, BuildContext context) {
//     bool wasFavorite = event.isFavorite;

//     FirebaseUtils.getEventsCollection()
//         .doc(event.id)
//         .update({'isFavorite': !event.isFavorite})
//         .timeout(
//           const Duration(milliseconds: 500),
//           onTimeout: () {
//             print('updateIsFavoriteEvents timeout success');

//             String message = wasFavorite
//                 ? AppLocalizations.of(context)!.removed_from_favorites
//                 : AppLocalizations.of(context)!.added_to_favorites;

//             ToastUtils.showToast(
//               message: message,
//               backgroundColor: wasFavorite ? Colors.red : Colors.green,
//             );
//           },
//         )
//         .catchError((error) {
//           print("Error updating favorite: $error");
//         });

//     /// 🔸 تحديث الحالة محليًا عشان الأيقونة تتغير فورًا
//     event.isFavorite = !event.isFavorite;
//     notifyListeners();
//   }
// }
