import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evently/model/event.dart';
import 'package:evently/model/my_user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseUtils {
  static CollectionReference<Event> getEventsCollection(String uId) {
    return getUsersCollection()
        .doc(uId)
        .collection(Event.collectionName)
        .withConverter(
          fromFirestore: (event, _) => Event.fromJson(event.data()!),
          toFirestore: (event, _) => event.toJson(),
        );
  }

  static Future<void> addEvent(Event event, String uId) async {
    return getEventsCollection(uId).doc().set(event);
    // خطوات  ابسط واكثر وضوحا
    // var eventsCollection = getEventsCollection();  //collection
    // DocumentReference<Event> docRef = eventsCollection.doc(); // document
    // event.id = docRef.id ;  // auto id
    // return docRef.set(event);
  }

  static CollectionReference<MyUser> getUsersCollection() {
    return FirebaseFirestore.instance
        .collection(MyUser.collectionName)
        .withConverter(
          fromFirestore: (user, _) => MyUser.fromMap(user.data()!),
          toFirestore: (user, _) => user.toMap(),
        );
  }

  static Future<void> addUser(MyUser user) async {
    return getUsersCollection().doc(user.id).set(user);
  }

  static Future<MyUser?> getUserById(String id) async {
    DocumentSnapshot<Map<String, dynamic>> docSnapshot =
        await FirebaseFirestore.instance
            .collection(MyUser.collectionName)
            .doc(id)
            .get();
    if (docSnapshot.exists) {
      return MyUser.fromMap(docSnapshot.data()!);
    } else {
      return null;
    }
  }

  static Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('⚠️ Error during logout: $e');
    }
  }
}
