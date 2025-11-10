import 'package:evently/model/my_user.dart';
 import 'package:evently/ui/authentication/login/login_screen.dart';
import 'package:evently/ui/widgets/custom_elevated_button.dart';
import 'package:evently/ui/widgets/custom_text_button.dart';
import 'package:evently/ui/widgets/custom_text_field.dart';
// import 'package:evently/utils/app_colors.dart';
import 'package:evently/utils/app_styles.dart';
import 'package:evently/utils/assets_manager.dart';
import 'package:evently/utils/dialog_utils.dart';
import 'package:evently/utils/firebase_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = "register_screen";

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  var formKey = GlobalKey<FormState>();

  // @override
  TextEditingController emailController = TextEditingController(
    text: "123852zza@gmail.com",
  );

  TextEditingController passwordController = TextEditingController(
    text: "123456",
  );

  TextEditingController rePasswordController = TextEditingController(
    text: "123456",
  );

  TextEditingController nameController = TextEditingController(
    text: "abobakr",
  );

  Widget build(BuildContext context) {
    // var width = MediaQuery.of(context).size.width;
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
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Image.asset(AssetsManager.logoTop),
                  SizedBox(height: height * 0.02),
                  CustomTextField(
                    prefixIcon: Image.asset(AssetsManager.iconEmail),
                    hintText: AppLocalizations.of(context)!.email,
                    controller: emailController,
                    textInputType: TextInputType.emailAddress,

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
                    prefixIcon: Image.asset(AssetsManager.iconName),
                    hintText: AppLocalizations.of(context)!.name,
                    controller: nameController,
                    validator: (text) {
                      if (text == null || text.trim().isEmpty) {
                        return "enter valid name";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: height * 0.02),
                  CustomTextField(
                    obscureText: true,
                    obscuringCharacter: '•',
                    prefixIcon: Image.asset(AssetsManager.iconLock),
                    hintText: AppLocalizations.of(context)!.password,
                    suffixIcon: Image.asset(
                      AssetsManager.iconPassword,
                      // width: width * .001,
                      // height: height * .001,
                      // fit: BoxFit.contain,
                    ),
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
                  ),
                  SizedBox(height: height * 0.02),
                  CustomTextField(
                    obscureText: true,
                    obscuringCharacter: '•',
                    prefixIcon: Image.asset(AssetsManager.iconLock),
                    hintText: AppLocalizations.of(context)!.re_password,
                    suffixIcon: Image.asset(AssetsManager.iconPassword),
                    controller: rePasswordController,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "enter valid password";
                      }
                      if (text.length < 6) {
                        return "password must be at least 6 characters";
                      }
                      if (text != passwordController.text) {
                        return "passwords do not match";
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: height * 0.02),
                  CustomElevatedButton(
                    onButtonClick: register,
                    text: AppLocalizations.of(context)!.create_account,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.already_have_account,
                        style: AppStyles.medium16Black,
                      ),
                      CustomTextButton(
                        onPressed: () {},
                        text: AppLocalizations.of(context)!.login,
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.01),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void register() async {
    // Registration logic to be implemented
    if (formKey.currentState!.validate()) {
      DialogUtils.showLoadingDialog(
        context: context,
        message: "Creating your account...",
      );
      try {
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: emailController.text,
              password: passwordController.text,
            );
        //      FirebaseUtils.getUsersCollection().doc(credential.user!.uid).set(
        //   MyUser(
        //     id: credential.user!.uid,
        //     name: nameController.text,
        //     email: emailController.text,
        //   ),
        // );
          await FirebaseUtils.addUser( 
          MyUser(
            id: credential.user!.uid,
            name: nameController.text,
            email: emailController.text,
          ),
        );
        if (!context.mounted) return;
        DialogUtils.hideLoadingDialog(context:context);
        print("User registered: ${credential.user?.email}");
         if (!context.mounted) return;
        DialogUtils.showErrorDialog(
          context: context ,
          title: "Success",
          content: "Your account has been created successfully.",
          positiveActionName: "OK",
          onPositiveActionClick: () {
            // Navigate to home screen or another screen after successful registration
            Navigator.pushReplacementNamed(
              formKey.currentContext!, LoginScreen.routeName
            );
          },
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          DialogUtils.hideLoadingDialog(context: context);
          DialogUtils.showErrorDialog(
            context:context,
            title: "Error",
            content: "The password provided is too weak.",
          );
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          DialogUtils.hideLoadingDialog(context:context);
          if (!context.mounted) return;
          DialogUtils.showErrorDialog(
            context:context,
            title: "Error",
            content: "The account already exists for that email.",
          );
          print('The account already exists for that email.');
        }
      } catch (e) {
        DialogUtils.hideLoadingDialog(context: formKey.currentContext!);
        DialogUtils.showErrorDialog(
          context: context,
          title: "Error",
          content: "An unexpected error occurred. Please try again.",
        );
        print(e.toString());
      }
    }
  }
}
