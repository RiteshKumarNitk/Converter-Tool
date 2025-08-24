import 'package:flutter/material.dart';
import '../utils/app_routes.dart';

class AuthService {
  // Simulated sendOtp
  Future<void> sendOtp(String phone, BuildContext context) async {
    await Future.delayed(const Duration(seconds: 1));

    Navigator.pushNamed(
      context,
      AppRoutes.otp,
      arguments: 'dummy-verification-id',
    );
  }

  // ✅ Return bool instead of void
  Future<bool> verifyOtp(
    String verificationId,
    String otp,
    BuildContext context,
  ) async {
    if (otp == '000000') {
      return true; // OTP is valid
    } else {
      return false; // OTP is invalid
    }
  }
}
