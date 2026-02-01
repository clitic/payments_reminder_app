import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_theme.dart';
import '../core/utils/date_helper.dart';
import '../models/payment.dart';
import 'category_chip.dart';
import 'status_badge.dart';

/// Reusable payment card widget
/// Displays payment information with color-coded status
class PaymentCard extends StatelessWidget {
  final Payment payment;
  final VoidCallback? onTap;
  final VoidCallback? onMarkPaid;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const PaymentCard({
    super.key,
    required this.payment,
    this.onTap,
    this.onMarkPaid,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConfig.radiusM),
        side: BorderSide(
          color: _getStatusBorderColor(),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConfig.radiusM),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConfig.radiusM),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getStatusBackgroundColor().withValues(alpha: 0.1),
                theme.cardColor,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Status badge and category
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge(status: payment.status),
                    CategoryChip(category: payment.category, compact: true),
                  ],
                ),
                const SizedBox(height: 12),

                // Title and amount
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Payment icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: payment.category.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        payment.category.icon,
                        color: payment.category.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title and due date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payment.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: payment.status == PaymentStatus.paid
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: _getDueDateColor(),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateHelper.getRelativeDateString(payment.dueDate),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: _getDueDateColor(),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (payment.frequency != PaymentFrequency.oneTime) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.repeat,
                                  size: 14,
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  payment.frequency.displayName,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Amount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyFormat.format(payment.amount),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getAmountColor(),
                          ),
                        ),
                        if (payment.status != PaymentStatus.paid)
                          Text(
                            DateHelper.getDaysRemainingString(payment.dueDate),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _getDueDateColor(),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                // Notes preview
                if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    payment.notes!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppTheme.grey500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Action buttons
                if (showActions) ...[
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onEdit != null)
                        TextButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Edit'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.grey600,
                          ),
                        ),
                      if (onDelete != null) ...[
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Delete'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.overdueColor,
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (onMarkPaid != null)
                        FilledButton.icon(
                          onPressed: onMarkPaid,
                          icon: Icon(
                            payment.status == PaymentStatus.paid
                                ? Icons.undo
                                : Icons.check_circle_outline,
                            size: 18,
                          ),
                          label: Text(
                            payment.status == PaymentStatus.paid
                                ? 'Undo'
                                : 'Mark Paid',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: payment.status == PaymentStatus.paid
                                ? AppTheme.grey500
                                : AppTheme.paidColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusBorderColor() {
    switch (payment.status) {
      case PaymentStatus.paid:
        return AppTheme.paidColor;
      case PaymentStatus.upcoming:
        return AppTheme.upcomingColor;
      case PaymentStatus.overdue:
        return AppTheme.overdueColor;
    }
  }

  Color _getStatusBackgroundColor() {
    switch (payment.status) {
      case PaymentStatus.paid:
        return AppTheme.paidLightColor;
      case PaymentStatus.upcoming:
        return AppTheme.upcomingLightColor;
      case PaymentStatus.overdue:
        return AppTheme.overdueLightColor;
    }
  }

  Color _getDueDateColor() {
    if (payment.status == PaymentStatus.paid) {
      return AppTheme.grey500;
    } else if (payment.status == PaymentStatus.overdue) {
      return AppTheme.overdueColor;
    } else if (payment.isDueToday) {
      return AppTheme.upcomingColor;
    }
    return AppTheme.grey600;
  }

  Color _getAmountColor() {
    switch (payment.status) {
      case PaymentStatus.paid:
        return AppTheme.paidDarkColor;
      case PaymentStatus.upcoming:
        return AppTheme.grey800;
      case PaymentStatus.overdue:
        return AppTheme.overdueDarkColor;
    }
  }
}
