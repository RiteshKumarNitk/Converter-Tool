import 'package:flutter/material.dart';
import '../screens/auth/mobile_login_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/main/main_screen.dart';
import '../screens/splash_screen.dart';
import 'package:pdf_convertor/screens/converters/pdf_password_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String mobileLogin = '/mobile-login';
  static const String otp = '/otp';
  static const String home = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case mobileLogin:
        return MaterialPageRoute(builder: (_) => MobileLoginScreen());
      case otp:
        return MaterialPageRoute(
  builder: (_) => OtpScreen(verificationId: settings.arguments as String),
);
      case home:
        return MaterialPageRoute(builder: (_) => MainScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text("No route defined for ${settings.name}")),
          ),
        );
    }
  }
}
