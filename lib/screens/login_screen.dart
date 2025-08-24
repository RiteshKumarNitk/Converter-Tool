import 'package:flutter/material.dart';
import '../utils/app_routes.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';

class OtpScreen extends StatelessWidget {
  final TextEditingController otpController = TextEditingController();
  final String verificationId;

  OtpScreen({required this.verificationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify OTP")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Enter OTP"),
            ),
            SizedBox(height: 20),
            CustomButton(
              text: "Verify & Login",
              onPressed: () async {
                await AuthService()
                    .verifyOtp(verificationId, otpController.text, context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
