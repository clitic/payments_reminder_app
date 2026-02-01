import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

/// Category chip widget
/// Displays a payment category with icon and color
class CategoryChip extends StatelessWidget {
  final PaymentCategory category;
  final bool isSelected;
  final bool compact;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactChip(context);
    }

    return _buildFullChip(context);
  }

  Widget _buildCompactChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            category.icon,
            size: 14,
            color: category.color,
          ),
          const SizedBox(width: 4),
          Text(
            category.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: category.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullChip(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? category.color.withValues(alpha: 0.45)
              : category.color.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: category.color, width: 2)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 18,
              color: category.color,
            ),
            const SizedBox(width: 6),
            Text(
              category.displayName,
              style: theme.textTheme.labelMedium?.copyWith(
                color: category.color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Category selector widget
/// Horizontal list of category chips for selection
class CategorySelector extends StatelessWidget {
  final PaymentCategory? selectedCategory;
  final ValueChanged<PaymentCategory?> onCategorySelected;
  final bool showAllOption;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.showAllOption = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (showAllOption) ...[
            GestureDetector(
              onTap: () => onCategorySelected(null),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: selectedCategory == null
                      ? theme.colorScheme.primary.withValues(alpha: 0.4)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: selectedCategory == null
                      ? Border.all(color: theme.colorScheme.primary, width: 2)
                      : null,
                ),
                child: Text(
                  'All',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: selectedCategory == null
                        ? theme.colorScheme.primary
                        : theme.textTheme.bodyMedium?.color,
                    fontWeight: selectedCategory == null
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          ...PaymentCategory.values.map(
            (category) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CategoryChip(
                category: category,
                isSelected: selectedCategory == category,
                onTap: () => onCategorySelected(category),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Category dropdown widget
/// Dropdown for selecting a category
class CategoryDropdown extends StatelessWidget {
  final PaymentCategory? value;
  final ValueChanged<PaymentCategory?> onChanged;
  final String? hintText;
  final String? errorText;

  const CategoryDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.hintText = 'Select category',
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<PaymentCategory>(
      value: value,
      hint: Text(hintText!),
      isExpanded: true,
      decoration: InputDecoration(
        errorText: errorText,
        prefixIcon: value != null
            ? Icon(value!.icon, color: value!.color)
            : const Icon(Icons.category_outlined),
      ),
      items: PaymentCategory.values.map((category) {
        return DropdownMenuItem<PaymentCategory>(
          value: category,
          child: Row(
            children: [
              Icon(
                category.icon,
                size: 20,
                color: category.color,
              ),
              const SizedBox(width: 12),
              Text(category.displayName),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
