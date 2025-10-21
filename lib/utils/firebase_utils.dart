import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evently/model/event.dart';

class FirebaseUtils {
  static CollectionReference<Event> getEventsCollection() {
    return FirebaseFirestore.instance
        .collection(Event.collectionName)
        .withConverter(
          fromFirestore: (event, _) => Event.fromJson(event.data()!),
          toFirestore: (event, _) => event.toJson(),
        );
  }

  static Future<void> addEvent(Event event) async {
    return getEventsCollection().doc().set(event);
    // خطوات  ابسط واكثر وضوحا
    // var eventsCollection = getEventsCollection();  //collection
    // DocumentReference<Event> docRef = eventsCollection.doc(); // document
    // event.id = docRef.id ;  // auto id
    // return docRef.set(event);
  }
}
