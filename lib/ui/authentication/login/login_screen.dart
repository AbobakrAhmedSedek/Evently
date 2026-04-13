import 'package:evently/domain/model/my_user.dart';
import 'package:evently/providers/event_list_provider.dart';
import 'package:evently/providers/user_provider.dart';
import 'package:evently/ui/authentication/login/login_navigator.dart';
import 'package:evently/ui/authentication/login/login_screen_view_model.dart';
import 'package:evently/ui/authentication/register_screen/register_screen.dart';
import 'package:evently/ui/home/home_screen.dart';
import 'package:evently/ui/widgets/custom_elevated_button.dart';
import 'package:evently/ui/widgets/custom_text_button.dart';
import 'package:evently/ui/widgets/custom_text_field.dart';
import 'package:evently/utils/app_colors.dart';
import 'package:evently/utils/app_styles.dart';
import 'package:evently/utils/assets_manager.dart';
import 'package:evently/utils/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String routeName = "Login_screen";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> implements LoginNavigator {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginScreenViewModel viewModel = LoginScreenViewModel();

  @override
  void initState() {
    super.initState();
    viewModel.loginNavigator = this;
  }

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

    return ChangeNotifierProvider(
      create: (context) => viewModel,
      builder: (context, child){ return Scaffold(
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
                              text:
                                  AppLocalizations.of(context)!.forget_password,
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
                              text:
                                  AppLocalizations.of(context)!.create_account,
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
                                  AppLocalizations.of(
                                    context,
                                  )!.login_with_google,
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
            if (Provider.of<LoginScreenViewModel>(context).isLoading)
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
    }); 
  
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
    viewModel.logiginWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );
  }

  // ============================================
  // 🔐 Google Login
  // ============================================

  Future<void> _loginWithGoogle() async {
    viewModel.logiginWithGoogle();
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

  @override
  void hideLogin() {
    DialogUtils.hideLoadingDialog(context: context);
  }

  @override
  Future<void> navigateToHomeScreen(MyUser user) async {
    await _setupUserSession(user);
    Navigator.pushReplacementNamed(context, HomeScreen.routeName);
  }

  @override
  void showLogin({required String message}) {
    DialogUtils.showLoadingDialog(context: context, message: message);
  }

  @override
  void showMessage({required String message}) {
    DialogUtils.showErrorDialog(
      context: context,
      title: "login failed",
      content: message,
    );
  }
}
