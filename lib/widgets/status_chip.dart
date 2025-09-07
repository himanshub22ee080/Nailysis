import 'package:flutter/material.dart';
import 'package:Nailysis/theme/app_theme.dart';

enum StatusType {
  severe,
  moderate,
  mild,
  normal,
  synced,
  offline,
}

enum StatusSize {
  small,
  medium,
  large,
}

class StatusChip extends StatelessWidget {
  final StatusType status;
  final StatusSize size;
  final String text;

  const StatusChip({
    super.key,
    required this.status,
    this.size = StatusSize.medium,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColorsForStatus(status);
    final textSize = _getTextSizeForSize(size);
    final padding = _getPaddingForSize(size);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.borderColor,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: colors.textColor,
          fontSize: textSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  StatusColors _getColorsForStatus(StatusType status) {
    switch (status) {
      case StatusType.severe:
        return StatusColors(
          backgroundColor: AppTheme.severeTriage.withOpacity(0.1),
          borderColor: AppTheme.severeTriage.withOpacity(0.3),
          textColor: AppTheme.severeTriage,
        );
      case StatusType.moderate:
        return StatusColors(
          backgroundColor: AppTheme.moderateTriage.withOpacity(0.1),
          borderColor: AppTheme.moderateTriage.withOpacity(0.3),
          textColor: AppTheme.moderateTriage,
        );
      case StatusType.mild:
        return StatusColors(
          backgroundColor: AppTheme.mildTriage.withOpacity(0.1),
          borderColor: AppTheme.mildTriage.withOpacity(0.3),
          textColor: AppTheme.mildTriage,
        );
      case StatusType.normal:
        return StatusColors(
          backgroundColor: AppTheme.normalTriage.withOpacity(0.1),
          borderColor: AppTheme.normalTriage.withOpacity(0.3),
          textColor: AppTheme.normalTriage,
        );
      case StatusType.synced:
        return StatusColors(
          backgroundColor: Colors.green.withOpacity(0.1),
          borderColor: Colors.green.withOpacity(0.3),
          textColor: Colors.green,
        );
      case StatusType.offline:
        return StatusColors(
          backgroundColor: Colors.grey.withOpacity(0.1),
          borderColor: Colors.grey.withOpacity(0.3),
          textColor: Colors.grey,
        );
    }
  }

  double _getTextSizeForSize(StatusSize size) {
    switch (size) {
      case StatusSize.small:
        return 12;
      case StatusSize.medium:
        return 14;
      case StatusSize.large:
        return 16;
    }
  }

  EdgeInsets _getPaddingForSize(StatusSize size) {
    switch (size) {
      case StatusSize.small:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case StatusSize.medium:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case StatusSize.large:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    }
  }
}

class StatusColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  StatusColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });
}