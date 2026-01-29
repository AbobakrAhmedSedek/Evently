import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evently/domain/model/my_user.dart';

/// Repository للتعامل مع بيانات المستخدمين في Firestore
/// مسؤول فقط عن CRUD operations
class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// الحصول على Collection المستخدمين مع Converter
  CollectionReference<MyUser> get _usersCollection {
    return _firestore
        .collection(MyUser.collectionName)
        .withConverter<MyUser>(
          fromFirestore:
              (DocumentSnapshot<Map<String, dynamic>> snapshot, _) =>
                  MyUser.fromMap(snapshot.data()!),
          toFirestore: (MyUser user, _) => user.toMap(),
        );
  }

  // ============================================
  // ✍️ Create & Update
  // ============================================

  /// إنشاء مستخدم جديد (للتسجيل الأول)
  Future<void> createUser(MyUser user) async {
    await _usersCollection.doc(user.id).set(user);
  }

  /// حفظ أو تحديث بيانات المستخدم (للـ Google Sign-In)
  /// يتحقق من وجود المستخدم أولاً
  Future<void> saveOrUpdateUser(MyUser user) async {
    final docRef = _usersCollection.doc(user.id);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      // تحديث البيانات الأساسية فقط
      await docRef.update({
        'name': user.name,
        'email': user.email,
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } else {
      // إنشاء مستخدم جديد
      await docRef.set(user, SetOptions(merge: true));
    }
  }

  /// تحديث بيانات المستخدم
  Future<void> updateUser(MyUser user) async {
    await _usersCollection.doc(user.id).update(user.toMap());
  }

  /// تحديث حقل معين
  Future<void> updateUserField(
    String userId,
    String field,
    dynamic value,
  ) async {
    await _usersCollection.doc(userId).update({field: value});
  }

  // ============================================
  // 📖 Read
  // ============================================

  /// الحصول على بيانات المستخدم بواسطة ID
  Future<MyUser?> getUserById(String userId) async {
    final docSnapshot = await _usersCollection.doc(userId).get();
    return docSnapshot.exists ? docSnapshot.data() : null;
  }

  /// stream للاستماع لتغييرات بيانات المستخدم
  Stream<MyUser?> getUserStream(String userId) {
    return _usersCollection
        .doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.exists ? snapshot.data() : null);
  }

  /// الحصول على جميع المستخدمين (للـ Admin)
  Future<List<MyUser>> getAllUsers() async {
    final querySnapshot = await _usersCollection.get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  // ============================================
  // 🗑️ Delete
  // ============================================

  /// حذف بيانات المستخدم

  Future<void> deleteUser(String userId) async {
    await _usersCollection.doc(userId).delete();
  }

  // ============================================
  // 🔍 Query Methods
  // ============================================

  /// البحث عن مستخدم بالبريد الإلكتروني
  Future<MyUser?> getUserByEmail(String email) async {
    final querySnapshot =
        await _usersCollection.where('email', isEqualTo: email).limit(1).get();

    if (querySnapshot.docs.isEmpty) return null;
    return querySnapshot.docs.first.data();
  }

  /// البحث عن مستخدمين بالاسم
  Future<List<MyUser>> searchUsersByName(String name) async {
    final querySnapshot =
        await _usersCollection
            .where('name', isGreaterThanOrEqualTo: name)
            .where('name', isLessThanOrEqualTo: '$name\uf8ff')
            .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  /// التحقق من وجود المستخدم
  Future<bool> userExists(String userId) async {
    final docSnapshot = await _usersCollection.doc(userId).get();
    return docSnapshot.exists;
  }
}
