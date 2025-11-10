import 'package:evently/model/my_user.dart';
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
import 'package:evently/utils/firebase_utils.dart';
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
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController(
    text: "123852zza@gmail.com",
  );
  final TextEditingController passwordController = TextEditingController(
    text: "123456",
  );
  
  // ✅ متغير للتحكم في الـ loading
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Image.asset(AssetsManager.logoTop),
                      SizedBox(height: height * 0.02),

                      CustomTextField(
                        textInputType: TextInputType.emailAddress,
                        prefixIcon: Image.asset(AssetsManager.iconEmail),
                        hintText: AppLocalizations.of(context)!.email,
                        controller: emailController,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return "enter valid email";
                          }
                          final bool emailValid = RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                          ).hasMatch(text);
                          if (!emailValid) {
                            return "enter valid email";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: height * 0.02),

                      CustomTextField(
                        obscureText: true,
                        obscuringCharacter: '•',
                        textInputType: TextInputType.visiblePassword,
                        controller: passwordController,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return "enter valid password";
                          }
                          if (text.length < 6) {
                            return "password must be at least 6 characters";
                          }
                          return null;
                        },
                        prefixIcon: Image.asset(AssetsManager.iconLock),
                        hintText: AppLocalizations.of(context)!.password,
                        suffixIcon: Image.asset(AssetsManager.iconPassword),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomTextButton(
                            text: AppLocalizations.of(context)!.forget_password,
                          ),
                        ],
                      ),

                      SizedBox(height: height * 0.02),

                      CustomElevatedButton(
                        onButtonClick: login,
                        text: AppLocalizations.of(context)!.login,
                      ),

                      SizedBox(height: height * 0.02),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.do_not_have_an_account,
                            style: AppStyles.medium16Black,
                          ),
                          CustomTextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(RegisterScreen.routeName);
                            },
                            text: AppLocalizations.of(context)!.create_account,
                          ),
                        ],
                      ),

                      SizedBox(height: height * 0.01),

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

                      Container(
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
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // ✅ الـ loading overlay
          if (isLoading)
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

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    // ✅ نعرض الـ loading
    setState(() {
      isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      final MyUser? myUser = await FirebaseUtils.getUserById(
        credential.user!.uid,
      );
      
      if (!mounted) return;

      if (myUser != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(myUser);
        
        var eventListProvider = Provider.of<EventListProvider>(
          context,
          listen: false,
        );
        
        await eventListProvider.getAllEvents(userProvider.user!.id);
        eventListProvider.changeSelectedIndex(0);
        
        if (!mounted) return;
        
        // ✅ نخفي الـ loading
        setState(() {
          isLoading = false;
        });
        
        // ✅ الانتقال للـ Home Screen
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        
      } else {
        if (!mounted) return;
        
        setState(() {
          isLoading = false;
        });
        
        DialogUtils.showErrorDialog(
          context: context,
          title: "Error",
          content: "User data not found in Firestore.",
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      
      setState(() {
        isLoading = false;
      });
      
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = "No user found for that email.";
          break;
        case 'wrong-password':
          message = "Wrong password provided for that user.";
          break;
        case 'invalid-email':
          message = "The email address is badly formatted.";
          break;
        default:
          message = "An error occurred. Please try again.";
      }
      
      DialogUtils.showErrorDialog(
        context: context,
        title: "Error",
        content: message,
      );
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        isLoading = false;
      });
      
      DialogUtils.showErrorDialog(
        context: context,
        title: "Error",
        content: "An unexpected error occurred.",
      );
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
