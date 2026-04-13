import 'package:evently/data/repositories/auth_repository.dart';
import 'package:evently/ui/authentication/register_screen/register_navigator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreenViewModel extends ChangeNotifier {
  
  late RegisterNavigator navigator;

  final _authRepository = AuthRepository();
  void register(String email, String password, String name) async {
    // DialogUtils.showLoadingDialog(
    //     context: context,
    //     message: "Creating your account...",
    //   );

    navigator.showLogin(message: "Creating your account...");

    try {
      // ✅ استخدام الـ Repository بدلاً من Firebase مباشرة
      await _authRepository.registerWithEmailPassword(
        email: email,
        password: password,
        name: name,
      );

      // if (!mounted) return;
      // DialogUtils.hideLoadingDialog(context: context);

      navigator.hideLogin();

      // Success Dialog
      // DialogUtils.showErrorDialog(
      //   context: context,
      //   title: "Success",
      //   content: "Your account has been created successfully!",
      //   positiveActionName: "OK",
      //   onPositiveActionClick: () {
      //     Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      //   },
      // );

      navigator.showMessage(
        message: "Your account has been created successfully!",
      );
    } on FirebaseAuthException catch (e) {
      // if (!mounted) return;
      // DialogUtils.hideLoadingDialog(context: context);

      navigator.hideLogin();

      String errorMessage = _getErrorMessage(e.code);
      navigator.showMessage(message: errorMessage);

      // DialogUtils.showErrorDialog(
      //   context: context,
      //   title: "Registration Failed",
      //   content: errorMessage,
      // );
    } catch (e) {
      // if (!mounted) return;
      // DialogUtils.hideLoadingDialog(context: context);
      navigator.hideLogin();

      navigator.showMessage(
        message: "An unexpected error occurred. Please try again.",
      );
      // DialogUtils.showErrorDialog(
      //   context: context,
      //   title: "Error",
      //   content: "An unexpected error occurred. Please try again.",
      // );
    }
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return 'The password is too weak. Please use a stronger password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return 'Registration failed. Please try again.';
    }
  }
}
