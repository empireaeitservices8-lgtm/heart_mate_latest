import 'package:flutter/material.dart';
import '../utils/app_palette.dart';

typedef AppRadioButtonWidget<T> = AppRadioButton<T>;

class AppRadioButton<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final String? label;

  const AppRadioButton({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
  });

  bool get isSelected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppPalette.primaryRose : AppPalette.borderLight,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppPalette.primaryGradient,
                        ),
                      ),
                    )
                  : null,
            ),
            if (label != null) ...[
              const SizedBox(width: 10),
              Text(
                label!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppPalette.textPrimaryLight : AppPalette.textSecondaryLight,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
