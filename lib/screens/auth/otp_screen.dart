import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../services/auth_service.dart';

class OtpScreen extends StatelessWidget {
  final TextEditingController otpController = TextEditingController();
  final String verificationId;

  OtpScreen({required this.verificationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Enter OTP"),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: "Verify & Login",
              onPressed: () async {
                final isVerified = await AuthService()
                    .verifyOtp(verificationId, otpController.text, context);

                if (isVerified) {
                  // ✅ Save login flag
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isLoggedIn', true);
                  await prefs.setString('userPhone', "+91XXXXXXXXXX"); // ✅ store phone or any identifier

                  // ✅ Go to Home
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Invalid OTP, please try again")),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
