import 'package:flutter/material.dart';
import '../utils/app_palette.dart';

enum AppButtonType {
  primary,
  secondary,
  outlined,
}

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double height;
  final double? width;
  final double borderRadius;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.height = 52.0,
    this.width,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: Colors.white,
            ),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: 20, color: _getTextColor(context)),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              color: _getTextColor(context),
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );

    if (type == AppButtonType.outlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: isDisabled ? Colors.grey.shade300 : AppPalette.primaryRose,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: content,
        ),
      );
    }

    // Gradient container for primary
    final isPrimary = type == AppButtonType.primary;
    final gradient = isPrimary && !isDisabled ? AppPalette.primaryGradient : null;
    final bgColor = isPrimary
        ? (isDisabled ? Colors.grey.shade300 : null)
        : (isDisabled ? Colors.grey.shade200 : AppPalette.backgroundLightAlt);

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isPrimary && !isDisabled
            ? [
                BoxShadow(
                  color: AppPalette.primaryRose.withOpacity(0.32),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: content,
      ),
    );
  }

  Color _getTextColor(BuildContext context) {
    if (onPressed == null) return Colors.grey.shade500;
    if (type == AppButtonType.primary) return Colors.white;
    if (type == AppButtonType.outlined) return AppPalette.primaryRose;
    return AppPalette.textPrimaryLight;
  }
}
