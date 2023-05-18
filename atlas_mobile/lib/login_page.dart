import 'package:atlas_mobile/bottom_page.dart';
import 'package:atlas_mobile/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final UserController controller = UserController();

  void _submitForm() async {
    if (_formKey.currentState!.validate() && controller.validateForm()) {
      // Check if user exists in the database
      final userExists = await controller.loginUser(
        controller.user.email,
        controller.user.password,
      );

      // Navigate to new screen if successful
      if (userExists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomPage()),
        );
      } else {
        // Show error message if user does not exist
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email or password'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(153, 26, 35, 255),
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
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {},
                    child: Text(
                      'Don\'t have an account?',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      'Login',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
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
    );
  }
}
