import 'dart:io';
import 'package:evently/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // جديد
import 'package:evently/utils/app_colors.dart';
import 'package:evently/utils/assets_manager.dart';
import 'package:provider/provider.dart';

import '../../../../../utils/app_styles.dart';

class ProfileAppbarWidget extends StatefulWidget
    implements PreferredSizeWidget {
  const ProfileAppbarWidget({super.key});

  @override
  State<ProfileAppbarWidget> createState() => _ProfileAppbarWidgetState();

  // لازم علشان Scaffold.appBar يقبل الويجت ده
  @override
  Size get preferredSize => const Size.fromHeight(160);
}

class _ProfileAppbarWidgetState extends State<ProfileAppbarWidget> {
  File? userImage;
  bool _isPicking = false; // متغير لتحديد ما إذا كان الـ picker شغال الآن

  /// دالة لاختيار صورة من المعرض
  Future<void> pickImage() async {
    // لو الـ picker شغال، نخرج فورًا
    if (_isPicking) return;
    _isPicking = true;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);

      if (file != null) {
        setState(() {
          userImage = File(file.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    } finally {
      // سواء حصل خطأ أو لا، نرجّع الفلاغ للحالة العادية
      _isPicking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    var userProvider = Provider.of<UserProvider>(context);
    return AppBar(
      backgroundColor: AppColors.primaryLight,
      toolbarHeight: height * 0.18,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(70)),
      ),
      title: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            GestureDetector(
              onTap: pickImage, // هنا خليت الضغط يفتح المعرض
              child: Container(
                height: height * 0.15,
                width: height * 0.15,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(80),
                    topRight: Radius.circular(80),
                    bottomLeft: Radius.circular(80),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(80),
                      topRight: Radius.circular(80),
                      bottomLeft: Radius.circular(80),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(80),
                      topRight: Radius.circular(80),
                      bottomLeft: Radius.circular(80),
                    ),
                    child:
                        userImage == null
                            ? Image.asset(
                              AssetsManager.imageProfile, // صورة افتراضية
                              fit: BoxFit.cover,
                            )
                            : Image.file(
                              userImage!, // صورة المستخدم
                              fit: BoxFit.cover,
                            ),
                  ),
                ),
              ),
            ),
            SizedBox(width: height * 0.02),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (userProvider.user == null)
                    const Text(
                      "Guest User",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userProvider.user!.name,
                          style: AppStyles.bold24White,
                        ),
                        SizedBox(height: height * 0.01),
                        Text(
                          userProvider.user!.email,
                          style: AppStyles.medium16White,
                          overflow: TextOverflow.visible,
                          softWrap: true,
                        ),
                      ],
                    ),

                  // Text(userProvider.user!.name, style: AppStyles.bold24White),
                  // SizedBox(height: height * 0.01),
                  // Text(
                  //   userProvider.user!.email,
                  //   style: AppStyles.medium16White,
                  //   overflow: TextOverflow.visible,
                  //   softWrap: true,
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
