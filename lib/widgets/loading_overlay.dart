import 'package:flutter/material.dart';
import '../core/constants/app_theme.dart';

/// Loading overlay widget
/// Shows a loading indicator over content
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? overlayColor;
  final bool dismissible;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.overlayColor,
    this.dismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          AbsorbPointer(
            absorbing: true,
            child: Container(
              color: overlayColor ?? Colors.black.withValues(alpha: 0.4),
              child: Center(
                child: _LoadingIndicator(message: message),
              ),
            ),
          ),
      ],
    );
  }
}

/// Loading indicator with optional message
class _LoadingIndicator extends StatelessWidget {
  final String? message;

  const _LoadingIndicator({this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Full screen loading indicator
class FullScreenLoading extends StatelessWidget {
  final String? message;

  const FullScreenLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 24),
              Text(
                message!,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading effect for skeleton loaders
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.grey200,
                AppTheme.grey100,
                AppTheme.grey200,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Progress button that shows loading state
class ProgressButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? progress; // 0.0 to 1.0 for determinate progress

  const ProgressButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Stack(
        children: [
          // Progress background
          if (progress != null)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          // Button
          Positioned.fill(
            child: FilledButton(
              onPressed: isLoading ? null : onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: progress != null
                    ? Colors.transparent
                    : theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: progress != null
                            ? theme.colorScheme.primary
                            : null,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline loading indicator for small spaces
class InlineLoading extends StatelessWidget {
  final double size;
  final Color? color;

  const InlineLoading({
    super.key,
    this.size = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
