import 'package:flutter/material.dart';
import '../utils/app_palette.dart';

class AppProgressWidget extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;
  final String? message;

  const AppProgressWidget({
    super.key,
    this.size = 36.0,
    this.strokeWidth = 3.0,
    this.color,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    Widget spinner = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? AppPalette.primaryRose),
      ),
    );

    if (message != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            spinner,
            const SizedBox(height: 14),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 13,
                color: AppPalette.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Center(child: spinner);
  }
}
