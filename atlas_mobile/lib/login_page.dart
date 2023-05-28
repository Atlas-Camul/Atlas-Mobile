import 'package:atlas_mobile/controllers/user_controller.dart';
import 'package:atlas_mobile/register_page.dart';
import 'package:atlas_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:atlas_mobile/colors/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final UserController controller = UserController();

  String? email;
  String? password;

 void _submitForm() async {
  if (_formKey.currentState?.validate() == true && controller.validateForm() == true) {
    try {
      // Check if user exists in the database
      final userExists = await controller.loginUser(
        controller.user.email,
        controller.user.password
      );

      // Navigate to new screen if successful
      if (userExists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>NavBarPage(initialPage: 'HomePage')),
        );
      } else {
        // Show error message if user does not exist
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email or password'),
          ),
        );
      }
    } catch (e) {
      print('Error during login: $e');
    }
  }
}


  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    // You can add more email validation logic here if needed
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    // You can add more password validation logic here if needed
    return null;
  }
    void _openRegisterPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage('assets/images/atlasFundo.png'),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 301,
                  height: 198,
                  fit: BoxFit.fitWidth,
                ),
                SizedBox(height: 32),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                  validator: validateEmail,
                  onChanged: (value) {
                    setState(() {
                     controller.setEmail(value);
                    });
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                  validator: validatePassword,
                  onChanged: (value) {
                    setState(() {
                      controller.setPassword(value);
                    });
                  },
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap:_openRegisterPage,
                      child: Text(
                        'Don\'t have an account?',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    TextButton(
                      onPressed: _submitForm,
                      child: Text(
                        'Login',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
