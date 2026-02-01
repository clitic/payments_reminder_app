import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';
import '../dashboard/dashboard_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

/// Login screen for email/password authentication
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      _navigateToDashboard();
    } else {
      _showErrorSnackBar(authProvider.errorMessage ?? AppStrings.errorGeneric);
    }
  }

  Future<void> _handleGuestMode() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.continueAsGuest();

    if (!mounted) return;

    if (success) {
      _navigateToDashboard();
    } else {
      _showErrorSnackBar(authProvider.errorMessage ?? AppStrings.errorGeneric);
    }
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  void _navigateToForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();

    return LoadingOverlay(
      isLoading: authProvider.isLoading,
      message: 'Signing in...',
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      // Welcome header
                      _buildHeader(theme),
                      const SizedBox(height: 48),
                      // Email field
                      EmailTextField(
                        controller: _emailController,
                        validator: Validators.validateEmail,
                        onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                      ),
                      const SizedBox(height: 16),
                      // Password field
                      PasswordTextField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        validator: Validators.validatePassword,
                        onSubmitted: (_) => _handleLogin(),
                      ),
                      const SizedBox(height: 12),
                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _navigateToForgotPassword,
                          child: const Text(AppStrings.forgotPassword),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Sign in button
                      CustomButton(
                        text: AppStrings.signIn,
                        onPressed: _handleLogin,
                        isLoading: authProvider.isLoading,
                      ),
                      const SizedBox(height: 16),
                      // Guest mode button
                      CustomButton(
                        text: AppStrings.continueAsGuest,
                        onPressed: _handleGuestMode,
                        isOutlined: true,
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 32),
                      // Divider with text
                      _buildDivider(theme),
                      const SizedBox(height: 32),
                      // Register link
                      _buildRegisterLink(theme),
                      const SizedBox(height: 24),
                      // Guest mode info
                      _buildGuestModeInfo(theme),
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

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.payment,
            size: 32,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          AppStrings.welcomeBack,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.signInToContinue,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Row(
      children: [
        Expanded(child: Divider(color: theme.dividerColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ),
        Expanded(child: Divider(color: theme.dividerColor)),
      ],
    );
  }

  Widget _buildRegisterLink(ThemeData theme) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppStrings.dontHaveAccount,
            style: theme.textTheme.bodyMedium,
          ),
          TextButton(
            onPressed: _navigateToRegister,
            child: Text(
              AppStrings.signUp,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestModeInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Guest Mode',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Use the app offline without an account. Sign up later to sync across devices.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
