import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../utils/app_routes.dart';

class MobileNumberScreen extends StatelessWidget {
  final TextEditingController mobileController = TextEditingController();

  MobileNumberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter Mobile Number")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: mobileController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: "Mobile Number"),
            ),
            SizedBox(height: 20),
            CustomButton(
              text: "Continue",
              onPressed: () {
                // ✅ Later: Add OTP / verification logic
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              },
            ),
          ],
        ),
      ),
    );
  }
}
