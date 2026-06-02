import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../navigation_menu.dart';
import '../provider/auth_provider.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final errorMessage = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NavigationMenu()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea( // Ensures content doesn't hit the notch
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Branding
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.hub_rounded, size: 40, color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Log in to continue to Creator Hub',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 48),

                  // Reusable Custom Text Fields!
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Email Address',
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary),
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                    obscureText: true,
                    validator: Validators.validatePassword,
                  ),
                  const SizedBox(height: 40),

                  // Elevated Login Button
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 4,
                      shadowColor: AppColors.primary.withOpacity(0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.surface, strokeWidth: 2))
                        : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.surface)),
                  ),
                  const SizedBox(height: 24),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ", style: TextStyle(color: AppColors.textSecondary)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen()));
                        },
                        child: const Text('Sign up', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}