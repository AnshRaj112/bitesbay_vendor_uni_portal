import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import '../config/app_config.dart';

class VendorOtp extends StatefulWidget {
  final String email;
  final String? fromPage;

  const VendorOtp({
    Key? key,
    required this.email,
    this.fromPage,
  }) : super(key: key);

  @override
  State<VendorOtp> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<VendorOtp> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool isLoading = false;

  final String backendUrl = AppConfig.backendUrl;

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void handleChange(String value, int index) {
    if (value.isNotEmpty && index < _otpControllers.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  void handlePaste(String pastedText) {
    final digits = pastedText.replaceAll(RegExp(r'\D'), '').split('');
    for (int i = 0; i < 6 && i < digits.length; i++) {
      _otpControllers[i].text = digits[i];
    }
    if (digits.length == 6) {
      _focusNodes[5].requestFocus();
    }
  }

  Future<void> handleVerifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 6-digit OTP.')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/api/vendor/auth/otpverification'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': widget.email, 'otp': otp}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'];
        final userRes = await http.get(
          Uri.parse('$backendUrl/api/vendor/auth/user'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (userRes.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP verified successfully!')),
          );
          if (widget.fromPage == 'forgotpassword') {
            Navigator.pushReplacementNamed(context, '/ResetPassword/VendorReset',
                arguments: {'email': widget.email});
          } else {
            Navigator.pushReplacementNamed(context, '/dashboard_vendor');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch user data.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'OTP verification failed.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildOtpField(int index) {
    return SizedBox(
      width: 45,
      height: 50,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        maxLength: 1,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 20, color: Colors.black),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF4EA199), width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF4EA199), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: (value) {
          if (value.length > 1) {
            _otpControllers[index].text = value[value.length - 1];
            _otpControllers[index].selection = TextSelection.fromPosition(
              TextPosition(offset: 1),
            );
          }
          if (value.isNotEmpty && index < _otpControllers.length - 1) {
            _focusNodes[index + 1].requestFocus();
          }
        },
        onTap: () {
          if (index == 0) {
            handlePasteClipboard();
          }
        },
      ),
    );
  }

  Future<void> handlePasteClipboard() async {
    final clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData?.text != null) {
      handlePaste(clipboardData!.text!);
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
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(30),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "OTP Verification",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        foreground: Paint()
                          ..shader = const LinearGradient(
                            colors: [Colors.black, Colors.black],
                          ).createShader(
                              const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text("Enter the OTP sent to ${widget.email}",
                        style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 24),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          6,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4), // slightly reduced
                            child: buildOtpField(index),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: isLoading ? null : handleVerifyOtp,
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
                            isLoading ? 'Verifying...' : 'Verify OTP',
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
          ),
        ],
      ),
    );
  }
}
