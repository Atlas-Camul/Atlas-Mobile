import 'package:atlas_mobile/model/user_model.dart';

class UserController {
  final UserModel user = UserModel();

  void registerUser() {
    // Do something with the user data, like saving to a database or sending to an API
    print('User registered: ${user.name}, ${user.email}, ${user.password}');
  }


  void setEmail(String value) {
    user.email = value;
  }

  void setPassword(String value) {
    user.password = value;
  }

  bool validateForm() {
    return user.email.isNotEmpty && user.password.isNotEmpty;
  }





}
