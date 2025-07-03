import 'package:bitesbay_vendor_uni_portal/ForgotPassword/VendorForgot.dart';
import 'package:bitesbay_vendor_uni_portal/ResetPassword/VendorReset.dart';
import 'package:bitesbay_vendor_uni_portal/home.dart';
import 'package:bitesbay_vendor_uni_portal/ForgotPassword/UniForgot.dart';
import 'package:bitesbay_vendor_uni_portal/ResetPassword/UniReset.dart';
import 'package:bitesbay_vendor_uni_portal/OtpVerify/UniOtp.dart';
import 'package:bitesbay_vendor_uni_portal/OtpVerify/VendorOtp.dart';
import 'package:flutter/material.dart';
import 'package:bitesbay_vendor_uni_portal/Dashboard/dashboard_uni.dart';
import 'package:bitesbay_vendor_uni_portal/Dashboard/dashboard_vendor.dart';
import 'package:bitesbay_vendor_uni_portal/Login/UniversityLogin.dart';
import 'package:bitesbay_vendor_uni_portal/Login/VendorLogin.dart';
// import 'Login/UniversityLogin.dart';
// import 'Dashboard/dashboard_uni.dart';
// import 'config/app_config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Login Demo',
        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),
        home: const Home(),
        onGenerateRoute: (settings) {
          // Handle named routes with arguments
          if (settings.name == '/ResetPassword/UniReset') {
            final args = settings.arguments as Map<String, dynamic>;
            final email = args['email'] as String;
            return MaterialPageRoute(
              builder: (context) => UniReset(email: email),
            );
          }
          if (settings.name == '/ResetPassword/VendorReset') {
            final args = settings.arguments as Map<String, dynamic>;
            final email = args['email'] as String;
            return MaterialPageRoute(
              builder: (context) => VendorReset(email: email),
            );
          }
          if (settings.name == '/OtpVerify/UniOtp') {
            final args = settings.arguments as Map<String, dynamic>;
            final email = args['email'] as String;
            final fromPage = args['from'] as String?;
            return MaterialPageRoute(
              builder: (context) => UniOtp(email: email, fromPage: fromPage),
            );
          }
          if (settings.name == '/OtpVerify/VendorOtp') {
            final args = settings.arguments as Map<String, dynamic>;
            final email = args['email'] as String;
            final fromPage = args['from'] as String?;
            return MaterialPageRoute(
              builder: (context) => VendorOtp(email: email, fromPage: fromPage),
            );
          }
          switch (settings.name) {
            case '/ForgotPassword/UniForgot':
              return MaterialPageRoute(builder: (_) => const UniForgot());
            case '/ForgotPassword/VendorForgot':
              return MaterialPageRoute(builder: (_) => const VendorForgot());
            case '/dashboard_uni':
              return MaterialPageRoute(builder: (_) => const UniversityDashboard());
            case '/dashboard_vendor':
              return MaterialPageRoute(builder: (_) => const VendorDashboard());
            case '/Login/UniversityLogin':
              return MaterialPageRoute(builder: (_) => const UniversityLogin());
            case '/Login/VendorLogin':
              return MaterialPageRoute(builder: (_) => const VendorLogin());
            default:
              return null;
          }
        });
  }
}
