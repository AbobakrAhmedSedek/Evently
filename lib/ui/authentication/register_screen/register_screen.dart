
import 'package:evently/data/repositories/auth_repository.dart';
import 'package:evently/ui/authentication/login/login_screen.dart';
import 'package:evently/ui/widgets/custom_elevated_button.dart';
import 'package:evently/ui/widgets/custom_text_button.dart';
import 'package:evently/ui/widgets/custom_text_field.dart';
import 'package:evently/utils/app_styles.dart';
import 'package:evently/utils/assets_manager.dart';
import 'package:evently/utils/dialog_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = "register_screen";

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authRepository = AuthRepository(); // ✅ استخدام الـ Repository

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rePasswordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _rePasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.create_account,
          style: AppStyles.medium16Primary,
        ),
      ),
      body: SafeArea(
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
                    prefixIcon: Image.asset(AssetsManager.iconEmail),
                    hintText: AppLocalizations.of(context)!.email,
                    controller: _emailController,
                    textInputType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  SizedBox(height: height * 0.02),

                  // Name Field
                  CustomTextField(
                    prefixIcon: Image.asset(AssetsManager.iconName),
                    hintText: AppLocalizations.of(context)!.name,
                    controller: _nameController,
                    validator: _validateName,
                  ),
                  SizedBox(height: height * 0.02),

                  // Password Field
                  CustomTextField(
                    obscureText: true,
                    obscuringCharacter: '•',
                    prefixIcon: Image.asset(AssetsManager.iconLock),
                    hintText: AppLocalizations.of(context)!.password,
                    suffixIcon: Image.asset(AssetsManager.iconPassword),
                    controller: _passwordController,
                    validator: _validatePassword,
                  ),
                  SizedBox(height: height * 0.02),

                  // Re-Password Field
                  CustomTextField(
                    obscureText: true,
                    obscuringCharacter: '•',
                    prefixIcon: Image.asset(AssetsManager.iconLock),
                    hintText: AppLocalizations.of(context)!.re_password,
                    suffixIcon: Image.asset(AssetsManager.iconPassword),
                    controller: _rePasswordController,
                    validator: _validateRePassword,
                  ),

                  SizedBox(height: height * 0.03),

                  // Register Button
                  CustomElevatedButton(
                    onButtonClick: _register,
                    text: AppLocalizations.of(context)!.create_account,
                  ),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.already_have_account,
                        style: AppStyles.medium16Black,
                      ),
                      CustomTextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            LoginScreen.routeName,
                          );
                        },
                        text: AppLocalizations.of(context)!.login,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
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

  String? _validateName(String? text) {
    if (text == null || text.trim().isEmpty) {
      return "Please enter your name";
    }
    if (text.trim().length < 2) {
      return "Name must be at least 2 characters";
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

  String? _validateRePassword(String? text) {
    if (text == null || text.isEmpty) {
      return "Please confirm your password";
    }
    if (text != _passwordController.text) {
      return "Passwords do not match";
    }
    return null;
  }

  // ============================================
  // 📝 Registration Logic
  // ============================================

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    DialogUtils.showLoadingDialog(
      context: context,
      message: "Creating your account...",
    );

    try {
      // ✅ استخدام الـ Repository بدلاً من Firebase مباشرة
      await _authRepository.registerWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );

      if (!mounted) return;
      DialogUtils.hideLoadingDialog(context: context);

      // Success Dialog
      DialogUtils.showErrorDialog(
        context: context,
        title: "Success",
        content: "Your account has been created successfully!",
        positiveActionName: "OK",
        onPositiveActionClick: () {
          Navigator.pushReplacementNamed(
            context,
            LoginScreen.routeName,
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      DialogUtils.hideLoadingDialog(context: context);

      String errorMessage = _getErrorMessage(e.code);
      
      DialogUtils.showErrorDialog(
        context: context,
        title: "Registration Failed",
        content: errorMessage,
      );
    } catch (e) {
      if (!mounted) return;
      DialogUtils.hideLoadingDialog(context: context);
      
      DialogUtils.showErrorDialog(
        context: context,
        title: "Error",
        content: "An unexpected error occurred. Please try again.",
      );
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


// ----------------------------------------------------------------------------

// import 'package:evently/domain/model/my_user.dart';
//  import 'package:evently/ui/authentication/login/login_screen.dart';
// import 'package:evently/ui/widgets/custom_elevated_button.dart';
// import 'package:evently/ui/widgets/custom_text_button.dart';
// import 'package:evently/ui/widgets/custom_text_field.dart';
// import 'package:evently/utils/app_styles.dart';
// import 'package:evently/utils/assets_manager.dart';
// import 'package:evently/utils/dialog_utils.dart';
// import 'package:evently/utils/firebase_utils.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// class RegisterScreen extends StatefulWidget {
//   static const String routeName = "register_screen";

//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   var formKey = GlobalKey<FormState>();

//   // @override
//   TextEditingController emailController = TextEditingController(
//     text: "123852zza@gmail.com",
//   );

//   TextEditingController passwordController = TextEditingController(
//     text: "123456",
//   );

//   TextEditingController rePasswordController = TextEditingController(
//     text: "123456",
//   );

//   TextEditingController nameController = TextEditingController(
//     text: "abobakr",
//   );

//   @override
//   Widget build(BuildContext context) {
//     // var width = MediaQuery.of(context).size.width;
//     var height = MediaQuery.of(context).size.height;
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text(
//           AppLocalizations.of(context)!.create_account,
//           style: AppStyles.medium16Primary,
//         ),
//       ),
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
//                     prefixIcon: Image.asset(AssetsManager.iconEmail),
//                     hintText: AppLocalizations.of(context)!.email,
//                     controller: emailController,
//                     textInputType: TextInputType.emailAddress,

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
//                     prefixIcon: Image.asset(AssetsManager.iconName),
//                     hintText: AppLocalizations.of(context)!.name,
//                     controller: nameController,
//                     validator: (text) {
//                       if (text == null || text.trim().isEmpty) {
//                         return "enter valid name";
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: height * 0.02),
//                   CustomTextField(
//                     obscureText: true,
//                     obscuringCharacter: '•',
//                     prefixIcon: Image.asset(AssetsManager.iconLock),
//                     hintText: AppLocalizations.of(context)!.password,
//                     suffixIcon: Image.asset(
//                       AssetsManager.iconPassword,
//                       // width: width * .001,
//                       // height: height * .001,
//                       // fit: BoxFit.contain,
//                     ),
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
//                   ),
//                   SizedBox(height: height * 0.02),
//                   CustomTextField(
//                     obscureText: true,
//                     obscuringCharacter: '•',
//                     prefixIcon: Image.asset(AssetsManager.iconLock),
//                     hintText: AppLocalizations.of(context)!.re_password,
//                     suffixIcon: Image.asset(AssetsManager.iconPassword),
//                     controller: rePasswordController,
//                     validator: (text) {
//                       if (text == null || text.isEmpty) {
//                         return "enter valid password";
//                       }
//                       if (text.length < 6) {
//                         return "password must be at least 6 characters";
//                       }
//                       if (text != passwordController.text) {
//                         return "passwords do not match";
//                       }
//                       return null;
//                     },
//                   ),

//                   SizedBox(height: height * 0.02),
//                   CustomElevatedButton(
//                     onButtonClick: register,
//                     text: AppLocalizations.of(context)!.create_account,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         AppLocalizations.of(context)!.already_have_account,
//                         style: AppStyles.medium16Black,
//                       ),
//                       CustomTextButton(
//                         onPressed: () {},
//                         text: AppLocalizations.of(context)!.login,
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: height * 0.01),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void register() async {
//     // Registration logic to be implemented
//     if (formKey.currentState!.validate()) {
//       DialogUtils.showLoadingDialog(
//         context: context,
//         message: "Creating your account...",
//       );
//       try {
//         final credential = await FirebaseAuth.instance
//             .createUserWithEmailAndPassword(
//               email: emailController.text,
//               password: passwordController.text,
//             );
//         //      FirebaseUtils.getUsersCollection().doc(credential.user!.uid).set(
//         //   MyUser(
//         //     id: credential.user!.uid,
//         //     name: nameController.text,
//         //     email: emailController.text,
//         //   ),
//         // );
//           await FirebaseUtils.addUser( 
//           MyUser(
//             id: credential.user!.uid,
//             name: nameController.text,
//             email: emailController.text,
//           ),
//         );
//         if (!context.mounted) return;
//         DialogUtils.hideLoadingDialog(context:context);
//         print("User registered: ${credential.user?.email}");
//          if (!context.mounted) return;
//         DialogUtils.showErrorDialog(
//           context: context ,
//           title: "Success",
//           content: "Your account has been created successfully.",
//           positiveActionName: "OK",
//           onPositiveActionClick: () {
//             // Navigate to home screen or another screen after successful registration
//             Navigator.pushReplacementNamed(
//               formKey.currentContext!, LoginScreen.routeName
//             );
//           },
//         );
//       } on FirebaseAuthException catch (e) {
//         if (e.code == 'weak-password') {
//           DialogUtils.hideLoadingDialog(context: context);
//           DialogUtils.showErrorDialog(
//             context:context,
//             title: "Error",
//             content: "The password provided is too weak.",
//           );
//           print('The password provided is too weak.');
//         } else if (e.code == 'email-already-in-use') {
//           DialogUtils.hideLoadingDialog(context:context);
//           if (!context.mounted) return;
//           DialogUtils.showErrorDialog(
//             context:context,
//             title: "Error",
//             content: "The account already exists for that email.",
//           );
//           print('The account already exists for that email.');
//         }
//       } catch (e) {
//         DialogUtils.hideLoadingDialog(context: formKey.currentContext!);
//         DialogUtils.showErrorDialog(
//           context: context,
//           title: "Error",
//           content: "An unexpected error occurred. Please try again.",
//         );
//         print(e.toString());
//       }
//     }
//   }
// }
