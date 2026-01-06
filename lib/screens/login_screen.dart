import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  String? _emailError;
  String? _passwordError;

  // 🔍 Email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(email);
  }

  Future<void> _login() async {
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();

    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    // ---- CLIENT SIDE VALIDATION ----
    if (email.isEmpty) {
      _emailError = "Email is required";
    } else if (!_isValidEmail(email)) {
      _emailError = "Enter a valid email address";
    }

    if (password.isEmpty) {
      _passwordError = "Password is required";
    } else if (password.length < 6) {
      _passwordError = "Password must be at least 6 characters";
    }

    if (_emailError != null || _passwordError != null) {
      setState(() {});
      return;
    }

    try {
      setState(() => _isLoading = true);

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showError("No account found with this email");
      } else if (e.code == 'wrong-password') {
        _showError("Incorrect password");
      } else if (e.code == 'invalid-email') {
        _showError("Invalid email format");
      } else {
        _showError("Login failed. Please try again");
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        padding: const EdgeInsets.symmetric( // ✅ USE padding
          horizontal: 16,
          vertical: 12,
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white, // ✅ WHITE TEXT
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // APP NAME
              const Text(
                "Appcrew Notes",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow,
                ),
              ),

              const SizedBox(height: 12),

              // SCREEN TITLE
              const Text(
                "Log in to your account",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 30),

              // SEGMENT SWITCH
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignupScreen(),
                            ),
                          );
                        },
                        child: const Center(
                          child: Text(
                            "Sign up",
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // EMAIL FIELD
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Email Address",
                  errorText: _emailError,
                  errorStyle: const TextStyle(
                    color: Colors.redAccent, // 🔴 RED ERROR
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // PASSWORD FIELD
              TextField(
                controller: passCtrl,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Password",
                  errorText: _passwordError,
                  errorStyle: const TextStyle(
                    color: Colors.redAccent, // 🔴 RED ERROR
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // LOGIN BUTTON
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                    color: Colors.black,
                  )
                      : const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
