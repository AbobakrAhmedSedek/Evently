import 'package:evently/data/repositories/auth_repository.dart';
import 'package:evently/data/repositories/user_repository.dart';
import 'package:evently/domain/model/my_user.dart';
import 'package:evently/providers/event_list_provider.dart';
import 'package:evently/providers/user_provider.dart';
import 'package:evently/ui/authentication/register_screen/register_screen.dart';
import 'package:evently/ui/home/home_screen.dart';
import 'package:evently/ui/widgets/custom_elevated_button.dart';
import 'package:evently/ui/widgets/custom_text_button.dart';
import 'package:evently/ui/widgets/custom_text_field.dart';
import 'package:evently/utils/app_colors.dart';
import 'package:evently/utils/app_styles.dart';
import 'package:evently/utils/assets_manager.dart';
import 'package:evently/utils/dialog_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String routeName = "Login_screen";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // ✅ استخدام الـ Repositories
  final _authRepository = AuthRepository();
  final _userRepository = UserRepository();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Image.asset(AssetsManager.logoTop),
                      SizedBox(height: height * 0.02),

                      // Email Field
                      CustomTextField(
                        textInputType: TextInputType.emailAddress,
                        prefixIcon: Image.asset(AssetsManager.iconEmail),
                        hintText: AppLocalizations.of(context)!.email,
                        controller: _emailController,
                        validator: _validateEmail,
                      ),
                      SizedBox(height: height * 0.02),

                      // Password Field
                      CustomTextField(
                        obscureText: true,
                        obscuringCharacter: '•',
                        textInputType: TextInputType.visiblePassword,
                        controller: _passwordController,
                        validator: _validatePassword,
                        prefixIcon: Image.asset(AssetsManager.iconLock),
                        hintText: AppLocalizations.of(context)!.password,
                        suffixIcon: Image.asset(AssetsManager.iconPassword),
                      ),

                      // Forget Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomTextButton(
                            text: AppLocalizations.of(context)!.forget_password,
                            onPressed: () {
                              // TODO: Implement forgot password
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: height * 0.02),

                      // Login Button
                      CustomElevatedButton(
                        onButtonClick: _loginWithEmail,
                        text: AppLocalizations.of(context)!.login,
                      ),

                      SizedBox(height: height * 0.02),

                      // Create Account Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.do_not_have_an_account,
                            style: AppStyles.medium16Black,
                          ),
                          CustomTextButton(
                            onPressed: () {
                              Navigator.of(
                                context,
                              ).pushNamed(RegisterScreen.routeName);
                            },
                            text: AppLocalizations.of(context)!.create_account,
                          ),
                        ],
                      ),

                      SizedBox(height: height * 0.01),

                      // Divider with "OR"
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 2,
                              color: AppColors.primaryLight,
                              indent: width * 0.02,
                              endIndent: width * 0.02,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)!.or,
                            style: AppStyles.medium16Primary,
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 2,
                              color: AppColors.primaryLight,
                              indent: width * 0.02,
                              endIndent: width * 0.02,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: height * 0.03),

                      // Google Sign-In Button
                      InkWell(
                        onTap: _loginWithGoogle,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primaryLight),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.05,
                            vertical: height * 0.015,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(AssetsManager.iconGoogle),
                              SizedBox(width: width * 0.04),
                              Text(
                                AppLocalizations.of(context)!.login_with_google,
                                style: AppStyles.medium20Primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 20),
                        Text("Logging in..."),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================
  // 🔐 Validation Methods
  // ============================================

  String? _validateEmail(String? text) {
    if (text == null || text.isEmpty) {
      return "Please enter your email";
    }
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );
    if (!emailRegex.hasMatch(text)) {
      return "Please enter a valid email";
    }
    return null;
  }

  String? _validatePassword(String? text) {
    if (text == null || text.isEmpty) {
      return "Please enter a password";
    }
    if (text.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  // ============================================
  // 📧 Email Login
  // ============================================

  Future<void> _loginWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // ✅ 1. تسجيل الدخول عبر Repository
      final credential = await _authRepository.signInWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // ✅ 2. الحصول على بيانات المستخدم من Firestore
      final myUser = await _userRepository.getUserById(credential.user!.uid);

      if (!mounted) return;

      if (myUser == null) {
        setState(() => _isLoading = false);
        _showError("User data not found in database");
        return;
      }

      // ✅ 3. حفظ البيانات في Provider
      await _setupUserSession(myUser);

      if (!mounted) return;
      setState(() => _isLoading = false);

      // ✅ 4. الانتقال للـ Home
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(_getFirebaseErrorMessage(e.code));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError("An unexpected error occurred. Please try again.");
    }
  }

  // ============================================
  // 🔐 Google Login
  // ============================================

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      // ✅ 1. تسجيل الدخول عبر Google
      final userCredential = await _authRepository.signInWithGoogle();

      if (userCredential == null) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showError("Google sign-in was cancelled");
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
      await _setupUserSession(myUser); 

      if (!mounted) return;
      setState(() => _isLoading = false);

      // ✅ 4. الانتقال للـ Home
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError("Google sign-in failed. Please try again.");
      print('Google Sign-In Error: $e');
    }
  }

  // ============================================
  // 🛠️ Helper Methods
  // ============================================

  /// إعداد جلسة المستخدم (Provider + Events)
  /// يحمل بيانات المستخدم ويجلب الأحداث الخاصة به
  /// قبل الانتقال للصفحة الرئيسية
  Future<void> _setupUserSession(MyUser user) async {
    try {
      // 1. حفظ بيانات المستخدم
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setUser(user);

      // 2. جلب الأحداث (مع timeout لتفادي التعليق)
      final eventListProvider = Provider.of<EventListProvider>(
        context,
        listen: false,
      );

      // ⏱️ إضافة timeout للأحداث
      await eventListProvider
          .getAllEvents(user.id)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('⚠️ Event loading timeout - continuing with empty list');
            },
          );

      eventListProvider.changeSelectedIndex(0);
    } catch (e) {
      print('⚠️ Error in _setupUserSession: $e');
    }
  }

  void _showError(String message) {
    DialogUtils.showErrorDialog(
      context: context,
      title: "Login Failed",
      content: message,
    );
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
// -----------------------------------------------------------------------

// import 'package:evently/model/my_user.dart';
// import 'package:evently/providers/event_list_provider.dart';
// import 'package:evently/providers/user_provider.dart';
// import 'package:evently/ui/authentication/register_screen/register_screen.dart';
// import 'package:evently/ui/home/home_screen.dart';
// import 'package:evently/ui/widgets/custom_elevated_button.dart';
// import 'package:evently/ui/widgets/custom_text_button.dart';
// import 'package:evently/ui/widgets/custom_text_field.dart';
// import 'package:evently/utils/app_colors.dart';
// import 'package:evently/utils/app_styles.dart';
// import 'package:evently/utils/assets_manager.dart';
// import 'package:evently/utils/dialog_utils.dart';
// import 'package:evently/utils/firebase_utils.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:provider/provider.dart';

// class LoginScreen extends StatelessWidget {
//   LoginScreen({super.key});
//   static const String routeName = "Login_screen";

//   final formKey = GlobalKey<FormState>();
//   final TextEditingController emailController = TextEditingController(
//     text: "123852zza@gmail.com",
//   );
//   final TextEditingController passwordController = TextEditingController(
//     text: "123456",
//   );

//   @override
//   Widget build(BuildContext context) {
//     var width = MediaQuery.of(context).size.width;
//     var height = MediaQuery.of(context).size.height;
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: SingleChildScrollView(
//             child: Form(
//               key: formKey,
//               child: Column(
//                 children: [
//                   Image.asset(AssetsManager.logoTop),
//                   SizedBox(height: height * 0.02),

//                   CustomTextField(
//                     textInputType: TextInputType.emailAddress,
//                     prefixIcon: Image.asset(AssetsManager.iconEmail),
//                     hintText: AppLocalizations.of(context)!.email,
//                     controller: emailController,
//                     validator: (text) {
//                       if (text == null || text.isEmpty) {
//                         return "enter valid email";
//                       }
//                       final bool emailValid = RegExp(
//                         r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
//                       ).hasMatch(text);
//                       if (!emailValid) {
//                         return "enter valid email";
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: height * 0.02),

//                   CustomTextField(
//                     obscureText: true,
//                     obscuringCharacter: '•',
//                     textInputType: TextInputType.visiblePassword,
//                     controller: passwordController,
//                     validator: (text) {
//                       if (text == null || text.isEmpty) {
//                         return "enter valid password";
//                       }
//                       if (text.length < 6) {
//                         return "password must be at least 6 characters";
//                       }
//                       return null;
//                     },
//                     prefixIcon: Image.asset(AssetsManager.iconLock),
//                     hintText: AppLocalizations.of(context)!.password,
//                     suffixIcon: Image.asset(AssetsManager.iconPassword),
//                   ),

//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       CustomTextButton(
//                         text: AppLocalizations.of(context)!.forget_password,
//                       ),
//                     ],
//                   ),

//                   SizedBox(height: height * 0.02),

//                   CustomElevatedButton(
//                     onButtonClick: () => login(context),
//                     text: AppLocalizations.of(context)!.login,
//                   ),

//                   SizedBox(height: height * 0.02),

//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         AppLocalizations.of(context)!.do_not_have_an_account,
//                         style: AppStyles.medium16Black,
//                       ),
//                       CustomTextButton(
//                         onPressed: () {
//                           Navigator.of(
//                             context,
//                           ).pushNamed(RegisterScreen.routeName);
//                         },
//                         text: AppLocalizations.of(context)!.create_account,
//                       ),
//                     ],
//                   ),

//                   SizedBox(height: height * 0.01),

//                   Row(
//                     children: [
//                       Expanded(
//                         child: Divider(
//                           thickness: 2,
//                           color: AppColors.primaryLight,
//                           indent: width * 0.02,
//                           endIndent: width * 0.02,
//                         ),
//                       ),
//                       Text(
//                         AppLocalizations.of(context)!.or,
//                         style: AppStyles.medium16Primary,
//                       ),
//                       Expanded(
//                         child: Divider(
//                           thickness: 2,
//                           color: AppColors.primaryLight,
//                           indent: width * 0.02,
//                           endIndent: width * 0.02,
//                         ),
//                       ),
//                     ],
//                   ),

//                   SizedBox(height: height * 0.03),

//                   Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(color: AppColors.primaryLight),
//                     ),
//                     padding: EdgeInsets.symmetric(
//                       horizontal: width * 0.05,
//                       vertical: height * 0.015,
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Image.asset(AssetsManager.iconGoogle),
//                         SizedBox(width: width * 0.04),
//                         Text(
//                           AppLocalizations.of(context)!.login_with_google,
//                           style: AppStyles.medium20Primary,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> login(BuildContext context) async {
//     if (!formKey.currentState!.validate()) return;

//     DialogUtils.showLoadingDialog(context: context, message: "Logging in...");

//     try {
//       // تسجيل الدخول
//       final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: emailController.text,
//         password: passwordController.text,
//       );

//       // جلب بيانات المستخدم من Firestore
//       final MyUser? myUser = await FirebaseUtils.getUserById(
//         credential.user!.uid,
//       );
//       if (!context.mounted) return;
//       DialogUtils.hideLoadingDialog(context: context);

//       if (myUser != null) {
//         //  حفظ بيانات المستخدم في ال Provider
//         final userProvider = Provider.of<UserProvider>(context, listen: false);
//         userProvider.setUser(myUser);
//         var eventListProvider = Provider.of<EventListProvider>(
//           context,
//           listen: false,
//         );
//         // ✅ تحميل الأحداث الخاصة بالمستخدم الحالي فقط
//         await eventListProvider.getAllEvents(userProvider.user!.id);

//         eventListProvider.changeSelectedIndex(0);
//         if (!context.mounted) return;
//         // عرض رسالة النجاح
//         DialogUtils.showErrorDialog(
//           context: context,
//           title: "Success",
//           content: "Logged in successfully.",
//           positiveActionName: "OK",
//           onPositiveActionClick: () {
//             Navigator.pushReplacementNamed(context, HomeScreen.routeName);
//           },
//         );
//       } else {
//         if (!context.mounted) return;

//         DialogUtils.showErrorDialog(
//           context: context,
//           title: "Error",
//           content: "User data not found in Firestore.",
//         );
//       }
//     } on FirebaseAuthException catch (e) {
//       if (!context.mounted) return;
//       DialogUtils.hideLoadingDialog(context: context);
//       String message;
//       if (e.code == 'user-not-found') {
//         message = "No user found for that email.";
//       } else if (e.code == 'wrong-password') {
//         message = "Wrong password provided for that user.";
//       } else if (e.code == 'invalid-email') {
//         message = "The email address is badly formatted.";
//       } else {
//         message = "An error occurred. Please try again.";
//       }
//       if (!context.mounted) return;
//       DialogUtils.showErrorDialog(
//         context: context,
//         title: "Error",
//         content: message,
//       );
//     }
//   }
// }
