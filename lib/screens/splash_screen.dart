import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../services/biometric_service.dart';
import 'auth/login_screen.dart';
import 'dashboard/dashboard_screen.dart';

/// Splash screen for app initialization
/// Handles biometric authentication and navigation
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _isCheckingAuth = true;
  String _statusMessage = 'Loading...';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    // Wait for animations to start and auth provider to initialize
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    // Wait for auth provider to finish initializing with a timeout
    int waitCount = 0;
    const maxWaitCount = 50; // 5 seconds max wait
    while (!authProvider.isInitialized && waitCount < maxWaitCount) {
      await Future.delayed(const Duration(milliseconds: 100));
      waitCount++;
      if (!mounted) return;
    }

    // If still not initialized after timeout, navigate to login anyway
    if (!authProvider.isInitialized) {
      debugPrint('Auth provider initialization timed out, proceeding to login');
      _navigateToLogin();
      return;
    }

    setState(() {
      _statusMessage = 'Checking authentication...';
    });

    // Check if user is signed in
    if (!authProvider.isSignedIn) {
      _navigateToLogin();
      return;
    }

    // Check biometric lock
    if (settingsProvider.biometricEnabled) {
      setState(() {
        _statusMessage = 'Authenticating...';
      });

      final biometricResult =
          await BiometricService.instance.authenticateToUnlock();

      if (!mounted) return;

      if (!biometricResult.success) {
        // Biometric failed, show error and retry option
        setState(() {
          _isCheckingAuth = false;
          _statusMessage = biometricResult.message;
        });
        return;
      }
    }

    // All checks passed, go to dashboard
    _navigateToDashboard();
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const DashboardScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  Future<void> _retryBiometric() async {
    setState(() {
      _isCheckingAuth = true;
      _statusMessage = 'Authenticating...';
    });

    final biometricResult =
        await BiometricService.instance.authenticateToUnlock();

    if (!mounted) return;

    if (biometricResult.success) {
      _navigateToDashboard();
    } else {
      setState(() {
        _isCheckingAuth = false;
        _statusMessage = biometricResult.message;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // App icon and title
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.payment,
                              size: 60,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Payment Reminder',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Never miss a payment',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const Spacer(),
              // Loading indicator or retry button
              if (_isCheckingAuth) ...[
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  _statusMessage,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ] else ...[
                Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                const SizedBox(height: 16),
                Text(
                  _statusMessage,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _retryBiometric,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Try Again'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    context.read<AuthProvider>().signOut();
                    _navigateToLogin();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Sign Out'),
                ),
              ],
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
