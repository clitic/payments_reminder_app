import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_theme.dart';
import '../../models/payment.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/sync_provider.dart';
import '../../widgets/payment_list.dart';
import '../../widgets/payment_card.dart';
import '../../widgets/summary_card.dart';
import '../payments/add_edit_payment_screen.dart';
import '../payments/payment_detail_screen.dart';
import '../calendar/calendar_screen.dart';
import '../settings/settings_screen.dart';
import '../auth/login_screen.dart';

/// Main dashboard screen
/// Displays payment summary and list with navigation
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  PaymentStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final paymentProvider = context.read<PaymentProvider>();
    final syncProvider = context.read<SyncProvider>();

    // Load payments
    await paymentProvider.loadPayments(authProvider.userId);

    // Start auto-sync if logged in
    if (!authProvider.isGuest) {
      syncProvider.startAutoSync(
        userId: authProvider.userId,
        isGuest: authProvider.isGuest,
      );
    }
  }

  void _onNavItemSelected(int index) {
    if (index == 1) {
      // Calendar
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CalendarScreen()),
      );
    } else if (index == 2) {
      // Settings
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _onFilterByStatus(PaymentStatus? status) {
    setState(() {
      _filterStatus = status;
    });
    context.read<PaymentProvider>().setSelectedStatus(status);
  }

  void _navigateToAddPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditPaymentScreen()),
    ).then((_) => _loadData());
  }

  void _navigateToPaymentDetail(Payment payment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentDetailScreen(payment: payment),
      ),
    ).then((_) => _loadData());
  }

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
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

    if (confirmed == true && mounted) {
      final syncProvider = context.read<SyncProvider>();
      syncProvider.stopAutoSync();

      await context.read<AuthProvider>().signOut();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final paymentProvider = context.watch<PaymentProvider>();

    return Scaffold(
      appBar: _buildAppBar(theme, authProvider),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Column(
          children: [
            // Summary cards (non-scrollable header)
            _buildSummarySection(theme, paymentProvider),
            // Status filter chips
            _buildFilterSection(theme),
            // Payment list header
            _buildListHeader(theme, paymentProvider),
            // Payment list (scrollable)
            Expanded(
              child: paymentProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : paymentProvider.filteredPayments.isEmpty
                      ? _buildEmptyState(theme)
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: paymentProvider.filteredPayments.length,
                          itemBuilder: (context, index) {
                            final payment = paymentProvider.filteredPayments[index];
                            return PaymentCard(
                              payment: payment,
                              onTap: () => _navigateToPaymentDetail(payment),
                              onMarkPaid: () async {
                                final wasPaid = payment.status == PaymentStatus.paid;
                                final success = await paymentProvider.togglePaidStatus(payment.id);
                                if (mounted) {
                                  final messenger = ScaffoldMessenger.of(context);
                                  messenger.clearSnackBars();
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success 
                                            ? (wasPaid ? 'Payment marked as unpaid' : 'Payment marked as paid')
                                            : 'Failed to update payment',
                                      ),
                                      backgroundColor: success ? AppTheme.paidColor : AppTheme.overdueColor,
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddEditPaymentScreen(payment: payment),
                                  ),
                                ).then((_) => _loadData());
                              },
                              onDelete: () async {
                                final confirmed = await _showDeleteConfirmation(payment.title);
                                if (confirmed == true) {
                                  final success = await paymentProvider.deletePayment(payment.id);
                                  if (mounted) {
                                    final messenger = ScaffoldMessenger.of(context);
                                    messenger.clearSnackBars();
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          success 
                                              ? 'Payment "${payment.title}" deleted'
                                              : 'Failed to delete payment',
                                        ),
                                        backgroundColor: success ? AppTheme.paidColor : AppTheme.overdueColor,
                                        behavior: SnackBarBehavior.floating,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddPayment,
        icon: const Icon(Icons.add),
        label: const Text('Add Payment'),
      ),
      bottomNavigationBar: _buildBottomNav(theme),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, AuthProvider authProvider) {
    final syncProvider = context.watch<SyncProvider>();

    return AppBar(
      title: const Text('Payment Reminder'),
      actions: [
        // Sync indicator
        if (!authProvider.isGuest)
          IconButton(
            onPressed: () async {
              final result = await syncProvider.syncNow(authProvider.userId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.message),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: syncProvider.isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Badge(
                    isLabelVisible: syncProvider.hasPendingChanges,
                    child: const Icon(Icons.sync),
                  ),
            tooltip: 'Sync',
          ),
        // User menu
        PopupMenuButton<String>(
          icon: CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            child: Icon(
              authProvider.isGuest ? Icons.person_outline : Icons.person,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          onSelected: (value) {
            if (value == 'signout') {
              _handleSignOut();
            } else if (value == 'settings') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authProvider.isGuest
                        ? 'Guest User'
                        : authProvider.currentUser?.email ?? 'User',
                    style: theme.textTheme.titleSmall,
                  ),
                  if (authProvider.isGuest)
                    Text(
                      'Sign up to sync data',
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings_outlined),
                title: Text('Settings'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'signout',
              child: ListTile(
                leading: Icon(Icons.logout, color: AppTheme.overdueColor),
                title: Text('Sign Out', style: TextStyle(color: AppTheme.overdueColor)),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSummarySection(ThemeData theme, PaymentProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Total amount card
          TotalAmountCard(
            title: 'Total Due',
            amount: provider.totalAmountDue,
            subtitle: '${provider.upcomingPayments.length + provider.overduePayments.length} payments',
            icon: Icons.account_balance_wallet,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          // Stats row
          StatsRow(
            upcomingCount: provider.upcomingPayments.length,
            overdueCount: provider.overduePayments.length,
            paidCount: provider.paidPayments.length,
            onStatTap: (type) {
              switch (type) {
                case 'upcoming':
                  _onFilterByStatus(PaymentStatus.upcoming);
                  break;
                case 'overdue':
                  _onFilterByStatus(PaymentStatus.overdue);
                  break;
                case 'paid':
                  _onFilterByStatus(PaymentStatus.paid);
                  break;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: 'All',
              isSelected: _filterStatus == null,
              onTap: () => _onFilterByStatus(null),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Overdue',
              isSelected: _filterStatus == PaymentStatus.overdue,
              color: AppTheme.overdueColor,
              onTap: () => _onFilterByStatus(PaymentStatus.overdue),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Upcoming',
              isSelected: _filterStatus == PaymentStatus.upcoming,
              color: AppTheme.upcomingColor,
              onTap: () => _onFilterByStatus(PaymentStatus.upcoming),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Paid',
              isSelected: _filterStatus == PaymentStatus.paid,
              color: AppTheme.paidColor,
              onTap: () => _onFilterByStatus(PaymentStatus.paid),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    Color? color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.2)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: chipColor, width: 2) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? chipColor : theme.textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildListHeader(ThemeData theme, PaymentProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _getListTitle(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (provider.filteredPayments.isNotEmpty)
            Text(
              '${provider.filteredPayments.length} payments',
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(ThemeData theme) {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onNavItemSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month),
          label: 'Calendar',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }

  String _getListTitle() {
    switch (_filterStatus) {
      case PaymentStatus.overdue:
        return 'Overdue Payments';
      case PaymentStatus.upcoming:
        return 'Upcoming Payments';
      case PaymentStatus.paid:
        return 'Paid Payments';
      default:
        return 'All Payments';
    }
  }

  String _getEmptyMessage() {
    switch (_filterStatus) {
      case PaymentStatus.overdue:
        return 'No overdue payments! 🎉';
      case PaymentStatus.upcoming:
        return 'No upcoming payments';
      case PaymentStatus.paid:
        return 'No paid payments yet';
      default:
        return 'No payments found';
    }
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '💳',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessage(),
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppTheme.grey500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add a payment',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.grey400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(String title) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment'),
        content: Text('Are you sure you want to delete "$title"?'),
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
