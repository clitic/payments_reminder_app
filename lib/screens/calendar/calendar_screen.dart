import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_theme.dart';
import '../../models/payment.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/payment_card.dart';
import '../payments/add_edit_payment_screen.dart';
import '../payments/payment_detail_screen.dart';

/// Calendar view for payments
/// Shows payments organized by date with calendar navigation
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Payment>> _paymentsByDate = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadPayments();
  }

  void _loadPayments() {
    final paymentProvider = context.read<PaymentProvider>();
    _paymentsByDate = paymentProvider.getPaymentsByDate();
  }

  List<Payment> _getPaymentsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _paymentsByDate[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paymentProvider = context.watch<PaymentProvider>();

    // Update payments map when provider changes
    _paymentsByDate = paymentProvider.getPaymentsByDate();

    final selectedPayments = _selectedDay != null
        ? _getPaymentsForDay(_selectedDay!)
        : <Payment>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
            icon: const Icon(Icons.today),
            tooltip: 'Go to Today',
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar widget
          _buildCalendar(theme),
          const Divider(height: 1),
          // Selected day payments
          Expanded(
            child: _buildDayPayments(theme, selectedPayments),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddPayment(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendar(ThemeData theme) {
    return TableCalendar<Payment>(
      firstDay: DateTime.now().subtract(const Duration(days: 365)),
      lastDay: DateTime.now().add(const Duration(days: 365 * 2)),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      eventLoader: _getPaymentsForDay,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        // Today decoration
        todayDecoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
        // Selected day decoration
        selectedDecoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        // Marker decoration
        markerDecoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 3,
        markerSize: 6,
        markerMargin: const EdgeInsets.symmetric(horizontal: 1),
        // Weekend style
        weekendTextStyle: TextStyle(
          color: theme.colorScheme.error.withValues(alpha: 0.7),
        ),
        // Outside days
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        formatButtonDecoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        formatButtonTextStyle: theme.textTheme.bodyMedium!,
        titleTextStyle: theme.textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isEmpty) return null;

          return Positioned(
            bottom: 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: events.take(3).map((payment) {
                return Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: _getPaymentStatusColor(payment.status),
                    shape: BoxShape.circle,
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
    );
  }

  Widget _buildDayPayments(ThemeData theme, List<Payment> payments) {
    if (_selectedDay == null) {
      return const Center(
        child: Text('Select a day to view payments'),
      );
    }

    final dateLabel = _getDateLabel(_selectedDay!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${payments.length} payment${payments.length != 1 ? 's' : ''}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              if (payments.isNotEmpty)
                _buildStatsChips(theme, payments),
            ],
          ),
        ),
        Expanded(
          child: payments.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    final payment = payments[index];
                    return PaymentCard(
                      payment: payment,
                      onTap: () => _navigateToDetail(payment),
                      onMarkPaid: () => _togglePaidStatus(payment),
                      showActions: false,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No payments on this day',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _navigateToAddPayment,
            icon: const Icon(Icons.add),
            label: const Text('Add Payment'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsChips(ThemeData theme, List<Payment> payments) {
    final overdueCount = payments.where((p) => p.status == PaymentStatus.overdue).length;
    final upcomingCount = payments.where((p) => p.status == PaymentStatus.upcoming).length;
    final paidCount = payments.where((p) => p.status == PaymentStatus.paid).length;

    return Row(
      children: [
        if (overdueCount > 0)
          _buildMiniChip(overdueCount.toString(), AppTheme.overdueColor),
        if (upcomingCount > 0)
          _buildMiniChip(upcomingCount.toString(), AppTheme.upcomingColor),
        if (paidCount > 0)
          _buildMiniChip(paidCount.toString(), AppTheme.paidColor),
      ],
    );
  }

  Widget _buildMiniChip(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getDateLabel(DateTime date) {
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

    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return AppTheme.paidColor;
      case PaymentStatus.upcoming:
        return AppTheme.upcomingColor;
      case PaymentStatus.overdue:
        return AppTheme.overdueColor;
    }
  }

  void _navigateToAddPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditPaymentScreen()),
    ).then((_) {
      _loadPayments();
      setState(() {});
    });
  }

  void _navigateToDetail(Payment payment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentDetailScreen(payment: payment),
      ),
    ).then((_) {
      _loadPayments();
      setState(() {});
    });
  }

  Future<void> _togglePaidStatus(Payment payment) async {
    final paymentProvider = context.read<PaymentProvider>();
    await paymentProvider.togglePaidStatus(payment.id);
    _loadPayments();
    setState(() {});
  }
}
