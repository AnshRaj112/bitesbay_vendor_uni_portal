import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UniForgot extends StatefulWidget {
  const UniForgot({Key? key}) : super(key: key);

  @override
  State<UniForgot> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<UniForgot> {
  final TextEditingController _identifierController = TextEditingController();
  bool _isLoading = false;

  Future<void> handleForgotPassword() async {
    final identifier = _identifierController.text.trim();

    if (identifier.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter your email or phone number.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
            "${const String.fromEnvironment('BACKEND_URL')}/api/user/auth/forgotpassword"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"identifier": identifier}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "OTP sent successfully! Check your registered email.",
          backgroundColor: Colors.green,
        );

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushNamed(
            context,
            '/otpverification',
            arguments: {
              "email": data['email'],
              "from": "forgotpassword",
            },
          );
        });
      } else {
        Fluttertoast.showToast(
          msg: data['message'] ?? "Failed to send reset email.",
          backgroundColor: Colors.red,
        );
      }
    } catch (error) {
      debugPrint("Forgot Password Error: $error");
      Fluttertoast.showToast(msg: "Something went wrong. Try again.");
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.black, Colors.black],
                    ).createShader(bounds),
                    child: const Text(
                      'Forgot Password',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Text(
                      'Enter your email or phone number to receive a password reset email.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _identifierController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: 'Email or Phone',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color.fromRGBO(78, 161, 153, 0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF4EA199),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _isLoading ? null : handleForgotPassword,
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
                          if (!_isLoading)
                            const BoxShadow(
                              color: Color.fromRGBO(78, 161, 153, 0.3),
                              offset: Offset(0, 4),
                              blurRadius: 8,
                            ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _isLoading ? 'Sending OTP...' : 'Send OTP',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
