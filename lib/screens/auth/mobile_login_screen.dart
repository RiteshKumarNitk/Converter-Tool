import 'package:flutter/material.dart';
import '../../utils/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../services/auth_service.dart';

import 'package:pdf_convertor/utils/app_routes.dart';
import 'package:pdf_convertor/widgets/custom_button.dart';
import 'package:pdf_convertor/services/auth_service.dart';

class MobileLoginScreen extends StatelessWidget {
  final TextEditingController mobileController = TextEditingController();

  MobileLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login with Mobile")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: mobileController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: "Enter Mobile Number"),
            ),
            SizedBox(height: 20),
            CustomButton(
              text: "Send OTP",
              onPressed: () async {
                String phone = mobileController.text.trim();
                if (phone.isNotEmpty) {
                  await AuthService().sendOtp(phone, context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
