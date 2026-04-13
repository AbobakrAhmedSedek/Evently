import 'package:evently/data/repositories/auth_repository.dart';
import 'package:evently/data/repositories/user_repository.dart';
import 'package:evently/domain/model/my_user.dart';
import 'package:evently/ui/authentication/login/login_navigator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreenViewModel extends ChangeNotifier {
  LoginNavigator? loginNavigator;
  final AuthRepository _authRepository = AuthRepository();
  final UserRepository _userRepository = UserRepository();

  bool _isDisposed = false;

  bool isLoading = false;
  @override
  void dispose() {
    _isDisposed = true;
    loginNavigator = null;
    super.dispose();
  }

  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  void logiginWithEmail(String email, String password) async {
    isLoading = true;
    _notify();
    try {
      // ✅ 1. تسجيل الدخول عبر Repository

      final credential = await _authRepository.signInWithEmailPassword(
        email: email,
        password: password,
      );

      // ✅ 2. الحصول على بيانات المستخدم من Firestore
      final myUser = await _userRepository.getUserById(credential.user!.uid);

      if (myUser == null) {
        isLoading = false;

        _notify();
        if (loginNavigator == null) return;
        loginNavigator!.showMessage(message: "User data not found in database");

        return;
      }

      // ✅ 3. حفظ البيانات في Provider

      isLoading = false;
      _notify();
       // ✅ 4. الانتقال للـ Home
      if (loginNavigator == null) return;
      await loginNavigator!.navigateToHomeScreen(myUser);
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      _notify();
      if (loginNavigator == null) return;
      loginNavigator!.showMessage(message: _getFirebaseErrorMessage(e.code));
    } catch (e) {
      isLoading = false;
      _notify();
      if (loginNavigator == null) return;
      loginNavigator!.showMessage(
        message: "An unexpected error occurred. Please try again.",
      );
    }
  }

  void logiginWithGoogle() async {
    isLoading = true;
    _notify();
    try {
      // ✅ 1. تسجيل الدخول عبر Google
      final userCredential = await _authRepository.signInWithGoogle();

      if (userCredential == null) {
        isLoading = false;
        _notify();
        if (loginNavigator == null) return;
        loginNavigator!.showMessage(message: "Google sign-in was cancelled");
        return;
      }

      final firebaseUser = userCredential.user!;

      // ✅ 2. الحصول على بيانات المستخدم من Firestore
      MyUser? myUser = await _userRepository.getUserById(firebaseUser.uid);
      // 3.  إذا كان المستخدم جديد، نقوم بإنشاء حساب له في Firestore
      if (myUser == null) {
        myUser = MyUser(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'User',
        );
        //  حفظ المستخدم الجديد في Firestore
        await _userRepository.createUser(myUser);
      }

      // ✅ 4. حفظ البيانات في Provider

      isLoading = false;
    _notify();

      // ✅ 4. الانتقال للـ Home
      if (loginNavigator == null) return;
      await loginNavigator!.navigateToHomeScreen(myUser);
    } catch (e) {
      isLoading = false;
      _notify();
      if (loginNavigator == null) return;
      loginNavigator!.showMessage(
        message: "Google sign-in failed. Please try again.",
      );
      print('Google Sign-In Error: $e');
    }
  }

  /// تحويل أكواد أخطاء Firebase لرسائل واضحة
  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return 'Login failed. Please try again.';
    }
  }
}
