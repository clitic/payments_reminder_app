import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/sync_provider.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/secure_storage_service.dart';
import 'app.dart';

/// Application entry point
/// Initializes all services before running the app
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  await _initializeServices();

  // Run the app with providers
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
      ],
      child: const PaymentReminderApp(),
    ),
  );
}

/// Initialize all required services
Future<void> _initializeServices() async {
  try {
    // Initialize secure storage service (which initializes Hive)
    await SecureStorageService.instance.initialize();
    debugPrint('Secure storage initialized');

    // Initialize database service
    await DatabaseService.instance.database;
    debugPrint('Database initialized');

    // Initialize notification service
    try {
      await NotificationService.instance.initialize();
      await NotificationService.instance.requestPermissions();
      debugPrint('Notification service initialized');
    } catch (e) {
      debugPrint('Notification service initialization failed: $e');
    }

    debugPrint('All services initialized successfully');
  } catch (e) {
    debugPrint('Error initializing services: $e');
  }
}
