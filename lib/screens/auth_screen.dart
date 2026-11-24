import 'package:flutter/material.dart';
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

final TextEditingController _nameController = TextEditingController();
final TextEditingController _emailController = TextEditingController();
final TextEditingController _phoneController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();

void _handleSubmit() async {
if (_emailController.text.trim().isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Please enter your email address.'),
backgroundColor: AppColors.emergencyRed,
),
);
return;
}

if (!_isLogin && _nameController.text.trim().isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Please enter your full name.'),
backgroundColor: AppColors.emergencyRed,
),
);
return;
}

setState(() => _isLoading = true);

if (_isLogin) {
await VitaAuthService.instance.signInWithEmailAndPassword(
email: _emailController.text.trim(),
password: _passwordController.text,
);
} else {
await VitaAuthService.instance.registerWithEmailAndPassword(
email: _emailController.text.trim(),
password: _passwordController.text,
fullName: _nameController.text.trim(),
phone: _phoneController.text.trim(),
);
}

await Future.delayed(const Duration(milliseconds: 400));
if (!mounted) return;
setState(() => _isLoading = false);
Navigator.of(context).pushReplacementNamed(AppRoutes.mainShell);
}

void _showForgotPasswordSheet() {
showModalBottomSheet(
context: context,
isScrollControlled: true,
backgroundColor: Colors.transparent,
builder: (context) => Container(
padding: EdgeInsets.only(
bottom: MediaQuery.of(context).viewInsets.bottom + 24,
top: 24,
left: 24,
right: 24,
),
decoration: const BoxDecoration(
color: AppColors.white,
borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
'Enter your registered email address and we will send a cryptographic recovery link to regain vault access.',
style: TextStyle(
fontSize: 13,
color: AppColors.textSecondary,
height: 1.4,
),
),
const SizedBox(height: 20),
VitaTextField(
label: 'Email Address',
hint: 'e.g. kholoud@example.com',
prefixIcon: Icons.email_outlined,
controller: TextEditingController(text: _emailController.text),
),
const SizedBox(height: 24),
VitaButton(
label: 'Send Recovery Link',
icon: Icons.send_rounded,
onPressed: () {
Navigator.pop(context);
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Recovery instructions sent to your email.'),
backgroundColor: AppColors.primaryTeal,
),
);
},
),
],
),
),
);
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: AppColors.tealGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.favorite_rounded, color: AppColors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'VitaFile',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
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
                  : 'Get started with a HIPAA-compliant personal medical vault.',
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
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isLogin = true),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isLogin ? AppColors.white : Colors.transparent,
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
                              color: _isLogin ? AppColors.primaryTeal : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isLogin = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isLogin ? AppColors.white : Colors.transparent,
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
                              color: !_isLogin ? AppColors.primaryTeal : AppColors.textMuted,
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
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (v) => setState(() => _rememberMe = v ?? true),
                      ),
                      const Text(
                        'Remember Me',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _showForgotPasswordSheet,
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        'I agree to VitaFile Terms, HIPAA Privacy Policy, and encrypted local credential storage.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            VitaButton(
              label: _isLogin ? 'Sign In to Vault' : 'Create Encrypted Vault',
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