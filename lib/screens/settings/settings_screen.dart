import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/sync_provider.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

/// Settings screen
/// Manages app preferences, biometrics, sync, and account
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Account section
          _buildSectionHeader(theme, 'Account'),
          _buildAccountTile(context, theme, authProvider),
          const Divider(),

          // Appearance section
          _buildSectionHeader(theme, 'Appearance'),
          _buildThemeTile(context, theme, settingsProvider),
          const Divider(),

          // Notifications section
          _buildSectionHeader(theme, 'Notifications'),
          _buildNotificationsTile(context, theme, settingsProvider),
          _buildDefaultRemindersTile(context, theme, settingsProvider),
          const Divider(),

          // Security section
          _buildSectionHeader(theme, 'Security'),
          _buildBiometricTile(context, theme, settingsProvider),
          const Divider(),

          // Sync section
          if (!authProvider.isGuest) ...[
            _buildSectionHeader(theme, 'Sync'),
            _buildSyncTile(context, theme, authProvider),
            const Divider(),
          ],

          // About section
          _buildSectionHeader(theme, 'About'),
          _buildAboutTiles(context, theme),
          const Divider(),

          // Danger zone
          _buildSectionHeader(theme, 'Account Actions', isDestructive: true),
          _buildSignOutTile(context, theme, authProvider),
          if (!authProvider.isGuest)
            _buildDeleteAccountTile(context, theme),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, {bool isDestructive = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: isDestructive ? AppTheme.overdueColor : theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAccountTile(BuildContext context, ThemeData theme, AuthProvider authProvider) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
        child: Icon(
          authProvider.isGuest ? Icons.person_outline : Icons.person,
          color: theme.colorScheme.primary,
        ),
      ),
      title: Text(
        authProvider.isGuest
            ? 'Guest User'
            : authProvider.currentUser?.email ?? 'User',
      ),
      subtitle: Text(
        authProvider.isGuest
            ? 'Sign up to sync your data'
            : 'Signed in',
      ),
      trailing: authProvider.isGuest
          ? FilledButton(
              onPressed: () => _navigateToRegister(context),
              child: const Text('Sign Up'),
            )
          : null,
    );
  }

  Widget _buildThemeTile(BuildContext context, ThemeData theme, SettingsProvider settingsProvider) {
    return ListTile(
      leading: Icon(
        settingsProvider.themeMode == ThemeMode.dark
            ? Icons.dark_mode
            : settingsProvider.themeMode == ThemeMode.light
                ? Icons.light_mode
                : Icons.brightness_auto,
        color: theme.colorScheme.primary,
      ),
      title: const Text('Theme'),
      subtitle: Text(_getThemeModeLabel(settingsProvider.themeMode)),
      trailing: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(
            value: ThemeMode.light,
            icon: Icon(Icons.light_mode, size: 18),
          ),
          ButtonSegment(
            value: ThemeMode.system,
            icon: Icon(Icons.brightness_auto, size: 18),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            icon: Icon(Icons.dark_mode, size: 18),
          ),
        ],
        selected: {settingsProvider.themeMode},
        onSelectionChanged: (modes) {
          settingsProvider.setThemeMode(modes.first);
        },
        showSelectedIcon: false,
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  Widget _buildNotificationsTile(BuildContext context, ThemeData theme, SettingsProvider settingsProvider) {
    return SwitchListTile(
      secondary: Icon(
        Icons.notifications_outlined,
        color: theme.colorScheme.primary,
      ),
      title: const Text('Push Notifications'),
      subtitle: const Text('Receive payment reminders'),
      value: settingsProvider.notificationsEnabled,
      onChanged: (value) => settingsProvider.setNotificationsEnabled(value),
    );
  }

  Widget _buildDefaultRemindersTile(BuildContext context, ThemeData theme, SettingsProvider settingsProvider) {
    return ListTile(
      leading: Icon(
        Icons.alarm,
        color: theme.colorScheme.primary,
      ),
      title: const Text('Default Reminders'),
      subtitle: Text(
        settingsProvider.defaultReminderTypes.isEmpty
            ? 'None selected'
            : settingsProvider.defaultReminderTypes
                .map((t) => t.displayName)
                .join(', '),
      ),
      onTap: () => _showReminderSettingsDialog(context, settingsProvider),
    );
  }

  Widget _buildBiometricTile(BuildContext context, ThemeData theme, SettingsProvider settingsProvider) {
    return FutureBuilder<bool>(
      future: settingsProvider.checkBiometricsAvailable(),
      builder: (context, snapshot) {
        final isAvailable = snapshot.data ?? false;

        return SwitchListTile(
          secondary: Icon(
            Icons.fingerprint,
            color: theme.colorScheme.primary,
          ),
          title: const Text('Biometric Lock'),
          subtitle: Text(
            isAvailable
                ? 'Require fingerprint or Face ID to open app'
                : 'Not available on this device',
          ),
          value: settingsProvider.biometricEnabled,
          onChanged: isAvailable
              ? (value) async {
                  if (value) {
                    await settingsProvider.enableBiometric();
                  } else {
                    await settingsProvider.disableBiometric();
                  }
                }
              : null,
        );
      },
    );
  }

  Widget _buildSyncTile(BuildContext context, ThemeData theme, AuthProvider authProvider) {
    final syncProvider = context.watch<SyncProvider>();

    return ListTile(
      leading: Icon(
        Icons.sync,
        color: theme.colorScheme.primary,
      ),
      title: const Text('Last Synced'),
      subtitle: Text(syncProvider.lastSyncTimeFormatted),
      trailing: syncProvider.isSyncing
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : TextButton(
              onPressed: () async {
                final result = await syncProvider.syncNow(authProvider.userId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.message),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Sync Now'),
            ),
    );
  }

  Widget _buildAboutTiles(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.info_outline,
            color: theme.colorScheme.primary,
          ),
          title: const Text('App Version'),
          subtitle: const Text('1.0.0'),
        ),
        ListTile(
          leading: Icon(
            Icons.privacy_tip_outlined,
            color: theme.colorScheme.primary,
          ),
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.open_in_new, size: 18),
          onTap: () {
            // Open privacy policy
          },
        ),
        ListTile(
          leading: Icon(
            Icons.description_outlined,
            color: theme.colorScheme.primary,
          ),
          title: const Text('Terms of Service'),
          trailing: const Icon(Icons.open_in_new, size: 18),
          onTap: () {
            // Open terms of service
          },
        ),
      ],
    );
  }

  Widget _buildSignOutTile(BuildContext context, ThemeData theme, AuthProvider authProvider) {
    return ListTile(
      leading: const Icon(
        Icons.logout,
        color: AppTheme.overdueColor,
      ),
      title: const Text(
        'Sign Out',
        style: TextStyle(color: AppTheme.overdueColor),
      ),
      onTap: () => _handleSignOut(context, authProvider),
    );
  }

  Widget _buildDeleteAccountTile(BuildContext context, ThemeData theme) {
    return ListTile(
      leading: const Icon(
        Icons.delete_forever,
        color: AppTheme.overdueColor,
      ),
      title: const Text(
        'Delete Account',
        style: TextStyle(color: AppTheme.overdueColor),
      ),
      onTap: () => _showDeleteAccountDialog(context),
    );
  }

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _navigateToRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  Future<void> _handleSignOut(BuildContext context, AuthProvider authProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: Text(
          authProvider.isGuest
              ? 'You will lose all your local data. Are you sure?'
              : 'Are you sure you want to sign out?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.overdueColor,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final syncProvider = context.read<SyncProvider>();
      syncProvider.stopAutoSync();

      await authProvider.signOut();

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // Handle account deletion
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.overdueColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showReminderSettingsDialog(BuildContext context, SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Reminders'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: ReminderType.values.map((type) {
                return CheckboxListTile(
                  title: Text(type.displayName),
                  value: settingsProvider.isReminderTypeEnabled(type),
                  onChanged: (value) {
                    settingsProvider.toggleReminderType(type);
                    setState(() {});
                  },
                );
              }).toList(),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
