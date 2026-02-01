import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_theme.dart';
import '../../core/utils/date_helper.dart';
import '../../models/payment.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/status_badge.dart';
import 'add_edit_payment_screen.dart';

/// Payment detail screen
/// Shows full payment information with actions
class PaymentDetailScreen extends StatelessWidget {
  final Payment payment;

  const PaymentDetailScreen({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Details'),
        actions: [
          IconButton(
            onPressed: () => _navigateToEdit(context),
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
          ),
          IconButton(
            onPressed: () => _handleDelete(context),
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            _buildHeaderCard(context, theme, currencyFormat),
            const SizedBox(height: 24),
            // Details section
            _buildDetailsSection(context, theme),
            const SizedBox(height: 24),
            // Reminders section
            if (payment.reminderEnabled) _buildRemindersSection(context, theme),
            const SizedBox(height: 24),
            // Notes section
            if (payment.notes != null && payment.notes!.isNotEmpty)
              _buildNotesSection(theme),
            const SizedBox(height: 100), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: _buildActionButton(context),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    ThemeData theme,
    NumberFormat currencyFormat,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getStatusColor().withValues(alpha: 0.8),
            _getStatusColor(),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor().withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      payment.category.icon,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      payment.category.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: payment.status, large: true),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            payment.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(payment.amount),
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text(
                DateHelper.formatFullDate(payment.dueDate),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (payment.status != PaymentStatus.paid) ...[
            const SizedBox(height: 8),
            Text(
              DateHelper.getDaysRemainingString(payment.dueDate),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            theme,
            Icons.repeat,
            'Frequency',
            payment.frequency.displayName,
          ),
          const Divider(height: 32),
          _buildDetailRow(
            theme,
            Icons.schedule,
            'Due Time',
            DateHelper.formatTimeOnly(payment.dueDate),
          ),
          const Divider(height: 32),
          _buildDetailRow(
            theme,
            Icons.access_time,
            'Created',
            DateHelper.formatRelativeDate(payment.createdAt),
          ),
          if (payment.updatedAt != payment.createdAt) ...[
            const Divider(height: 32),
            _buildDetailRow(
              theme,
              Icons.update,
              'Last Updated',
              DateHelper.formatRelativeDate(payment.updatedAt),
            ),
          ],
          const Divider(height: 32),
          _buildDetailRow(
            theme,
            Icons.sync,
            'Sync Status',
            payment.isSynced ? 'Synced' : 'Pending sync',
            valueColor: payment.isSynced ? AppTheme.paidColor : AppTheme.upcomingColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRemindersSection(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Reminders',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.paidLightColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Enabled',
                  style: TextStyle(
                    color: AppTheme.paidDarkColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: payment.reminderTypes.map((type) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_active,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      type.displayName,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              payment.notes!,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final paymentProvider = context.read<PaymentProvider>();

    if (payment.status == PaymentStatus.paid) {
      return FloatingActionButton.extended(
        onPressed: () async {
          await paymentProvider.markAsUnpaid(payment.id);
          if (context.mounted) {
            Navigator.pop(context);
          }
        },
        backgroundColor: AppTheme.grey500,
        icon: const Icon(Icons.undo),
        label: const Text('Mark Unpaid'),
      );
    }

    return FloatingActionButton.extended(
      onPressed: () async {
        await paymentProvider.markAsPaid(payment.id);
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
      backgroundColor: AppTheme.paidColor,
      icon: const Icon(Icons.check_circle),
      label: const Text('Mark as Paid'),
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditPaymentScreen(payment: payment),
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment'),
        content: Text('Are you sure you want to delete "${payment.title}"?'),
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

    if (confirmed == true && context.mounted) {
      await context.read<PaymentProvider>().deletePayment(payment.id);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  Color _getStatusColor() {
    switch (payment.status) {
      case PaymentStatus.paid:
        return AppTheme.paidColor;
      case PaymentStatus.upcoming:
        return AppTheme.primaryColor;
      case PaymentStatus.overdue:
        return AppTheme.overdueColor;
    }
  }
}
