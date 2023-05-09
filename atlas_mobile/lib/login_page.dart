import 'package:flutter/material.dart';

// Model class
class LoginModel {
  String email = '';
  String password = '';
}

// Controller class
class LoginController {
  final LoginModel model = LoginModel();

  void setEmail(String value) {
    model.email = value;
  }

  void setPassword(String value) {
    model.password = value;
  }

  bool validateForm() {
    return model.email.isNotEmpty && model.password.isNotEmpty;
  }
}

// View class
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final LoginController controller = LoginController();

  void _submitForm() {
    if (_formKey.currentState!.validate() && controller.validateForm()) {
      // Navigate to new screen if successful
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    controller.setEmail(value);
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    controller.setPassword(value);
                  });
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
