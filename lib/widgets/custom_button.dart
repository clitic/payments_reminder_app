import 'package:flutter/material.dart';

/// Custom elevated button widget
/// Provides consistent styling across the app
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isFullWidth;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final EdgeInsets? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isFullWidth = true,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final buttonWidget = isOutlined
        ? _buildOutlinedButton(theme)
        : _buildFilledButton(theme);

    if (isFullWidth || width != null) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height ?? 52,
        child: buttonWidget,
      );
    }

    return buttonWidget;
  }

  Widget _buildFilledButton(ThemeData theme) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _buildButtonContent(theme),
    );
  }

  Widget _buildOutlinedButton(ThemeData theme) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor ?? theme.colorScheme.primary,
        side: BorderSide(
          color: foregroundColor ?? theme.colorScheme.primary,
        ),
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _buildButtonContent(theme),
    );
  }

  Widget _buildButtonContent(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            isOutlined
                ? theme.colorScheme.primary
                : theme.colorScheme.onPrimary,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Text button with icon
class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final bool isLoading;

  const CustomTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 6),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}

/// Floating action button with extended option
class CustomFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? label;
  final bool isExtended;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomFAB({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
    this.label,
    this.isExtended = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isExtended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        icon: Icon(icon),
        label: Text(label!),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      child: Icon(icon),
    );
  }
}

/// Icon button with tooltip
class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final double size;
  final Color? backgroundColor;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
    this.size = 24,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: size,
      color: color,
      style: backgroundColor != null
          ? IconButton.styleFrom(
              backgroundColor: backgroundColor,
            )
          : null,
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
