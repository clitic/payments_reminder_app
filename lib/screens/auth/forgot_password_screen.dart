import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';

/// Forgot password screen for password reset
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendPasswordResetEmail(
      _emailController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _emailSent = true;
      });
    } else {
      _showErrorSnackBar(authProvider.errorMessage ?? AppStrings.errorGeneric);
    }
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
      message: 'Sending reset email...',
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.resetPassword),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _emailSent ? _buildSuccessContent(theme) : _buildFormContent(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_reset,
                size: 40,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Header
          Center(
            child: Text(
              'Forgot your password?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          // Email field
          EmailTextField(
            controller: _emailController,
            validator: Validators.validateEmail,
            onSubmitted: (_) => _handleResetPassword(),
          ),
          const SizedBox(height: 24),
          // Submit button
          CustomButton(
            text: 'Send Reset Link',
            onPressed: _handleResetPassword,
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 16),
          // Back to login
          Center(
            child: TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Back to Login'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 60),
        // Success icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read,
            size: 50,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 32),
        // Success message
        Text(
          'Check your email',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'We\'ve sent a password reset link to:',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _emailController.text,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        // Instructions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildInstruction(
                theme,
                '1',
                'Open the email from Payment Reminder',
              ),
              const SizedBox(height: 12),
              _buildInstruction(
                theme,
                '2',
                'Click the reset password link',
              ),
              const SizedBox(height: 12),
              _buildInstruction(
                theme,
                '3',
                'Create a new password',
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Buttons
        CustomButton(
          text: 'Back to Login',
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            setState(() {
              _emailSent = false;
            });
          },
          child: const Text('Didn\'t receive the email? Try again'),
        ),
      ],
    );
  }

  Widget _buildInstruction(ThemeData theme, String number, String text) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
