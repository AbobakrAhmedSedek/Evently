import 'package:evently/domain/model/my_user.dart';

abstract class LoginNavigator {
  Future<void> navigateToHomeScreen(MyUser user);
  void showMessage({required String message});
  void hideLogin();
  void showLogin({required String message});
}
