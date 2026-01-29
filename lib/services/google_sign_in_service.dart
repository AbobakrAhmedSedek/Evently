import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn;

  GoogleSignInService({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  /// تهيئة Google Sign-In مع الإعدادات المطلوبة
  Future<void> initialize() async {
    await _googleSignIn.initialize(
      serverClientId:
          '555728337939-lgi97h888a6aska0is3ukf7kboig1hn2.apps.googleusercontent.com',
    );
  }

  /// تسجيل الدخول عبر Google
  Future<GoogleSignInAccount?> authenticate() async {
    try {
      // ✅ تأكد من التهيئة أولاً
      await initialize();

      // ✅ استخدام authenticate() في الإصدار 7.x
      return await _googleSignIn.authenticate();
    } catch (e) {
      print('❌ Google Authentication Error: $e');
      return null;
    }
  }

  /// الحصول على Firebase Credential
  Future<OAuthCredential> getFirebaseCredential(
    GoogleSignInAccount googleUser,
  ) async {
    try {
      // ✅ في الإصدار 7.x: authentication هو property وليس method
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // ✅ في الإصدار 7.x: idToken متاح مباشرة، لكن accessToken يحتاج authorizationClient
      // لكن لـ Firebase، نحتاج فقط idToken!
      return GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        // accessToken اختياري لـ Firebase، idToken كافٍ
      );
    } catch (e) {
      print('❌ Error getting Firebase Credential: $e');
      rethrow;
    }
  }

  /// تسجيل الخروج
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
    } catch (e) {
      print('❌ Google Disconnect Error: $e');
    }
  }
}

// -------------------------------------------------------------------

// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class GoogleSignInService {
//   final GoogleSignIn _googleSignIn;

//   GoogleSignInService({GoogleSignIn? googleSignIn})
//     : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

//   /// تسجيل الدخول عبر Google
//   Future<GoogleSignInAccount?> authenticate() async {
//     try {
//       return await _googleSignIn.authenticate(scopeHint: ['email']);
//     } catch (e) {
//       print('❌ Google Authentication Error: $e');
//       return null;
//     }
//   }

//   /// الحصول على Firebase Credential
//   Future<OAuthCredential> getFirebaseCredential(
//     GoogleSignInAccount googleUser,
//   ) async {
//     try {
//       final String? idToken = googleUser.authentication.idToken;
//       final authClient = googleUser.authorizationClient;
//       final authorization = await authClient.authorizationForScopes(['email']);

//       if (authorization == null) {
//         throw Exception('Failed to get accessToken');
//       }

//       return GoogleAuthProvider.credential(
//         accessToken: authorization.accessToken,
//         idToken: idToken,
//       );
//     } catch (e) {
//       print('❌ Error getting Firebase Credential: $e');
//       rethrow;
//     }
//   }

//   /// تسجيل الخروج (disconnect فقط)
//   Future<void> disconnect() async {
//     try {
//       await _googleSignIn.disconnect();
//     } catch (e) {
//       print('❌ Google Disconnect Error: $e');
//     }
//   }
// }
