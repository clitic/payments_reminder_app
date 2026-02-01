import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../models/payment.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';

/// Screen for adding or editing a payment
class AddEditPaymentScreen extends StatefulWidget {
  final Payment? payment;

  const AddEditPaymentScreen({super.key, this.payment});

  bool get isEditing => payment != null;

  @override
  State<AddEditPaymentScreen> createState() => _AddEditPaymentScreenState();
}

class _AddEditPaymentScreenState extends State<AddEditPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  late PaymentCategory _selectedCategory;
  late PaymentFrequency _selectedFrequency;
  late DateTime _selectedDueDate;
  late TimeOfDay _selectedDueTime;
  late bool _reminderEnabled;
  late List<ReminderType> _selectedReminderTypes;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.isEditing) {
      // Editing existing payment
      final payment = widget.payment!;
      _titleController.text = payment.title;
      _amountController.text = payment.amount.toStringAsFixed(2);
      _notesController.text = payment.notes ?? '';
      _selectedCategory = payment.category;
      _selectedFrequency = payment.frequency;
      _selectedDueDate = payment.dueDate;
      _selectedDueTime = TimeOfDay.fromDateTime(payment.dueDate);
      _reminderEnabled = payment.reminderEnabled;
      _selectedReminderTypes = List.from(payment.reminderTypes);
    } else {
      // New payment - use defaults
      final settingsProvider = context.read<SettingsProvider>();
      _selectedCategory = PaymentCategory.other;
      _selectedFrequency = PaymentFrequency.oneTime;
      _selectedDueDate = DateTime.now().add(const Duration(days: 1));
      _selectedDueTime = const TimeOfDay(hour: 12, minute: 0);
      _reminderEnabled = true;
      _selectedReminderTypes = List.from(settingsProvider.defaultReminderTypes);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedDueTime,
    );

    if (picked != null) {
      setState(() {
        _selectedDueTime = picked;
      });
    }
  }

  DateTime _getCombinedDateTime() {
    return DateTime(
      _selectedDueDate.year,
      _selectedDueDate.month,
      _selectedDueDate.day,
      _selectedDueTime.hour,
      _selectedDueTime.minute,
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final paymentProvider = context.read<PaymentProvider>();

      final payment = Payment(
        id: widget.isEditing ? widget.payment!.id : const Uuid().v4(),
        userId: authProvider.userId,
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        dueDate: _getCombinedDateTime(),
        category: _selectedCategory,
        frequency: _selectedFrequency,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        status: widget.isEditing ? widget.payment!.status : PaymentStatus.upcoming,
        reminderEnabled: _reminderEnabled,
        reminderTypes: _selectedReminderTypes,
        createdAt: widget.isEditing ? widget.payment!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      bool success;
      if (widget.isEditing) {
        success = await paymentProvider.updatePayment(payment);
      } else {
        success = await paymentProvider.addPayment(payment);
      }

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? AppStrings.paymentUpdated
                  : AppStrings.paymentAdded,
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(paymentProvider.errorMessage ?? AppStrings.errorGeneric),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.errorGeneric),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LoadingOverlay(
      isLoading: _isSaving,
      message: widget.isEditing ? 'Updating payment...' : 'Adding payment...',
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isEditing ? AppStrings.editPayment : AppStrings.addPayment,
          ),
          actions: [
            if (widget.isEditing)
              TextButton(
                onPressed: _handleSave,
                child: const Text('Save'),
              )
            else
              TextButton(
                onPressed: _handleSave,
                child: const Text('Add'),
              ),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
              // Title field
              CustomTextField(
                controller: _titleController,
                label: AppStrings.paymentTitle,
                hint: 'e.g., Rent, Electricity Bill',
                prefixIcon: Icons.title,
                validator: Validators.validatePaymentTitle,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Amount field
              AmountTextField(
                controller: _amountController,
                validator: Validators.validateAmount,
              ),
              const SizedBox(height: 24),

              // Category section
              _buildSectionHeader(theme, 'Category'),
              const SizedBox(height: 12),
              CategorySelector(
                selectedCategory: _selectedCategory,
                onCategorySelected: (category) {
                  if (category != null) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  }
                },
                showAllOption: false,
              ),
              const SizedBox(height: 24),

              // Due date and time
              _buildSectionHeader(theme, 'Due Date'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildDatePicker(theme),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimePicker(theme),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Frequency
              _buildSectionHeader(theme, 'Frequency'),
              const SizedBox(height: 12),
              _buildFrequencySelector(theme),
              const SizedBox(height: 24),

              // Reminders section
              _buildRemindersSection(theme),
              const SizedBox(height: 24),

              // Notes field
              NotesTextField(
                controller: _notesController,
                validator: Validators.validateNotes,
              ),
              const SizedBox(height: 32),

              // Save button
              CustomButton(
                text: widget.isEditing ? 'Update Payment' : 'Add Payment',
                onPressed: _handleSave,
                isLoading: _isSaving,
                icon: widget.isEditing ? Icons.check : Icons.add,
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildDatePicker(ThemeData theme) {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    _formatDate(_selectedDueDate),
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(ThemeData theme) {
    return InkWell(
      onTap: _selectTime,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Time',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    _selectedDueTime.format(context),
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencySelector(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PaymentFrequency.values.map((frequency) {
        final isSelected = _selectedFrequency == frequency;
        return ChoiceChip(
          label: Text(
            frequency.displayName,
            style: TextStyle(
              color: isSelected 
                  ? theme.colorScheme.onPrimary 
                  : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          selected: isSelected,
          selectedColor: theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          checkmarkColor: theme.colorScheme.onPrimary,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedFrequency = frequency;
              });
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildRemindersSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader(theme, 'Reminders'),
            Switch(
              value: _reminderEnabled,
              onChanged: (value) {
                setState(() {
                  _reminderEnabled = value;
                });
              },
            ),
          ],
        ),
        if (_reminderEnabled) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ReminderType.values.map((type) {
              final isSelected = _selectedReminderTypes.contains(type);
              return FilterChip(
                label: Text(
                  type.displayName,
                  style: TextStyle(
                    color: isSelected 
                        ? theme.colorScheme.onPrimary 
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                selected: isSelected,
                showCheckmark: false,
                selectedColor: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedReminderTypes.add(type);
                    } else {
                      _selectedReminderTypes.remove(type);
                    }
                  });
                },
                avatar: Icon(
                  _getReminderIcon(type),
                  size: 16,
                  color: isSelected 
                      ? theme.colorScheme.onPrimary 
                      : theme.colorScheme.onSurfaceVariant,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  IconData _getReminderIcon(ReminderType type) {
    switch (type) {
      case ReminderType.oneDayBefore:
        return Icons.calendar_today;
      case ReminderType.threeHoursBefore:
        return Icons.access_time;
      case ReminderType.onDueDate:
        return Icons.alarm;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
