import 'package:flutter/material.dart';
import '../utils/app_palette.dart';

typedef CustomCheckBoxWidget = CustomCheckbox;

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: value ? AppPalette.primaryGradient : null,
                color: value ? null : AppPalette.backgroundLightAlt,
                border: Border.all(
                  color: value ? Colors.transparent : AppPalette.borderLight,
                  width: 1.5,
                ),
              ),
              child: value
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            if (label != null) ...[
              const SizedBox(width: 10),
              Text(
                label!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppPalette.textPrimaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
