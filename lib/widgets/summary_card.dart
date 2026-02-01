import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_theme.dart';

/// Summary card for dashboard statistics
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isCompact;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isCompact ? 12 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.15),
                color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: isCompact ? _buildCompactLayout(theme) : _buildFullLayout(theme),
        ),
      ),
    );
  }

  Widget _buildCompactLayout(ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.grey500,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFullLayout(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.grey400,
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppTheme.grey500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.grey500,
            ),
          ),
        ],
      ],
    );
  }
}

/// Amount summary card with currency formatting
class AmountSummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;
  final String currencySymbol;

  const AmountSummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
    this.currencySymbol = '₹',
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: 0,
    );

    return SummaryCard(
      title: title,
      value: formatter.format(amount),
      icon: icon,
      color: color,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}

/// Count summary card for payment counts
class CountSummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isCompact;

  const CountSummaryCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      title: title,
      value: count.toString(),
      icon: icon,
      color: color,
      subtitle: subtitle,
      onTap: onTap,
      isCompact: isCompact,
    );
  }
}

/// Stats row with multiple summary cards
class StatsRow extends StatelessWidget {
  final int upcomingCount;
  final int overdueCount;
  final int paidCount;
  final Function(String)? onStatTap;

  const StatsRow({
    super.key,
    required this.upcomingCount,
    required this.overdueCount,
    required this.paidCount,
    this.onStatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CountSummaryCard(
            title: 'Upcoming',
            count: upcomingCount,
            icon: Icons.schedule,
            color: AppTheme.upcomingColor,
            isCompact: true,
            onTap: onStatTap != null ? () => onStatTap!('upcoming') : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CountSummaryCard(
            title: 'Overdue',
            count: overdueCount,
            icon: Icons.warning_amber,
            color: AppTheme.overdueColor,
            isCompact: true,
            onTap: onStatTap != null ? () => onStatTap!('overdue') : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CountSummaryCard(
            title: 'Paid',
            count: paidCount,
            icon: Icons.check_circle,
            color: AppTheme.paidColor,
            isCompact: true,
            onTap: onStatTap != null ? () => onStatTap!('paid') : null,
          ),
        ),
      ],
    );
  }
}

/// Large stat card for total amounts
class TotalAmountCard extends StatelessWidget {
  final String title;
  final double amount;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final String currencySymbol;

  const TotalAmountCard({
    super.key,
    required this.title,
    required this.amount,
    this.subtitle,
    this.icon = Icons.account_balance_wallet,
    this.color = AppTheme.primaryColor,
    this.currencySymbol = '₹',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: 2,
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              color.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const Spacer(),
                if (subtitle != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      subtitle!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatter.format(amount),
              style: theme.textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
