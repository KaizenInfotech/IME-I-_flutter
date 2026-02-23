import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Port of iOS progressView + progressLabel — download progress overlay.
/// Shows a centered card with circular progress and percentage.
class DownloadProgressWidget extends StatelessWidget {
  const DownloadProgressWidget({
    super.key,
    required this.progress,
    this.message = 'Downloading...',
  });

  final double progress;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: progress > 0 ? progress : null,
                    strokeWidth: 4,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.primary),
                    backgroundColor: AppColors.backgroundGray,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: AppTextStyles.body2,
                  textAlign: TextAlign.center,
                ),
                if (progress > 0) ...[
                  const SizedBox(height: 8),
                  // iOS: progressLabel shows percentage
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: AppTextStyles.body3.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.backgroundGray,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
