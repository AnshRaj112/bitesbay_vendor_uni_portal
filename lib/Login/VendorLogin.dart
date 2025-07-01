import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:another_flushbar/flushbar.dart';

class VendorLogin extends StatefulWidget {
  const VendorLogin({super.key});

  @override
  State<VendorLogin> createState() => _VendorLogin();
}

class _VendorLogin extends State<VendorLogin> {
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;

  late final Timer _sessionTimer;

  final String backendUrl = const String.fromEnvironment("BACKEND_URL",
      defaultValue: "http://localhost:3000");

  @override
  void initState() {
    super.initState();
    checkSession();
    _sessionTimer =
        Timer.periodic(const Duration(hours: 1), (_) => checkSession());
  }

  @override
  void dispose() {
    _sessionTimer.cancel();
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // void showToast(String message, {bool success = true}) {
  //   Fluttertoast.showToast(
  //     msg: message,
  //     toastLength: Toast.LENGTH_SHORT,
  //     gravity: ToastGravity.BOTTOM,
  //     backgroundColor: success ? Colors.green : Colors.red,
  //     textColor: Colors.white,
  //   );
  // }

  void showToast(String message, {bool success = true}) {
    Flushbar(
      margin: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 5), // <-- controls width
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

      borderRadius: BorderRadius.circular(12),
      backgroundColor: Colors.white,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      icon: Icon(
        success ? Icons.check_circle : Icons.error,
        color: success ? Colors.green : Colors.red,
      ),
      messageText: Text(
        message,
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      duration: const Duration(seconds: 4),
      leftBarIndicatorColor: success ? Colors.green : Colors.red,
    ).show(context);
  }

  Future<void> handleLogin() async {
    final identifier = identifierController.text.trim();
    final password = passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      showToast("Please fill all the fields.", success: false);
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await http.post(
        Uri.parse('$backendUrl/api/user/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'identifier': identifier, 'password': password}),
      );

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(res.body);
      } catch (_) {
        showToast("Invalid server response.", success: false);
        return;
      }

      if (res.statusCode == 400 && data['redirectTo'] != null) {
        showToast("Account not verified. OTP sent to email.", success: false);
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, '/otpverification',
              arguments: {
                'email': identifier,
                'from': 'login',
              });
        });
        return;
      }

      if (res.statusCode != 200) {
        showToast(data['message'] ?? "Login failed. Please try again.",
            success: false);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);

      final user = data['user'];
      final collegeName = (user['college']['name'] as String?)
              ?.toLowerCase()
              .replaceAll(' ', '-') ??
          'college';
      final collegeId = user['college']['_id'] ?? '';

      showToast("Login successful!");

      final redirectPath =
          '/home/$collegeName${collegeId.isNotEmpty ? '?cid=$collegeId' : ''}';

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, redirectPath);
      });
    } catch (e) {
      showToast("An unexpected error occurred. Please try again.",
          success: false);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final res = await http.get(
        Uri.parse('$backendUrl/api/user/auth/refresh'),
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['token'] != null) {
          await prefs.setString('token', data['token']);
          print("✅ Session refreshed successfully");
        }
      } else if (res.statusCode == 401 || res.statusCode == 403) {
        await prefs.remove('token');
        print("🔴 Session expired, redirecting to login...");
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        print("⚠️ Unexpected response from server");
      }
    } catch (e) {
      print("❌ Error refreshing session: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF4EA199)),
              onPressed: () => Navigator.pushNamed(context, '/'),
            ),
          ),
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.black, Colors.black],
                    ).createShader(bounds),
                    child: const Text(
                      'Vendor Login',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Email or Phone Field
                  TextField(
                    controller: identifierController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: 'Email or Phone',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(78, 161, 153, 0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Color(0xFF4EA199), width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Password Field
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      TextField(
                        controller: passwordController,
                        obscureText: !showPassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => handleLogin(),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Color.fromRGBO(78, 161, 153, 0.5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Color(0xFF4EA199), width: 1.5),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                            showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: const Color(0xFF4EA199)),
                        onPressed: () =>
                            setState(() => showPassword = !showPassword),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, '/forgotpassword'),
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF4EA199), Color(0xFF6FC3BD)],
                        ).createShader(bounds),
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Login Button
                  GestureDetector(
                    onTap: isLoading ? null : handleLogin,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4EA199), Color(0xFF6FC3BD)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          if (!isLoading)
                            const BoxShadow(
                              color: Color.fromRGBO(78, 161, 153, 0.3),
                              offset: Offset(0, 4),
                              blurRadius: 8,
                            ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          isLoading ? 'Logging in...' : 'Login',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/signup'),
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: const TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(
                                foreground: Paint()
                                  ..shader = const LinearGradient(
                                    colors: [
                                      Color(0xFF4EA199),
                                      Color(0xFF6FC3BD)
                                    ],
                                  ).createShader(
                                      const Rect.fromLTWH(0, 0, 200, 70)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
