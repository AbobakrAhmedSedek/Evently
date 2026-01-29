import 'package:firebase_auth/firebase_auth.dart';

/// خدمة Firebase Auth فقط - لا تتعامل مع Firestore
class FirebaseAuthService {
  final FirebaseAuth _auth;

  FirebaseAuthService({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  /// تسجيل مستخدم جديد
  Future<UserCredential> createUserWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// تسجيل الدخول
  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// تسجيل الدخول بـ Credential (للـ Google/Facebook)
  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    return await _auth.signInWithCredential(credential);
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  /// stream لحالة المصادقة
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// إعادة تعيين كلمة المرور
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// تحديث البريد الإلكتروني (مع التحقق)
  Future<void> updateEmail(String newEmail) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.verifyBeforeUpdateEmail(newEmail);
    }
  }

  /// تحديث كلمة المرور
  Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    }
  }

  /// حذف الحساب
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.delete();
    }
  }

  /// إعادة المصادقة (مطلوبة لعمليات حساسة)
  Future<UserCredential> reauthenticateWithCredential(
    AuthCredential credential,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }
    return await user.reauthenticateWithCredential(credential);
  }

  /// إرسال بريد تحقق
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// التحقق من حالة البريد الإلكتروني
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  /// تحديث الاسم
  Future<void> updateDisplayName(String displayName) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
    }
  }

  /// تحديث الصورة الشخصية
  Future<void> updatePhotoURL(String photoURL) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updatePhotoURL(photoURL);
    }
  }

  /// إعادة تحميل بيانات المستخدم
  Future<void> reload() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
    }
  }
}