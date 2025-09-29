import 'package:evently/ui/widgets/custom_elevated_button.dart';
import 'package:evently/ui/widgets/custom_text_button.dart';
import 'package:evently/ui/widgets/custom_text_field.dart';
import 'package:evently/utils/app_colors.dart';
import 'package:evently/utils/app_styles.dart';
import 'package:evently/utils/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterScreen extends StatelessWidget {
  static const String routeName = "/register_screen";
  @override
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController rePasswordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
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
                  prefixIcon: Image.asset(AssetsManager. iconName),
                  hintText: AppLocalizations.of(context)!.name,
                  controller: emailController,
                  validator: (text) {},
                ),
                SizedBox(height: height * 0.02),
                CustomTextField(
                  prefixIcon: Image.asset(AssetsManager.iconLock),
                  hintText: AppLocalizations.of(context)!.password,
                  suffixIcon: Image.asset(
                    AssetsManager.iconPassword,
                    // width: width * .001,
                    // height: height * .001,
                    // fit: BoxFit.contain,
                  ),
                  controller:passwordController ,
                     validator: (text) {},
                ),
                  SizedBox(height: height * 0.02),
                CustomTextField(
                  prefixIcon: Image.asset(AssetsManager.iconLock),
                  hintText: AppLocalizations.of(context)!.re_password,
                  suffixIcon: Image.asset(
                    AssetsManager. iconPassword,
                    
                  ),
                  controller:rePasswordController ,
                     validator: (text) {},
                ),
                
                SizedBox(height: height * 0.02),
                CustomElevatedButton(
                  onButtonClick:register ,
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
                      onPressed: () {
                        
                      },
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
    );
  }

  void register() {}
}
