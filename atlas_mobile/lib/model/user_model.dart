class UserModel {
  int? id;
  DateTime lastLogin;
  String name;
  String phoneNumber;
  String email;
  String password;
  String? otp; // Add the OTP property

  UserModel(this.name,this.phoneNumber, this.email, this.password,this.lastLogin);
}
