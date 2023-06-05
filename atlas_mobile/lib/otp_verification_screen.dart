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
      } else {
        // Handle incorrect OTP case, show an error message, or take appropriate action
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
      // Handle the exception, show an error message, or take appropriate action
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
            Text(
              (
"Open the email and locate the verification code. It should be clearly mentioned within the message."
"Return to our registration page and enter the verification code in the designated field."
"Click on the Verify Email button to complete the process."),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
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

