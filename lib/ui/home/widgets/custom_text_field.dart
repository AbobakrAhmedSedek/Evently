import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_styles.dart';

class CustomTextField extends StatelessWidget {
  final Color? borderColor;
  final String? hintText;
  final TextStyle ? hintStyle;
  final Widget? prefixIcon;
  final Widget? suffixIcon;


  const CustomTextField({
    super.key,
    this.borderColor,
    this.hintText,
    this.hintStyle,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: AppColors.primaryLight,
      decoration: InputDecoration(
        hintText:hintText,
        hintStyle: hintStyle?? AppStyles.medium16Grey,
        prefixIcon :prefixIcon,
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: borderColor ?? AppColors.greyColor,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: borderColor ?? AppColors.greyColor,
            width: 1.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red, width: 1.0),
        ),
      ),


    );
  }
}
