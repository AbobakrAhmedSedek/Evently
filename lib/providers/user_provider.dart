import 'package:evently/model/my_user.dart';
import 'package:evently/providers/event_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProvider with ChangeNotifier {
  MyUser? _user;

  MyUser? get user => _user;

  void setUser(MyUser user) {
    _user = user;
    notifyListeners();
  }

  void logout(BuildContext context) {
    _user = null;

    // ✅ تفريغ الأحداث القديمة عند تسجيل الخروج
    Provider.of<EventListProvider>(context, listen: false).clearEvents();

    notifyListeners();
  }

  // ✅ إضافة دالة لتحديث بيانات المستخدم عند التبديل
  void updateUser(MyUser newUser) {
    // لو المستخدم مختلف، نمسح الأحداث القديمة
    if (_user?.id != newUser.id || _user == null) {
      _user = newUser;
      notifyListeners();
      // } else if (_user == null) {
      //   _user = newUser;
      //   notifyListeners();
    }
  }
}
