import 'package:flutter/material.dart';
import 'package:atlas_mobile/controllers/user_controller.dart';

import 'main.dart';

class OtpVerificationScreen extends StatelessWidget {
  final TextEditingController _otpController = TextEditingController();

  OtpVerificationScreen({Key? key});

  void _verifyOTP(BuildContext context) async {
    final enteredOtp = _otpController.text;
    final userController = UserController();

    try {
      final isOtpCorrect = await userController.checkOtp(enteredOtp);
      if (isOtpCorrect) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => NavBarPage(initialPage: 'HomePage')),
          );
          transitionsBuilder: (___, Animation<double> animation, ____, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: RotationTransition(
        turns: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
        child: child,
      ),
    );
  }
;
      } else {
        // TODO: Handle incorrect OTP case, show an error message, or take appropriate action
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Incorrect OTP'),
            content: const Text('Please enter the correct OTP.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // TODO: Handle the exception, show an error message, or take appropriate action
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to verify OTP: $e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify OTP'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _otpController,
              decoration: InputDecoration(labelText: 'OTP'),
            ),
            ElevatedButton(
              onPressed: () {
                _verifyOTP(context); // Call the OTP verification function
              },
              child: Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
