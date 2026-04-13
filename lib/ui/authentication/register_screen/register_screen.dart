import 'package:evently/ui/authentication/login/login_screen.dart';
import 'package:evently/ui/authentication/register_screen/register_navigator.dart';
import 'package:evently/ui/authentication/register_screen/register_screen_view_model.dart';
import 'package:evently/ui/widgets/custom_elevated_button.dart';
import 'package:evently/ui/widgets/custom_text_button.dart';
import 'package:evently/ui/widgets/custom_text_field.dart';
import 'package:evently/utils/app_styles.dart';
import 'package:evently/utils/assets_manager.dart';
import 'package:evently/utils/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = "register_screen";

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    implements RegisterNavigator {
  final _formKey = GlobalKey<FormState>();
  

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rePasswordController = TextEditingController();
  final _nameController = TextEditingController();

  RegisterScreenViewModel registerScreenViewModel = RegisterScreenViewModel();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _rePasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    registerScreenViewModel.navigator = this;
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider(
      create: (context) => registerScreenViewModel,
      child: Scaffold(
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
    registerScreenViewModel.register(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
    );
  }

  @override
  void hideLogin() {
    DialogUtils.hideLoadingDialog(context: context);
  }

  @override
  void showLogin({required String message}) {
    DialogUtils.showLoadingDialog(context: context, message: message);
  }

  @override
  void showMessage({required String message}) {
    DialogUtils.showErrorDialog(
      context: context,
      title: "Error",
      content: message,
    );
  }
}
