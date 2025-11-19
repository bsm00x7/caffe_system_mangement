import 'package:flutter/material.dart';

class CustomErrorWidgetNew {
  static Future<void> showError(
      BuildContext context,
      String message, {
        String? actionText,
        VoidCallback? onAction,
        Duration duration = const Duration(seconds: 4),
        IconData? icon,
        Color? backgroundColor,
      }) async {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon ?? Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 6,
        action: actionText != null && onAction != null
            ? SnackBarAction(
          label: actionText,
          textColor: Colors.white,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            onAction();
          },
        )
            : null,
      ),
    );
  }

  static Future<void> showSuccess(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 3),
      }) async {
    await showError(
      context,
      message,
      duration: duration,
      icon: Icons.check_circle_outline,
      backgroundColor: Colors.green,
    );
  }

  static Future<void> showWarning(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 3),
      }) async {
    await showError(
      context,
      message,
      duration: duration,
      icon: Icons.warning_outlined,
      backgroundColor: Colors.orange,
    );
  }

  static Future<void> showInfo(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 3),
      }) async {
    await showError(
      context,
      message,
      duration: duration,
      icon: Icons.info_outline,
      backgroundColor: Colors.blue,
    );
  }

  /// Show error dialog for critical errors
  static Future<void> showErrorDialog(
      BuildContext context,
      String title,
      String message, {
        String? actionText,
        VoidCallback? onAction,
      }) async {
    if (!context.mounted) return;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 16)),
        actions: [
          if (actionText != null && onAction != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onAction();
              },
              child: Text(actionText),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}