import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../main.dart';
import 'auth_signup_screen.dart';

class _AuthColors {
  static const primaryGreen = Color(0xFF2E7D32);
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFE53935);
  static const textPrimary = Color(0xFF1C1B1F);
  static const textSecondary = Color(0xFF6B6B6B);
  // static const background = Color(0xFFF5F7F6);
  // static const cardBg = Colors.white;
}

class AuthSignInScreen extends StatefulWidget {
  const AuthSignInScreen({super.key});

  @override
  State<AuthSignInScreen> createState() => _AuthSignInScreenState();
}

class _AuthSignInScreenState extends State<AuthSignInScreen>
    with SingleTickerProviderStateMixin {
  // Controllers
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Focus nodes for better UX
  final _phoneFocusNode = FocusNode();
  final _otpFocusNode = FocusNode();

  // State variables
  bool _isOtpSent = false;
  bool _isLoading = false;
  bool _isPhoneValid = false;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupListeners();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    ));

    _animationController.forward();
  }

  void _setupListeners() {
    _phoneController.addListener(() {
      final isValid = _phoneController.text.length == 10;
      if (_isPhoneValid != isValid) {
        setState(() => _isPhoneValid = isValid);
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _phoneFocusNode.dispose();
    _otpFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ==================== Authentication Methods ====================

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Implement actual OTP sending logic
      // Simulating API call
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isOtpSent = true;
        });

        // Auto-focus OTP field
        Future.delayed(const Duration(milliseconds: 300), () {
          _otpFocusNode.requestFocus();
        });

        _showSuccessSnackBar('OTP sent successfully to ${_phoneController.text}');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Failed to send OTP. Please try again.');
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.signInWithPhone(
        _phoneController.text,
        _otpController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          // Navigate to AppInitializer which will handle proper routing
          NavigationHelper.pushAndRemoveUntil(context, const AppInitializer());
        } else {
          _showErrorSnackBar('Invalid OTP. Please try again.');
        }
      }

    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Verification failed. Please try again.');
      }
    }
  }

  void _resetOtpState() {
    setState(() {
      _isOtpSent = false;
      _otpController.clear();
    });
    _phoneFocusNode.requestFocus();
  }

  // ==================== UI Helper Methods ====================

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: AppConstants.spacingS),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: _AuthColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        margin: const EdgeInsets.all(AppConstants.spacingM),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: AppConstants.spacingS),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: _AuthColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        margin: const EdgeInsets.all(AppConstants.spacingM),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ==================== Build Methods ====================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF81C784).withValues(alpha: 0.3),
              Colors.white,
            ],
            stops: const [0.0, 0.5],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.spacingL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: size.height * 0.08),
                      _buildLogo(),
                      SizedBox(height: size.height * 0.05),
                      _buildHeader(),
                      SizedBox(height: size.height * 0.04),
                      _buildPhoneNumberField(),
                      if (_isOtpSent) ...[
                        const SizedBox(height: AppConstants.spacingL),
                        _buildOtpField(),
                        const SizedBox(height: AppConstants.spacingM),
                        _buildResendOtpButton(),
                      ],
                      const SizedBox(height: AppConstants.spacingXL),
                      _buildActionButton(),
                      if (_isOtpSent) ...[
                        const SizedBox(height: AppConstants.spacingM),
                        _buildChangeNumberButton(),
                      ],
                      const SizedBox(height: AppConstants.spacingL),
                      _buildSignUpLink(),
                      const SizedBox(height: AppConstants.spacingXL),
                      _buildSecurityFooter(),
                      const SizedBox(height: AppConstants.spacingM),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Center(
        child: Container(
          height: 90,
          width: 90,
          decoration: BoxDecoration(
            color: _AuthColors.primaryGreen.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.agriculture_outlined,
            size: 50,
            color: _AuthColors.primaryGreen,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: _AuthColors.textPrimary,
            letterSpacing: -0.5,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacingS),
        Text(
          _isOtpSent
              ? 'Enter the OTP sent to ${_phoneController.text}'
              : 'Sign in to access your account',
          style: const TextStyle(
            fontSize: 14,
            color: _AuthColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPhoneNumberField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _phoneController,
        focusNode: _phoneFocusNode,
        keyboardType: TextInputType.phone,
        enabled: !_isOtpSent,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        decoration: InputDecoration(
          labelText: 'Phone Number',
          hintText: '',
          hintStyle: const TextStyle(
            color: _AuthColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.phone_outlined,
            color: _AuthColors.textSecondary,
            size: 22,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: _isOtpSent
              ? _AuthColors.primaryGreen.withValues(alpha: 0.05)
              : Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingM,
            vertical: AppConstants.spacingM,
          ),
          labelStyle: const TextStyle(
            color: _AuthColors.textSecondary,
            fontSize: 14,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Phone number is required';
          }
          if (value.length != 10) {
            return 'Please enter a valid 10-digit phone number';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildOtpField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _otpController,
        focusNode: _otpFocusNode,
        keyboardType: TextInputType.number,
        autofocus: true,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ],
        decoration: InputDecoration(
          labelText: 'Enter OTP',
          hintText: '',
          prefixIcon: Icon(
            Icons.lock_outline,
            color: _AuthColors.textSecondary,
            size: 22,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingM,
            vertical: AppConstants.spacingM,
          ),
          labelStyle: const TextStyle(
            color: _AuthColors.textSecondary,
            fontSize: 14,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'OTP is required';
          }
          if (value.length != 6) {
            return 'Please enter a valid 6-digit OTP';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildResendOtpButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: _isLoading ? null : _sendOtp,
        icon: Icon(
          Icons.refresh,
          size: 18,
          color: _AuthColors.primaryGreen,
        ),
        label: Text(
          'Resend OTP',
          style: TextStyle(
            color: _AuthColors.primaryGreen,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildChangeNumberButton() {
    return TextButton.icon(
      onPressed: _isLoading ? null : _resetOtpState,
      icon: Icon(
        Icons.edit_outlined,
        size: 18,
        color: _AuthColors.textSecondary,
      ),
      label: const Text(
        'Change Phone Number',
        style: TextStyle(
          color: _AuthColors.textSecondary,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return PremiumButton(
      text: _isOtpSent ? 'Verify & Sign In' : 'Send OTP',
      onPressed: _isLoading ? null : (_isOtpSent ? _verifyOtp : _sendOtp),
      icon: _isLoading
          ? null
          : (_isOtpSent ? Icons.check_circle_outline : Icons.arrow_forward),
      isLoading: _isLoading,
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(
            color: _AuthColors.textSecondary,
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
            NavigationHelper.pushReplacement(
              context,
              const AuthSignUpScreen(),
            );
          },
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: _AuthColors.primaryGreen,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityFooter() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security_outlined,
            color: Colors.blue.shade700,
            size: 18,
          ),
          const SizedBox(width: AppConstants.spacingS),
          Expanded(
            child: Text(
              'Your data is secure and encrypted',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
