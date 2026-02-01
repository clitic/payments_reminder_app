import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';
import '../dashboard/dashboard_screen.dart';

/// Register screen for new user sign up
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  String? _passwordStrength;
  Color? _passwordStrengthColor;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _updatePasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = null;
        _passwordStrengthColor = null;
      });
      return;
    }

    final result = Validators.getPasswordStrength(password);
    Color color;

    switch (result.strength) {
      case 0:
      case 1:
        color = Colors.red;
        break;
      case 2:
        color = Colors.orange;
        break;
      case 3:
        color = Colors.lightGreen;
        break;
      case 4:
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    setState(() {
      _passwordStrength = result.label;
      _passwordStrengthColor = color;
    });
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      _showErrorSnackBar('Please agree to the Terms of Service');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      _showSuccessSnackBar(AppStrings.accountCreated);
      _navigateToDashboard();
    } else {
      _showErrorSnackBar(authProvider.errorMessage ?? AppStrings.errorGeneric);
    }
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
      (route) => false,
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
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
      message: 'Creating account...',
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.createAccount),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(theme),
                  const SizedBox(height: 32),
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
                    label: 'Password',
                    validator: Validators.validateStrongPassword,
                    onChanged: _updatePasswordStrength,
                    onSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
                  ),
                  // Password strength indicator
                  if (_passwordStrength != null) ...[
                    const SizedBox(height: 8),
                    _buildPasswordStrength(theme),
                  ],
                  const SizedBox(height: 16),
                  // Confirm password field
                  PasswordTextField(
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocusNode,
                    label: 'Confirm Password',
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    onSubmitted: (_) => _handleRegister(),
                  ),
                  const SizedBox(height: 24),
                  // Terms checkbox
                  _buildTermsCheckbox(theme),
                  const SizedBox(height: 24),
                  // Register button
                  CustomButton(
                    text: AppStrings.signUp,
                    onPressed: _handleRegister,
                    isLoading: authProvider.isLoading,
                  ),
                  const SizedBox(height: 24),
                  // Login link
                  _buildLoginLink(theme),
                ],
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
        Text(
          'Get Started',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Create an account to sync your payments across devices',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStrength(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: theme.colorScheme.surfaceContainerHighest,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _getStrengthFraction(),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: _passwordStrengthColor,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          _passwordStrength!,
          style: theme.textTheme.labelSmall?.copyWith(
            color: _passwordStrengthColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  double _getStrengthFraction() {
    switch (_passwordStrength) {
      case 'Weak':
        return 0.25;
      case 'Fair':
        return 0.5;
      case 'Good':
        return 0.75;
      case 'Strong':
        return 1.0;
      default:
        return 0.0;
    }
  }

  Widget _buildTermsCheckbox(ThemeData theme) {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _agreedToTerms,
            onChanged: (value) {
              setState(() {
                _agreedToTerms = value ?? false;
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink(ThemeData theme) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppStrings.alreadyHaveAccount,
            style: theme.textTheme.bodyMedium,
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.signIn,
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
}
