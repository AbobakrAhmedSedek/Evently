
import 'package:firebase_auth/firebase_auth.dart';
import 'package:evently/services/firebase_auth_service.dart';
import 'package:evently/services/google_sign_in_service.dart';
import 'package:evently/data/repositories/user_repository.dart';
import 'package:evently/domain/model/my_user.dart';

/// Repository للتعامل مع جميع عمليات المصادقة
/// يتبع مبدأ Dependency Injection
class AuthRepository {
  final FirebaseAuthService _authService;
  final GoogleSignInService _googleSignInService;
  final UserRepository _userRepository;

  AuthRepository({
    FirebaseAuthService? authService,
    GoogleSignInService? googleSignInService,
    UserRepository? userRepository,
  })  : _authService = authService ?? FirebaseAuthService(),
        _googleSignInService = googleSignInService ?? GoogleSignInService(),
        _userRepository = userRepository ?? UserRepository();

  // ============================================
  // 📧 Email & Password Authentication
  // ============================================

  /// تسجيل مستخدم جديد بالبريد والباسورد
  Future<UserCredential> registerWithEmailPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    // 1. إنشاء حساب في Firebase Auth
    final credential = await _authService.createUserWithEmailPassword(
      email: email,
      password: password,
    );

    // 2. حفظ بيانات المستخدم في Firestore
    final user = MyUser(
      id: credential.user!.uid,
      name: name,
      email: email,
    );
    await _userRepository.createUser(user);

    return credential;
  }

  /// تسجيل الدخول بالبريد والباسورد
  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _authService.signInWithEmailPassword(
      email: email,
      password: password,
    );
  }

  // ============================================
  // 🔐 Google Sign-In
  // ============================================

  /// تسجيل الدخول عبر Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. المصادقة عبر Google
      final googleUser = await _googleSignInService.authenticate();
      if (googleUser == null) return null;

      // 2. الحصول على Firebase Credential
      final credential = await _googleSignInService.getFirebaseCredential(
        googleUser,
      );

      // 3. تسجيل الدخول في Firebase
      final userCredential = await _authService.signInWithCredential(credential);

      // 4. حفظ/تحديث بيانات المستخدم في Firestore
      if (userCredential.user != null) {
        await _userRepository.saveOrUpdateUser(
          MyUser(
            id: userCredential.user!.uid,
            name: userCredential.user!.displayName ?? 'User',
            email: userCredential.user!.email!,
          ),
        );
      }

      return userCredential;
    } catch (e) {
      print('❌ Google Sign-In Error in Repository: $e');
      return null;
    }
  }

  // ============================================
  // 🔑 Password Management
  // ============================================

  /// إرسال رابط إعادة تعيين كلمة المرور
  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  /// تحديث كلمة المرور
  Future<void> updatePassword(String newPassword) async {
    await _authService.updatePassword(newPassword);
  }

  // ============================================
  // 👤 Account Management
  // ============================================

  /// تحديث البريد الإلكتروني
  Future<void> updateEmail(String newEmail) async {
    await _authService.updateEmail(newEmail);
    
    // تحديث البريد في Firestore أيضاً
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      await _userRepository.updateUserField(
        currentUser.uid,
        'email',
        newEmail,
      );
    }
  }

  /// حذف الحساب
  Future<void> deleteAccount() async {
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      // حذف من Firestore أولاً
      await _userRepository.deleteUser(currentUser.uid);
      // ثم حذف من Firebase Auth
      await _authService.deleteAccount();
    }
  }

  // ============================================
  // 🚪 Logout & Session
  // ============================================

  /// تسجيل الخروج (من Firebase و Google)
  Future<void> logout() async {
    try {
      await Future.wait([
        _authService.signOut(),
        _googleSignInService.disconnect(),
      ]);
    } catch (e) {
      print('❌ Logout Error: $e');
      rethrow;
    }
  }

  // ============================================
  // 📊 User State
  // ============================================

  /// الحصول على المستخدم الحالي
  User? get currentUser => _authService.currentUser;

  /// stream للاستماع لحالة المصادقة
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  /// التحقق من حالة تسجيل الدخول
  bool get isSignedIn => _authService.currentUser != null;

  /// الحصول على UID المستخدم الحالي
  String? get currentUserId => _authService.currentUser?.uid;

  /// الحصول على البريد الإلكتروني للمستخدم الحالي
  String? get currentUserEmail => _authService.currentUser?.email;
}