import 'package:evently/ui/authentication/register_screen/register_screen.dart';
import 'package:evently/ui/widgets/custom_elevated_button.dart';
import 'package:evently/ui/widgets/custom_text_button.dart';
import 'package:evently/ui/widgets/custom_text_field.dart';
import 'package:evently/utils/app_colors.dart';
import 'package:evently/utils/app_styles.dart';
import 'package:evently/utils/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = "/Login_screen";
  @override
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(AssetsManager.logoTop),
                SizedBox(height: height * 0.02),

                CustomTextField(
                  prefixIcon: Image.asset(AssetsManager.iconEmail),
                  hintText: AppLocalizations.of(context)!.email,
                  controller: emailController,
                  validator: (text) {},
                ),
                SizedBox(height: height * 0.02),
                CustomTextField(
                  prefixIcon: Image.asset(AssetsManager.iconLock),
                  hintText: AppLocalizations.of(context)!.password,
                  suffixIcon: Image.asset(
                    AssetsManager.iconShowPassword,
                    width: width * .001,
                    height: height * .001,
                    fit: BoxFit.contain,
                  ),
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
                    ), // Divider, Expanded
                    Text(
                      AppLocalizations.of(context)!.or,
                      style: AppStyles.medium16Primary,
                    ), // Text
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
    );
  }

  void login() {}
}
