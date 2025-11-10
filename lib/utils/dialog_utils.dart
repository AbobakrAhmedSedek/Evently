
import 'package:evently/utils/app_styles.dart';
import 'package:flutter/material.dart';

class DialogUtils {
  // ✅ نحفظ الـ context الخاص بالـ dialog
  static BuildContext? _loadingDialogContext;

  static void showLoadingDialog({
    required BuildContext context,
    required String message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // ✅ نحفظ الـ context عشان نستخدمه في الإغلاق
        _loadingDialogContext = dialogContext;
        
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 30),
              Text(
                message,
                overflow: TextOverflow.visible,
                softWrap: true,
                style: AppStyles.bold16Primary,
              ),
            ],
          ),
        );
      },
    ).then((_) {
      // ✅ لما الـ dialog يتقفل، نمسح الـ context
      _loadingDialogContext = null;
    });
  }

  static void hideLoadingDialog({required BuildContext context}) {
    // ✅ نستخدم الـ context المحفوظ بدل الـ context الممرر
    if (_loadingDialogContext != null) {
      Navigator.of(_loadingDialogContext!).pop();
      _loadingDialogContext = null;
    }
  }

  static void showErrorDialog({
    required BuildContext context,
    required String content,
    String? title,
    String? positiveActionName,
    String? negativeActionName,
    VoidCallback? onPositiveActionClick,
    bool barrierDismissible = false,
  }) {
    List<Widget> actions = [];

    if (positiveActionName != null) {
      actions.add(
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onPositiveActionClick?.call();
          },
          child: Text(
            positiveActionName,
            style: AppStyles.medium16Primary.copyWith(color: Colors.white),
          ),
        ),
      );
    }

    if (negativeActionName != null) {
      actions.add(
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.grey.shade300,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            negativeActionName,
            style: AppStyles.medium16Primary.copyWith(color: Colors.black),
          ),
        ),
      );
    }

    if (actions.isEmpty) {
      actions.add(
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      );
    }

    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(title ?? 'Error', style: AppStyles.bold20Primary),
          content: Text(
            content,
            overflow: TextOverflow.visible,
            softWrap: true,
            style: AppStyles.medium16Primary,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: actions,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// import 'package:evently/utils/app_styles.dart';
// import 'package:flutter/material.dart';

// class DialogUtils {
//   static void showLoadingDialog({
//     required BuildContext context,
//     required String message,
//   }) {


//     showDialog(
//       context: context,
//       barrierDismissible: false,

//       builder: (BuildContext context) {
//         return AlertDialog(
//           content: Row(
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(width: 30),
//               Text(message, overflow: TextOverflow.visible,
//                   softWrap: true,style: AppStyles.bold16Primary),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   static void hideLoadingDialog({required BuildContext context}) {
//   Navigator.of(context, rootNavigator: true).pop();
//   }

//   static void showErrorDialog({
//     required BuildContext context,
//     required String content,
//     String? title,
//     String? positiveActionName,
//     String? negativeActionName,
//     VoidCallback? onPositiveActionClick,
//     bool barrierDismissible = false, // 👈 يمنع إغلاق الحوار بالنقر بالخارج
//   }) {
//     List<Widget> actions = [];

//     // 🔹 زر الإيجابي (مثل "موافق" أو "حسنًا")
//     if (positiveActionName != null) {
//       actions.add(
//         TextButton(
//           style: TextButton.styleFrom(
//             foregroundColor: Colors.white,
//             backgroundColor: Colors.blueAccent,
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           onPressed: () {
//             Navigator.of(context).pop();
//             onPositiveActionClick?.call(); // 👈 طريقة أنظف لاستدعاء الدالة
//           },
//           child: Text(
//             positiveActionName,
//             style: AppStyles.medium16Primary.copyWith(color: Colors.white),
//           ),
//         ),
//       );
//     }

//     // 🔹 زر السلبي (مثل "إلغاء")
//     if (negativeActionName != null) {
//       actions.add(
//         TextButton(
//           style: TextButton.styleFrom(
//             foregroundColor: Colors.black,
//             backgroundColor: Colors.grey.shade300,
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           child: Text(
//             negativeActionName,
//             style: AppStyles.medium16Primary.copyWith(color: Colors.black),
//           ),
//         ),
//       );
//     }

//     // 🔹 في حال لم يُمرر أي زر، نضيف زر افتراضي
//     if (actions.isEmpty) {
//       actions.add(
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text(''),
//         ),
//       );
//     }

//     // 🔹 عرض الـDialog نفسه
//     showDialog(
//       context: context,
//       barrierDismissible: barrierDismissible,
//       builder: (context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           title: Text(title ?? 'Error', style: AppStyles.bold20Primary),
//           content: Text(
//             content,
//             overflow: TextOverflow.visible,
//             softWrap: true,
//             style: AppStyles.medium16Primary,
//           ),
//           actionsAlignment:
//               MainAxisAlignment.center, // 👈 يجعل الأزرار في المنتصف
//           actions: actions,
//         );
//       },
//     );
//   }
// }
