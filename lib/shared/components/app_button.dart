import 'package:flutter/material.dart';

enum AppButtonType { primary, secondary, outline, text }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    Widget child = isLoading
        ? SizedBox(
            height: _getIconSize(),
            width: _getIconSize(),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == AppButtonType.primary ? Colors.white : colorScheme.primary,
              ),
            ),
          )
        : Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: _getIconSize()),
                const SizedBox(width: 8),
              ],
              Text(text),
            ],
          );

    Widget button = switch (type) {
      AppButtonType.primary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            padding: _getPadding(),
            textStyle: _getTextStyle(context),
          ),
          child: child,
        ),
      AppButtonType.secondary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.secondary,
            foregroundColor: colorScheme.onSecondary,
            padding: _getPadding(),
            textStyle: _getTextStyle(context),
          ),
          child: child,
        ),
      AppButtonType.outline => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            padding: _getPadding(),
            textStyle: _getTextStyle(context),
          ),
          child: child,
        ),
      AppButtonType.text => TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            padding: _getPadding(),
            textStyle: _getTextStyle(context),
          ),
          child: child,
        ),
    };

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  EdgeInsets _getPadding() {
    return switch (size) {
      AppButtonSize.small => const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      AppButtonSize.medium => const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      AppButtonSize.large => const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    };
  }

  TextStyle _getTextStyle(BuildContext context) {
    return switch (size) {
      AppButtonSize.small => Theme.of(context).textTheme.labelMedium!,
      AppButtonSize.medium => Theme.of(context).textTheme.labelLarge!,
      AppButtonSize.large => Theme.of(context).textTheme.titleMedium!,
    };
  }

  double _getIconSize() {
    return switch (size) {
      AppButtonSize.small => 16,
      AppButtonSize.medium => 18,
      AppButtonSize.large => 20,
    };
  }
}