import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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

  Future<void> _signup() async {
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();

    // Reset errors
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

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ✅ SUCCESS MESSAGE
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          content: Text(
            "Account created successfully. Please login.",
            style: TextStyle(
              color: Colors.white, // ✅ WHITE TEXT
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 800));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showError("This email is already registered");
      } else if (e.code == 'invalid-email') {
        _showError("Invalid email address");
      } else if (e.code == 'weak-password') {
        _showError("Password is too weak");
      } else {
        _showError("Signup failed. Please try again");
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ❌ ERROR SNACKBAR (WHITE TEXT)
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                "Create a new account",
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
                      child: InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Center(
                          child: Text(
                            "Login",
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          "Sign up",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
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

              // SIGNUP BUTTON
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signup,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                    color: Colors.black,
                  )
                      : const Text(
                    "Sign up",
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
