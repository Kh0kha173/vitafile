
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/app_colors.dart';
import '../core/navigation/app_router.dart';
import '../services/auth_service.dart';
import '../widgets/vita_button.dart';
import '../widgets/vita_text_field.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;
  bool _isResetLoading = false;

  DateTime? _cooldownUntil;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool get _isCoolingDown {
    if (_cooldownUntil == null) return false;

    if (DateTime.now().isAfter(_cooldownUntil!)) {
      _cooldownUntil = null;
      return false;
    }

    return true;
  }

  Future<void> _handleSubmit() async {
    if (!mounted || _isLoading) return;

    if (_isCoolingDown) {
      _showMessage(
        'Too many attempts. Please wait before trying again.',
      );
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      _showMessage('Please enter your email address.');
      return;
    }

    if (password.isEmpty) {
      _showMessage('Please enter your password.');
      return;
    }

    if (!_isLogin) {
      if (_nameController.text.trim().isEmpty) {
        _showMessage('Please enter your full name.');
        return;
      }

      if (_phoneController.text.trim().isEmpty) {
        _showMessage('Please enter your phone number.');
        return;
      }

      if (!_agreedToTerms) {
        _showMessage('Please agree to the terms and conditions.');
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    final stopwatch = Stopwatch()..start();

    try {
      if (_isLogin) {
        await VitaAuthService.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await VitaAuthService.instance.registerWithEmailAndPassword(
          email: email,
          password: password,
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        );
      }

      stopwatch.stop();

      debugPrint(
        'Authentication completed in '
            '${stopwatch.elapsedMilliseconds} ms',
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed(
        AppRoutes.mainShell,
      );
    } on FirebaseAuthException catch (e) {
      stopwatch.stop();

      debugPrint(
        'Authentication failed after '
            '${stopwatch.elapsedMilliseconds} ms: ${e.code}',
      );

      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered. Please sign in.';
          break;

        case 'wrong-password':
        case 'invalid-credential':
          message = 'Incorrect email or password.';
          break;

        case 'user-not-found':
          message = 'No account found with this email.';
          break;

        case 'email-not-verified':
          message = 'Please verify your email before signing in.';
          break;

        case 'too-many-requests':
          _cooldownUntil = DateTime.now().add(
            const Duration(minutes: 5),
          );
          message =
          'Too many attempts. Please wait before trying again.';
          break;

        case 'network-request-failed':
          message = 'Check your internet connection.';
          break;

        case 'weak-password':
          message = 'Please choose a stronger password.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'operation-not-allowed':
          message = 'This sign-in method is not enabled.';
          break;

        default:
          message = e.message ?? 'Something went wrong. Please try again.';
      }

      _showMessage(message);
    } catch (e) {
      stopwatch.stop();

      debugPrint(
        'Authentication error after '
            '${stopwatch.elapsedMilliseconds} ms: $e',
      );

      if (!mounted) return;

      if (e.toString().contains('email-not-verified')) {
        _showMessage('Please verify your email before signing in.');
      } else {
        _showMessage('Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.emergencyRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _showForgotPasswordSheet() {
    if (_isLoading || _isResetLoading) return;

    final resetEmailController = TextEditingController(
      text: _emailController.text.trim(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.only(
                bottom: 24,
                top: 24,
                left: 24,
                right: 24,
              ),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Reset Encrypted Password',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your registered email address and we will send a recovery link.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  VitaTextField(
                    label: 'Email Address',
                    hint: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    controller: resetEmailController,
                  ),
                  const SizedBox(height: 24),
                  VitaButton(
                    label: 'Send Recovery Link',
                    icon: Icons.send_rounded,
                    isLoading: _isResetLoading,
                    onPressed: () async {
                      if (_isResetLoading) return;

                      final email = resetEmailController.text.trim();

                      if (email.isEmpty) {
                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please enter your email address.',
                            ),
                          ),
                        );
                        return;
                      }

                      setSheetState(() {
                        _isResetLoading = true;
                      });

                      try {
                        await VitaAuthService.instance
                            .sendPasswordResetEmail(email);

                        if (!mounted || !sheetContext.mounted) return;

                        Navigator.pop(sheetContext);

                        _showMessage(
                          'Password reset email sent successfully.',
                        );
                      } on FirebaseAuthException catch (e) {
                        if (!sheetContext.mounted) return;

                        String message;

                        if (e.code == 'too-many-requests') {
                          message =
                          'Too many attempts. Please try again later.';
                        } else if (e.code == 'invalid-email') {
                          message = 'Please enter a valid email address.';
                        } else if (e.code == 'network-request-failed') {
                          message = 'Check your internet connection.';
                        } else {
                          message = e.message ??
                              'Failed to send recovery email.';
                        }

                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      } catch (e) {
                        if (!sheetContext.mounted) return;

                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Failed to send recovery email.',
                            ),
                          ),
                        );
                      } finally {
                        if (mounted && sheetContext.mounted) {
                          setSheetState(() {
                            _isResetLoading = false;
                          });
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).whenComplete(() {
      resetEmailController.dispose();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/images/vitafile_logo.png',
                  width: 220,
                  height: 65,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                ),
              ),

              const SizedBox(height: 28),

              Text(
                _isLogin ? 'Welcome back' : 'Create your\nHealth Vault',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _isLogin
                    ? 'Authenticate to unlock your decrypted records.'
                    : 'Get started with your personal medical vault.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.cardBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () {
                          setState(() {
                            _isLogin = true;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isLogin
                                ? AppColors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _isLogin
                                ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                              ),
                            ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _isLogin
                                    ? AppColors.primaryTeal
                                    : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () {
                          setState(() {
                            _isLogin = false;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_isLogin
                                ? AppColors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: !_isLogin
                                ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                              ),
                            ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: !_isLogin
                                    ? AppColors.primaryTeal
                                    : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              if (!_isLogin) ...[
                VitaTextField(
                  label: 'Full Legal Name',
                  hint: 'Enter your full name',
                  prefixIcon: Icons.person_outline_rounded,
                  controller: _nameController,
                ),
                const SizedBox(height: 16),
                VitaTextField(
                  label: 'Mobile Phone',
                  hint: '+20 100 000 0000',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  controller: _phoneController,
                ),
                const SizedBox(height: 16),
              ],
              VitaTextField(
                label: 'Email Address',
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                controller: _emailController,
              ),

              const SizedBox(height: 16),
              VitaTextField(
                label: 'Password',
                hint: 'Enter your password',
                obscureText: _obscurePassword,
                prefixIcon: Icons.lock_outline_rounded,
                controller: _passwordController,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 12),
              if (_isLogin)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          activeColor: AppColors.primaryTeal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (v) {
                            setState(() {
                              _rememberMe = v ?? true;
                            });
                          },
                        ),
                        const Text(
                          'Remember Me',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : _showForgotPasswordSheet,
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      activeColor: AppColors.primaryTeal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (v) {
                        setState(() {
                          _agreedToTerms = v ?? false;
                        });
                      },
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          'I agree to VitaFile Terms, Privacy Policy, and encrypted local credential storage.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 20),
              VitaButton(
                label: _isLogin
                    ? 'Sign In to Vault'
                    : 'Create Encrypted Vault',
                icon: Icons.shield_rounded,
                isLoading: _isLoading,
                onPressed: _handleSubmit,
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
