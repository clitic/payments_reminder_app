import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom text field widget
/// Provides consistent styling and validation display
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,
      autofocus: autofocus,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        helperText: helperText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        counterText: maxLength != null ? null : '',
      ),
    );
  }
}

/// Email text field with validation
class EmailTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? errorText;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;

  const EmailTextField({
    super.key,
    this.controller,
    this.errorText,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: 'Email',
      hint: 'Enter your email',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction ?? TextInputAction.next,
      errorText: errorText,
      onChanged: onChanged,
      validator: validator,
      enabled: enabled,
      onSubmitted: onSubmitted,
      focusNode: focusNode,
    );
  }
}

/// Password text field with visibility toggle
class PasswordTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? errorText;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;

  const PasswordTextField({
    super.key,
    this.controller,
    this.label = 'Password',
    this.errorText,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      label: widget.label,
      hint: 'Enter your password',
      prefixIcon: Icons.lock_outlined,
      obscureText: _obscureText,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction ?? TextInputAction.done,
      errorText: widget.errorText,
      onChanged: widget.onChanged,
      validator: widget.validator,
      enabled: widget.enabled,
      onSubmitted: widget.onSubmitted,
      focusNode: widget.focusNode,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
    );
  }
}

/// Amount text field with currency formatting
class AmountTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? errorText;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final String currencySymbol;
  final FocusNode? focusNode;

  const AmountTextField({
    super.key,
    this.controller,
    this.errorText,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.currencySymbol = '₹',
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: 'Amount',
      hint: 'Enter amount',
      prefixIcon: Icons.currency_rupee,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      errorText: errorText,
      onChanged: onChanged,
      validator: validator,
      enabled: enabled,
      focusNode: focusNode,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
    );
  }
}

/// Notes/multiline text field
class NotesTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? errorText;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final FocusNode? focusNode;

  const NotesTextField({
    super.key,
    this.controller,
    this.errorText,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.maxLines = 3,
    this.maxLength = 500,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: 'Notes (Optional)',
      hint: 'Add any additional notes',
      prefixIcon: Icons.notes_outlined,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      maxLines: maxLines,
      maxLength: maxLength,
      errorText: errorText,
      onChanged: onChanged,
      validator: validator,
      enabled: enabled,
      focusNode: focusNode,
      textCapitalization: TextCapitalization.sentences,
    );
  }
}

/// Search text field
class SearchTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  final FocusNode? focusNode;

  const SearchTextField({
    super.key,
    this.controller,
    this.hint = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasText = controller?.text.isNotEmpty ?? false;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: hasText
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller?.clear();
                  onClear?.call();
                  onChanged?.call('');
                },
              )
            : null,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
