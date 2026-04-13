import 'package:ecommerce_app/Screens/main_screen.dart';
import 'package:ecommerce_app/services/auth_controller.dart';
import 'package:ecommerce_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;

  Future<void> _handleSignUp() async {
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showError("Please fill in all fields.");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError("Passwords do not match!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      await userCredential.user?.updateDisplayName(
        _usernameController.text.trim(),
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Registration failed";
      if (e.code == 'weak-password') {
        errorMessage = "The password provided is too weak.";
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "An account already exists for that email.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "The email address is not valid.";
      }
      _showError(errorMessage);
    } catch (e) {
      _showError("An unexpected error occurred.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_mall_rounded,
                    color: Colors.deepOrange,
                    size: 50,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
              const Text(
                'Sign up to start your journey with Shop Pro',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 40),
              _buildInput(
                "Full Name",
                Icons.person_outline,
                _usernameController,
              ),

              const SizedBox(height: 20),
              _buildInput(
                "Email Address",
                Icons.mail_outline,
                _emailController,
              ),

              const SizedBox(height: 20),
              _buildInput(
                "Password",
                Icons.lock_outline,
                _passwordController,
                isPass: true,
                isVisible: _isPasswordVisible,
                onToggle: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),

              const SizedBox(height: 20),
              _buildInput(
                "Confirm Password",
                Icons.lock_reset_outlined,
                _confirmPasswordController,
                isPass: true,
                isVisible: _isConfirmVisible,
                onToggle: () =>
                    setState(() => _isConfirmVisible = !_isConfirmVisible),
              ),

              const SizedBox(height: 30),
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepOrange,
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _handleSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        minimumSize: const Size.fromHeight(60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

              const SizedBox(height: 30),
              const Center(
                child: Text(
                  "OR",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              _isGoogleLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.blue),
                    )
                  : OutlinedButton.icon(
                      onPressed: () async {
                        setState(() => _isGoogleLoading = true);
                        try {
                          final UserCredential? result = await AuthService()
                              .signInWithGoogle(
                                skipLightweightAuthentication: true,
                                onBeforeFirebaseSignIn: () {
                                  if (!context.mounted) return;
                                  context
                                      .read<AuthController>()
                                      .markNeedsGoogleProfileSetup();
                                },
                              );

                          if (!context.mounted) return;
                          if (result == null) {
                            if (context.mounted) {
                              context
                                  .read<AuthController>()
                                  .clearNeedsGoogleProfileSetup();
                            }
                            return;
                          }

                          if (result.additionalUserInfo != null &&
                              result.additionalUserInfo!.isNewUser == false) {
                            if (context.mounted) {
                              context
                                  .read<AuthController>()
                                  .clearNeedsGoogleProfileSetup();
                            }
                            await _auth.signOut();
                            await GoogleSignIn.instance.signOut();
                            if (!context.mounted) return;
                            _showError(
                              'Account already exists. Use the Login page.',
                            );
                            return;
                          }
                          // New user (or no additionalUserInfo): flag already set
                          // in onBeforeFirebaseSignIn → ProfileSetupScreen.
                        } catch (e) {
                          if (context.mounted) {
                            context
                                .read<AuthController>()
                                .clearNeedsGoogleProfileSetup();
                          }
                          _showError("Sign up failed. Try again.");
                        } finally {
                          if (mounted) setState(() => _isGoogleLoading = false);
                        }
                      },
                      icon: Image.asset('assets/images/google.png', height: 55),
                      label: const Text(
                        "Continue with Google",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),

              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool isPass = false,
    bool? isVisible,
    VoidCallback? onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPass ? !(isVisible ?? false) : false,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.deepOrange),
        suffixIcon: isPass
            ? IconButton(
                icon: Icon(
                  (isVisible ?? false)
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: onToggle,
              )
            : null,
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
