import 'package:atlas_mobile/model/user_model.dart';
import 'package:atlas_mobile/db/db_settings.dart';
import 'package:mysql1/mysql1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
class UserController {
  final UserModel user = UserModel('', '');

 Future <bool> registerUser() async {
    // Do something with the user data, like saving to a database or sending to an API
    print('User registered: ${user.name}, ${user.email}, ${user.password}');
 
 
 // Store user data in shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', user.name);
    await prefs.setString('email', user.email);
    await prefs.setString('password', user.password);

 
 
 // Connect to the database
    final conn = await MySqlConnection.connect(
      ConnectionSettings(
        host: DbSettings.host,
        port: DbSettings.port,
        db: DbSettings.dbName,
        user: DbSettings.user,
        password: DbSettings.password,
        useSSL: DbSettings.useSSL
     
      ),
    );
    

  // Check if the email already exists in the database
    final emailQueryResult = await conn.query(
      'SELECT COUNT(*) AS count FROM user WHERE email = ?',
      [user.email],
    );
    final emailCount = emailQueryResult.first['count'] as int;

    if (emailCount > 0) {
    // Email already exists in the database, throw an exception or handle the error
      throw Exception('Email already exists in the database');
    }


    // Insert the user into the database

    await conn.query(
      'INSERT INTO user (name, email, password,phone,ID) VALUES (?, ?, ?)',
      [user.name, user.email, user.password],
    );
 
 
    // Close the database connection
      await conn.close();
      return true;
 
  }

   Future<bool> loginUser(String email, String password) async {
    // Connect to the database
    final conn = await MySqlConnection.connect(
      ConnectionSettings(
        host: DbSettings.host,
        port: DbSettings.port,
        db: DbSettings.dbName,
        user: DbSettings.user,
        password: DbSettings.password,
        useSSL: DbSettings.useSSL,
      ),
    );

    // Check if the user exists in the database
    final results = await conn.query(
      'SELECT COUNT(*) AS count FROM user WHERE email = ? AND password = ?',
      [email, password],
    );



    // Close the database connection
    await conn.close();

    
// If user exists, store user data in shared preferences
    if (results.first['count'] == 1) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);
      await prefs.setString('password', password);
      return true;
    } else {
      return false;
    }
}


 Future<UserModel?> getCurrentUser() async {
    // Get user data from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final password = prefs.getString('password');

    // If user data is present, create a UserModel object and return it
    if (email != null && password != null) {
      return UserModel(email,password);
    } else {
      return null;
    }
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