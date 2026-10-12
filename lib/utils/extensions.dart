import 'package:flutter/material.dart';
import '../widgets/app_progress_widget.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  double get bottomPadding => MediaQuery.viewPaddingOf(this).bottom;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  void pop<T>([T? result]) => Navigator.of(this).pop(result);
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) =>
      Navigator.of(this).pushNamed(routeName, arguments: arguments);

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  bool get isValidEmail {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(this);
  }

  bool get isValidPhone {
    final regex = RegExp(r'^\+?[0-9]{10,14}$');
    return regex.hasMatch(this);
  }
}

extension WidgetExtensions on Widget {
  Widget withPadding(EdgeInsetsGeometry padding) => Padding(padding: padding, child: this);
  Widget centered() => Center(child: this);
  Widget expanded({int flex = 1}) => Expanded(flex: flex, child: this);

  /// Shows a centered progress indicator on top or replaces widget when loading
  Widget showProgressOnCenter({required bool isLoading, String? message}) {
    if (!isLoading) return this;
    return Stack(
      children: [
        this,
        Container(
          color: Colors.black.withOpacity(0.15),
          alignment: Alignment.center,
          child: AppProgressWidget(message: message),
        ),
      ],
    );
  }

  /// Replaces the widget with a fallback empty widget when the condition is met
  Widget orShowEmptyWidget({required bool isEmpty, Widget? emptyWidget}) {
    if (isEmpty) {
      return emptyWidget ??
          const Center(
            child: Text(
              'No items available',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          );
    }
    return this;
  }
}

extension ScrollControllerExtensions on ScrollController {
  void withLoadMore({required VoidCallback onLoadMore, double threshold = 200.0}) {
    addListener(() {
      if (position.pixels >= position.maxScrollExtent - threshold) {
        onLoadMore();
      }
    });
  }
}
