import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../models/leaderboard_result.dart';

/// Port of iOS LeaderBoardCollectionViewCell — stat card with colored background.
/// Shows a label (e.g. "Members") and a value (e.g. "143").
class LeaderboardCollectionCell extends StatelessWidget {
  const LeaderboardCollectionCell({
    super.key,
    required this.stat,
    required this.index,
  });

  final LeaderBoardStat stat;
  final int index;

  /// Colors matching iOS hex values per index position.
  static const List<Color> _cellColors = [
    Color(0xFF29B49B), // Members — teal
    Color(0xFFFA5951), // TRF — red
    Color(0xFF00AEEF), // Projects — blue
    Color(0xFF00AEEF), // Cost
    Color(0xFF00AEEF), // Man Hours
    Color(0xFF00AEEF), // Beneficiaries
    Color(0xFF00AEEF), // Rotarians Involved
    Color(0xFF00AEEF), // Rotaractors Involved
  ];

  @override
  Widget build(BuildContext context) {
    final color = index < _cellColors.length
        ? _cellColors[index]
        : const Color(0xFF00AEEF);

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            stat.value,
            style: AppTextStyles.heading6.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            stat.label,
            style: AppTextStyles.captionSmall.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
