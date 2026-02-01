import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_theme.dart';

/// Status badge widget
/// Displays payment status with appropriate color
class StatusBadge extends StatelessWidget {
  final PaymentStatus status;
  final bool large;

  const StatusBadge({
    super.key,
    required this.status,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12 : 8,
        vertical: large ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(large ? 12 : 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            size: large ? 16 : 12,
            color: _getTextColor(),
          ),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: large ? 14 : 12,
              fontWeight: FontWeight.w600,
              color: _getTextColor(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case PaymentStatus.paid:
        return AppTheme.paidLightColor;
      case PaymentStatus.upcoming:
        return AppTheme.upcomingLightColor;
      case PaymentStatus.overdue:
        return AppTheme.overdueLightColor;
    }
  }

  Color _getTextColor() {
    switch (status) {
      case PaymentStatus.paid:
        return AppTheme.paidDarkColor;
      case PaymentStatus.upcoming:
        return AppTheme.upcomingDarkColor;
      case PaymentStatus.overdue:
        return AppTheme.overdueDarkColor;
    }
  }

  IconData _getIcon() {
    switch (status) {
      case PaymentStatus.paid:
        return Icons.check_circle;
      case PaymentStatus.upcoming:
        return Icons.schedule;
      case PaymentStatus.overdue:
        return Icons.warning;
    }
  }
}

/// Status filter chips widget
/// Horizontal list of status chips for filtering
class StatusFilterChips extends StatelessWidget {
  final PaymentStatus? selectedStatus;
  final ValueChanged<PaymentStatus?> onStatusSelected;

  const StatusFilterChips({
    super.key,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip(
            context,
            label: 'All',
            isSelected: selectedStatus == null,
            onTap: () => onStatusSelected(null),
          ),
          const SizedBox(width: 8),
          ...PaymentStatus.values.map(
            (status) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildStatusChip(
                context,
                status: status,
                isSelected: selectedStatus == status,
                onTap: () => onStatusSelected(status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.textTheme.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context, {
    required PaymentStatus status,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? _getBackgroundColor(status).withValues(alpha: 0.4)
              : _getBackgroundColor(status),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: _getBorderColor(status), width: 2)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIcon(status),
              size: 16,
              color: _getTextColor(status),
            ),
            const SizedBox(width: 6),
            Text(
              status.displayName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: _getTextColor(status),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return AppTheme.paidLightColor;
      case PaymentStatus.upcoming:
        return AppTheme.upcomingLightColor;
      case PaymentStatus.overdue:
        return AppTheme.overdueLightColor;
    }
  }

  Color _getTextColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return AppTheme.paidDarkColor;
      case PaymentStatus.upcoming:
        return AppTheme.upcomingDarkColor;
      case PaymentStatus.overdue:
        return AppTheme.overdueDarkColor;
    }
  }

  Color _getBorderColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return AppTheme.paidColor;
      case PaymentStatus.upcoming:
        return AppTheme.upcomingColor;
      case PaymentStatus.overdue:
        return AppTheme.overdueColor;
    }
  }

  IconData _getIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return Icons.check_circle;
      case PaymentStatus.upcoming:
        return Icons.schedule;
      case PaymentStatus.overdue:
        return Icons.warning;
    }
  }
}
