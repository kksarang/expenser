import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/user_provider.dart';
// import '../widgets/custom_button.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/custom_snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await Provider.of<UserProvider>(
        context,
        listen: false,
      ).loginWithEmail(_emailController.text, _passwordController.text);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _passwordController.clear(); // Clear password on error
        _showAuthError(context, e.code);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(context, 'Login failed. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final credential = await Provider.of<UserProvider>(
        context,
        listen: false,
      ).loginWithGoogle();

      // If credential is null, user cancelled. Stop here.
      if (credential == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _showAuthError(context, e.code);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(context, 'Google Login Failed: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAuthError(BuildContext context, String code) {
    String message;
    switch (code) {
      case 'wrong-password':
        message = 'Incorrect password. Please try again.';
        break;
      case 'user-not-found':
        message = 'No account found with this email.';
        break;
      case 'invalid-email':
        message = 'Please enter a valid email address.';
        break;
      case 'invalid-credential':
        message = 'Incorrect email or password.';
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Please try again later.';
        break;
      case 'network-request-failed':
        message = 'No internet connection. Please try again.';
        break;
      default:
        message = 'Login failed. Please try again.';
    }
    _showErrorSnackbar(context, message);
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    CustomSnackBar.showError(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final responsiveWidth = Responsive.width(context);
    final responsiveHeight = Responsive.height(context);
    final isSmall = Responsive.isSmall(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: responsiveWidth * 0.06, // 6% of width
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 600, // Limit width on tablets/desktops
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: responsiveHeight * 0.02),
                    // Logo/Brand
                    Center(
                      child: Image.asset(
                        'assets/images/theme.png',
                        width: isSmall ? 150 : responsiveWidth * 0.5,
                        height: isSmall ? 150 : responsiveWidth * 0.5,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: responsiveHeight * 0.01),
                    Text(
                      'Login',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: Responsive.fontSize(context, 28),
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: responsiveHeight * 0.03),
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.inter(
                        fontSize: Responsive.fontSize(context, 16),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your Email',
                        hintStyle: GoogleFonts.inter(
                          fontSize: Responsive.fontSize(context, 14),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFF1F1FA),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFF1F1FA),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.all(isSmall ? 12 : 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Please enter email';
                        return null;
                      },
                    ),
                    SizedBox(height: responsiveHeight * 0.02),
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: GoogleFonts.inter(
                        fontSize: Responsive.fontSize(context, 16),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: GoogleFonts.inter(
                          fontSize: Responsive.fontSize(context, 14),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFF1F1FA),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFF1F1FA),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.all(isSmall ? 12 : 16),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                            size: isSmall ? 20 : 24,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Please enter password';
                        return null;
                      },
                    ),
                    SizedBox(height: responsiveHeight * 0.04),
                    // Login Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: isSmall ? 12 : 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 24, // Fixed height matching icon/text
                              width: 24,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Login',
                              style: GoogleFonts.inter(
                                fontSize: Responsive.fontSize(context, 18),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    SizedBox(height: responsiveHeight * 0.03),
                    // Or Login with
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[300])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Or Sign In with',
                            style: GoogleFonts.inter(
                              color: Colors.grey,
                              fontSize: Responsive.fontSize(context, 14),
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey[300])),
                      ],
                    ),
                    SizedBox(height: responsiveHeight * 0.03),
                    // Social Buttons
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isLoading ? null : _loginWithGoogle,
                          borderRadius: BorderRadius.circular(30),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: isSmall ? 12 : 14,
                              horizontal: 16,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                                  height: 24,
                                  width: 24,
                                  errorBuilder: (ctx, _, __) =>
                                      Icon(Icons.g_mobiledata, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Continue with Google',
                                  style: GoogleFonts.roboto(
                                    // Changed to Roboto to match standard
                                    color: Colors.black87,
                                    fontSize: Responsive.fontSize(context, 16),
                                    fontWeight:
                                        FontWeight.w500, // Medium weight
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: responsiveHeight * 0.05),

                    Center(
                      child: TextButton(
                        onPressed: () async {
                          await Provider.of<UserProvider>(
                            context,
                            listen: false,
                          ).loginAsGuest();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(context, '/home');
                          }
                        },
                        child: Text(
                          'Continue as Guest',
                          style: GoogleFonts.inter(
                            color: AppColors.grey,
                            fontWeight: FontWeight.w600,
                            fontSize: Responsive.fontSize(context, 16),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: responsiveHeight * 0.02),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
