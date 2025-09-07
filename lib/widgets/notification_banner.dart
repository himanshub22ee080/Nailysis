import 'package:flutter/material.dart';

enum NotificationType {
  info,
  warning,
  error,
  success,
}

class NotificationBanner extends StatelessWidget {
  final NotificationType type;
  final String title;
  final String message;
  final VoidCallback? onDismiss;

  const NotificationBanner({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColorsForType(type);
    final icon = _getIconForType(type);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: colors.iconColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.titleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: colors.messageColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close,
                color: colors.iconColor,
                size: 20,
              ),
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              padding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }

  NotificationColors _getColorsForType(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return NotificationColors(
          backgroundColor: Colors.blue.withOpacity(0.1),
          borderColor: Colors.blue.withOpacity(0.3),
          iconColor: Colors.blue,
          titleColor: Colors.blue[800]!,
          messageColor: Colors.blue[700]!,
        );
      case NotificationType.warning:
        return NotificationColors(
          backgroundColor: Colors.orange.withOpacity(0.1),
          borderColor: Colors.orange.withOpacity(0.3),
          iconColor: Colors.orange,
          titleColor: Colors.orange[800]!,
          messageColor: Colors.orange[700]!,
        );
      case NotificationType.error:
        return NotificationColors(
          backgroundColor: Colors.red.withOpacity(0.1),
          borderColor: Colors.red.withOpacity(0.3),
          iconColor: Colors.red,
          titleColor: Colors.red[800]!,
          messageColor: Colors.red[700]!,
        );
      case NotificationType.success:
        return NotificationColors(
          backgroundColor: Colors.green.withOpacity(0.1),
          borderColor: Colors.green.withOpacity(0.3),
          iconColor: Colors.green,
          titleColor: Colors.green[800]!,
          messageColor: Colors.green[700]!,
        );
    }
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return Icons.info_outline;
      case NotificationType.warning:
        return Icons.warning_amber_outlined;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.success:
        return Icons.check_circle_outline;
    }
  }
}

class NotificationColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color titleColor;
  final Color messageColor;

  NotificationColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.titleColor,
    required this.messageColor,
  });
}