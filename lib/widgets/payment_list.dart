import 'package:flutter/material.dart';
import '../core/constants/app_theme.dart';
import '../models/payment.dart';
import 'payment_card.dart';

/// Reusable payment list widget
/// Displays a list of payments with empty and loading states
class PaymentList extends StatelessWidget {
  final List<Payment> payments;
  final bool isLoading;
  final String emptyMessage;
  final String emptyIcon;
  final Function(Payment)? onPaymentTap;
  final Function(Payment)? onMarkPaid;
  final Function(Payment)? onEdit;
  final Function(Payment)? onDelete;
  final bool showActions;
  final Future<void> Function()? onRefresh;
  final ScrollController? scrollController;
  final EdgeInsets? padding;

  const PaymentList({
    super.key,
    required this.payments,
    this.isLoading = false,
    this.emptyMessage = 'No payments found',
    this.emptyIcon = '💳',
    this.onPaymentTap,
    this.onMarkPaid,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
    this.onRefresh,
    this.scrollController,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _LoadingState();
    }

    if (payments.isEmpty) {
      return _EmptyState(
        message: emptyMessage,
        icon: emptyIcon,
      );
    }

    final listView = ListView.builder(
      controller: scrollController,
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return PaymentCard(
          payment: payment,
          onTap: onPaymentTap != null ? () => onPaymentTap!(payment) : null,
          onMarkPaid: onMarkPaid != null ? () => onMarkPaid!(payment) : null,
          onEdit: onEdit != null ? () => onEdit!(payment) : null,
          onDelete: onDelete != null ? () => onDelete!(payment) : null,
          showActions: showActions,
        );
      },
    );

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: listView,
      );
    }

    return listView;
  }
}

/// Loading state widget
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 5,
      itemBuilder: (context, index) {
        return const _PaymentCardSkeleton();
      },
    );
  }
}

/// Skeleton loader for payment card
class _PaymentCardSkeleton extends StatelessWidget {
  const _PaymentCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildShimmer(context, width: 80, height: 24),
                _buildShimmer(context, width: 60, height: 24),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildShimmer(context, width: 48, height: 48, radius: 12),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmer(context, width: double.infinity, height: 18),
                      const SizedBox(height: 8),
                      _buildShimmer(context, width: 150, height: 14),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildShimmer(context, width: 80, height: 24),
                    const SizedBox(height: 4),
                    _buildShimmer(context, width: 60, height: 12),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer(
    BuildContext context, {
    required double width,
    required double height,
    double radius = 4,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.grey200,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Empty state widget
class _EmptyState extends StatelessWidget {
  final String message;
  final String icon;

  const _EmptyState({
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              message,
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
}

/// Grouped payment list by date
class GroupedPaymentList extends StatelessWidget {
  final Map<DateTime, List<Payment>> groupedPayments;
  final bool isLoading;
  final String emptyMessage;
  final Function(Payment)? onPaymentTap;
  final Function(Payment)? onMarkPaid;
  final Future<void> Function()? onRefresh;

  const GroupedPaymentList({
    super.key,
    required this.groupedPayments,
    this.isLoading = false,
    this.emptyMessage = 'No payments found',
    this.onPaymentTap,
    this.onMarkPaid,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _LoadingState();
    }

    if (groupedPayments.isEmpty) {
      return _EmptyState(
        message: emptyMessage,
        icon: '📅',
      );
    }

    final sortedDates = groupedPayments.keys.toList()..sort();
    final theme = Theme.of(context);

    final listView = ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final payments = groupedPayments[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                _formatDateHeader(date),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.grey500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...payments.map(
              (payment) => PaymentCard(
                payment: payment,
                onTap: onPaymentTap != null ? () => onPaymentTap!(payment) : null,
                onMarkPaid: onMarkPaid != null ? () => onMarkPaid!(payment) : null,
                showActions: false,
              ),
            ),
          ],
        );
      },
    );

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: listView,
      );
    }

    return listView;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }

    // Format as "Monday, Jan 15"
    final weekday = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
    final month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1];
    return '$weekday, $month ${date.day}';
  }
}
