import 'package:flutter/material.dart';
import 'package:atlas_mobile/controllers/user_controller.dart';
import 'package:atlas_mobile/login_page.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:password_strength/password_strength.dart';
import 'package:email_validator/email_validator.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  final UserController _controller = UserController();

  List<String> temporaryEmailDomains = [
    // Add known temporary email domains here
  
    'temp-mail.org',
    // ...
  
  
  
  
  
  
  
  
  
  
  
  
  
  ];

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      bool isTemporaryEmail = _checkTemporaryEmail(_controller.user.email);
      if (isTemporaryEmail) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Temporary email addresses are not allowed')),
        );
        return;
      }

      bool registered = await _controller.registerUser();
      if (registered) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    }
  }

  bool _checkTemporaryEmail(String email) {
    String domain = _extractDomainFromEmail(email);
    return temporaryEmailDomains.contains(domain);
  }

  String _extractDomainFromEmail(String email) {
    int atIndex = email.indexOf('@');
    if (atIndex != -1) {
      return email.substring(atIndex + 1);
    }
    return '';
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    double strength = estimatePasswordStrength(value);
    if (strength < 0.3) {
      return 'Weak password';
    } else if (strength < 0.6) {
      return 'Medium password';
    } else {
      return null;
    }
  }

  String _getPasswordStrengthText(double strength) {
    if (strength < 0.3) {
      return 'Weak';
    } else if (strength < 0.6) {
      return 'Medium';
    } else {
      return 'Strong';
    }
  }

  Color _getPasswordStrengthColor(double strength) {
    if (strength < 0.3) {
      return Colors.red;
    } else if (strength < 0.6) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    setState(() {
                      _controller.user.name = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!EmailValidator.validate(value)) {
                      return 'Invalid email format';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    setState(() {
                      _controller.user.email = value!;
                    });
                  },
                ),

                const SizedBox(height: 16),
                IntlPhoneField(
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  initialCountryCode: 'PT', // Set the initial country code
                  onChanged: (phone) {
                    // Handle phone number changes
                    print(phone.completeNumber); // You can access the complete phone number using phone.completeNumber
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                  onSaved: (phone) {
                    // Handle saving of phone number
                    print(phone?.completeNumber); // You can access the complete phone number using phone.completeNumber
                  },
                ),

                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: _validatePassword,
                  onSaved: (value) {
                    setState(() {
                      _controller.user.password = value!;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Builder(
                  builder: (context) {
                    double strength = estimatePasswordStrength(_passwordController.text);
                    String strengthText = _getPasswordStrengthText(strength);
                    Color strengthColor = _getPasswordStrengthColor(strength);

                    return Text(
                      'Password Strength: $strengthText',
                      style: TextStyle(
                        color: strengthColor,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Repeat Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please repeat your password';
                    }

                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
