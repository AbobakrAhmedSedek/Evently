import 'package:evently/utils/app_colors.dart';
import 'package:evently/utils/app_styles.dart';
import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final String text; // المتغير اللي هيستقبل النص
  final VoidCallback? onPressed; // عشان لو حابب تحدد اكشن كمان

  const CustomTextButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed ?? () {}, // اكشن افتراضي فاضي
      child: Text(
        text,
        style: AppStyles.bold16Primary.copyWith(
          decoration: TextDecoration.underline,
          decorationColor: AppColors.primaryLight,
        ),
      ),
    );
  }
}
