import 'package:bitesbay_vendor_uni_portal/ForgotPassword/VendorForgot.dart';
import 'package:bitesbay_vendor_uni_portal/home.dart';
import 'package:bitesbay_vendor_uni_portal/ForgotPassword/UniForgot.dart';
import 'package:flutter/material.dart';
import 'Login/UniversityLogin.dart';
import 'Dashboard/dashboard_uni.dart';
import 'config/app_config.dart';

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
      routes: {
        '/ForgotPassword/UniForgot': (context) => const UniForgot(),
        '/ForgotPassword/VendorForgot': (context) => const VendorForgot(),
        '/login': (context) => const UniversityLogin(),
        '/dashboard/uni': (context) => const UniversityDashboard(),
      },
    );
  }
}
