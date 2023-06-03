import 'dart:convert';
import 'dart:math';
import 'package:atlas_mobile/model/user_model.dart';
import 'package:atlas_mobile/db/db_settings.dart';
import 'package:mysql1/mysql1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:crypto/crypto.dart';

class UserController {
  final UserModel user = UserModel('', '', '', '', DateTime(2000));

  Future<bool> registerUser() async {
    // Do something with the user data, like saving to a database or sending to an API
    print('User registered: ${user.name}, ${user.email}, ${user.password}, ${user.phoneNumber}, ${user.otp}');

    // Generate a confirmation code
    final confirmationCode = _generateConfirmationCode();

    String salt = 'unique_salt_per_user'; // Generate a unique salt for each user
    String password = user.password;

    // Combine the password and salt
    String saltedPassword = '$password$salt';

    // Hash the salted password using SHA-256 algorithm
    var bytes = utf8.encode(saltedPassword);
    var sha256Digest = sha256.convert(bytes);

    String hashedPassword = sha256Digest.toString();

    // Store user data in shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', user.name);
    await prefs.setString('email', user.email);
    // await prefs.setString('password', user.password);
    await prefs.setString('phoneNumber', user.phoneNumber);

    // Check MySQL connection
    final isConnected = await checkMySQLConnection();
    if (!isConnected) {
      throw Exception('Failed to connect to MySQL');
    }

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
    // Convert DateTime to UTC
    final utcLastLogin = user.lastLogin.toUtc();
    // Insert the user into the database
    final result = await conn.query(
      'INSERT INTO user (name, email, password, phone,otp) VALUES (?, ?, ?, ?,?)',
      [user.name, user.email, hashedPassword, user.phoneNumber, confirmationCode],
    );
    print(result.insertId);

    // Save the generated user ID to shared preferences
    final insertId = result.insertId;
    await prefs.setInt('id', result.insertId!.toInt());

    // Close the database connection
    await conn.close();

    // Send OTP to the user's email
    await sendOTP(user.email, confirmationCode);

    return true;
  }

  String _generateConfirmationCode() {
    final random = Random.secure();
    final values = List<int>.generate(6, (i) => random.nextInt(256));
    final code = base64Url.encode(values);
    return code.substring(0, 6);
  }

  Future<void> sendOTP(String email, String otp) async {
    final smtpServer = SmtpServer('smtp.office365.com',
        username: 'atlas.mobile.otp@outlook.pt',
        password: 'Atlas.2023',
        port: 587,
        ssl: false,
        ignoreBadCertificate: true);

    final message = Message()
      ..from = const Address('atlas.mobile.otp@outlook.pt', 'Atlas Team')
      ..recipients.add(email)
      ..subject = 'OTP Confirmation Code'
      ..text = 'Your OTP: $otp';

    try {
      final sendReport = await send(message, smtpServer);
      print('OTP sent: ${sendReport.toString()}');
    } catch (e) {
      print('Error sending OTP: $e');
      throw Exception('Failed to send OTP');
    }
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
    print('User logged: $email, $password');

    // Hash the password using SHA-256 algorithm
    String salt = 'unique_salt_per_user'; // The same salt used during registration
    String saltedPassword = '$password$salt';
    var bytes = utf8.encode(saltedPassword);
    var sha256Digest = sha256.convert(bytes);
    String hashedPassword = sha256Digest.toString();

    // Check if the user exists in the database
    final results = await conn.query(
      'SELECT COUNT(*) AS count, ID FROM user WHERE email = ? AND password = ? GROUP BY ID',
      [email, hashedPassword],
    );

    // Close the database connection
    await conn.close();

    // If user exists, store user data in shared preferences
    if (results.first['count'] == 1) {
      final prefs = await SharedPreferences.getInstance();
      final userId = results.first['ID'] as int; // Get the user ID from the query result

      // Update the lastLogin timestamp in the database
      await updateLastLoginTimestamp(userId);

      await prefs.setString('email', email);
      await prefs.setString('password', hashedPassword);
      await prefs.setInt('id', userId); // Save the user ID in shared preferences
      print(userId);

      // Update the id and lastLogin fields in the UserModel object
      user.id = userId;
      user.lastLogin = DateTime.now();

      return true;
    } else {
      return false;
    }
  }

  Future<void> updateLastLoginTimestamp(int userId) async {
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

    // Update the lastLogin timestamp in the database
    await conn.query(
      'UPDATE user SET lastLogin = ? WHERE id = ?',
      [DateTime.now().toUtc(), userId],
    );

    // Close the database connection
    await conn.close();
  }

  Future<UserModel?> getCurrentUser() async {
    // Get user data from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final password = prefs.getString('password');
    final phoneNumber = prefs.getString('phoneNumber');
    final name = prefs.getString('name');
    final lastLoginTimestamp = prefs.getString('lastLoginTimestamp');

    // If user data is present, create a UserModel object and return it
    if (email != null && password != null) {
      final lastLogin = lastLoginTimestamp != null ? DateTime.parse(lastLoginTimestamp) : null;
      return UserModel(name!, email, password, phoneNumber!, lastLogin!);
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

  Future<bool> checkMySQLConnection() async {
    try {
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
      await conn.close();
      return true;
    } catch (e) {
      print('Error connecting to MySQL: $e');
      return false;
    }
  }

  Future<bool> updateUser(String newName) async {
    // Get the user ID from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');

    if (userId == null) {
      throw Exception('User ID not found in shared preferences');
    }

    // Check MySQL connection
    final isConnected = await checkMySQLConnection();
    if (!isConnected) {
      throw Exception('Failed to connect to MySQL');
    }

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

    // Update the user's name in the database
    final result = await conn.query(
      'UPDATE user SET name = ? WHERE id = ?',
      [newName, userId],
    );

    // Close the database connection
    await conn.close();

    if (result.affectedRows == 1) {
      // Update the user's name in shared preferences
      await prefs.setString('name', newName);
      // Update the name field in the UserModel object
      user.name = newName;
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkOtp(String enteredOtp) async {
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

    // Get the user's email from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');

    // Retrieve the OTP from the database for the given email
    final result = await conn.query(
      'SELECT otp FROM user WHERE email = ?',
      [email],
    );

    // Close the database connection
    await conn.close();

    if (result.isNotEmpty) {
      final dbOtp = result.first['otp'] as String;
      // Compare the entered OTP with the OTP from the database
      return enteredOtp == dbOtp;
    } else {
      // User not found in the database, handle the error appropriately
      throw Exception('User not found in the database');
    }
  }
}