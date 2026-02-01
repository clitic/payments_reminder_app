import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'providers/settings_provider.dart';
import 'screens/splash_screen.dart';

/// Main application widget
/// Sets up theming and initial route
class PaymentReminderApp extends StatelessWidget {
  const PaymentReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return MaterialApp(
          title: 'Payment Reminder',
          debugShowCheckedModeBanner: false,
          
          // Theme configuration
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settingsProvider.themeMode,
          
          // Initial route
          home: const SplashScreen(),
          
          // Builder for global configuration
          builder: (context, child) {
            return MediaQuery(
              // Prevent text scaling from affecting layout
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.noScaling,
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}
