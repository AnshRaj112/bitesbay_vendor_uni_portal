import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UniReset extends StatefulWidget {
  final String email;

  const UniReset({Key? key, required this.email}) : super(key: key);

  @override
  State<UniReset> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<UniReset> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

  final String backendUrl = const String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://localhost:3000',
  );

  bool validatePassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'\d').hasMatch(password) &&
        RegExp(r'[@$!%*?&]').hasMatch(password) &&
        !RegExp(r'\s').hasMatch(password);
  }

  Future<void> handleResetPassword() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmController.text;

    if (widget.email.isEmpty) {
      Fluttertoast.showToast(msg: "Invalid reset link. Please try again.");
      return;
    }

    if (password.isEmpty || confirmPassword.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill all fields.");
      return;
    }

    if (!validatePassword(password)) {
      Fluttertoast.showToast(
        msg:
            "Password must be at least 8 characters long, include uppercase, lowercase, number, and special character.",
      );
      return;
    }

    if (password != confirmPassword) {
      Fluttertoast.showToast(msg: "Passwords do not match.");
      return;
    }

    try {
      setState(() => _isLoading = true);
      final res = await http.post(
        Uri.parse('$backendUrl/api/user/auth/resetpassword'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": widget.email,
          "password": password,
        }),
      );

      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        Fluttertoast.showToast(msg: "Password reset successfully!");
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pushReplacementNamed("/login");
        });
      } else {
        Fluttertoast.showToast(msg: data['message'] ?? "Reset failed.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Something went wrong. Try again.");
    } finally {
      setState(() => _isLoading = false);
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
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Form(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.black, Colors.black],
                      ).createShader(bounds),
                      child: const Text(
                        "Reset Password",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    buildPasswordField(
                      controller: _passwordController,
                      hint: "New Password",
                      isPasswordVisible: _showPassword,
                      toggleVisibility: () {
                        setState(() => _showPassword = !_showPassword);
                      },
                    ),
                    const SizedBox(height: 10),
                    buildPasswordField(
                      controller: _confirmController,
                      hint: "Confirm Password",
                      isPasswordVisible: _showConfirmPassword,
                      toggleVisibility: () {
                        setState(
                            () => _showConfirmPassword = !_showConfirmPassword);
                      },
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _isLoading ? null : handleResetPassword,
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
                        alignment: Alignment.center,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Reset Password",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isPasswordVisible,
    required VoidCallback toggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isPasswordVisible,
      cursorColor: const Color(0xFF4EA199),
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: const Color(0xFF4EA199),
          ),
          onPressed: toggleVisibility,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0x804EA199)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF4EA199)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
