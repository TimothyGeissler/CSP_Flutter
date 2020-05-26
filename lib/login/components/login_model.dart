import 'package:flutter_login_signup/login/components/user.dart';

class Login{
  bool error;
  User user;

  Login({this.error, this.user});

  factory Login.fromJson(Map<String, dynamic> parsedJson) {
    return Login(
      error: parsedJson['error'],
      user: User.fromJson(parsedJson['user'])
    );
  }
}