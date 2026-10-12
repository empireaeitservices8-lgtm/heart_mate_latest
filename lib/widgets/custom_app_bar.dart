import 'package:flutter/material.dart';
import '../utils/app_palette.dart';

PreferredSizeWidget buildAppBar({
  required String title,
  bool showBackButton = true,
  VoidCallback? onBackPressed,
  List<Widget>? actions,
  bool isGradientTitle = false,
  Color? backgroundColor,
}) {
  return CustomAppBar(
    title: title,
    showBackButton: showBackButton,
    onBackPressed: onBackPressed,
    actions: actions,
    isGradientTitle: isGradientTitle,
    backgroundColor: backgroundColor,
  );
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool isGradientTitle;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.isGradientTitle = false,
    this.bottom,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget titleWidget = Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );

    if (isGradientTitle) {
      titleWidget = ShaderMask(
        shaderCallback: (bounds) => AppPalette.primaryGradient.createShader(bounds),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    return AppBar(
      title: titleWidget,
      centerTitle: true,
      backgroundColor: backgroundColor ?? AppPalette.backgroundLight,
      elevation: 0,
      leading: showBackButton && Navigator.of(context).canPop()
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: AppPalette.textPrimaryLight,
              ),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}
