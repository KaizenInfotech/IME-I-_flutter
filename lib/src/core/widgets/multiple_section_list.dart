import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'collapsible_section.dart';

/// Data model for a single section in MultipleSectionList.
/// Mirrors iOS Section struct (name, items, collapsed, imagePic).
class SectionData {
  const SectionData({
    required this.name,
    required this.items,
    this.descriptions,
    this.imagePics,
    this.initiallyExpanded = true,
  });

  final String name;
  final List<String> items;
  final List<String>? descriptions;
  final List<String>? imagePics;
  final bool initiallyExpanded;
}

/// Port of iOS MultipleSectionTableViewController — grouped list with
/// collapsible sections. Each section has a header (CollapsibleSection)
/// and a list of items that collapse/expand.
class MultipleSectionList extends StatelessWidget {
  const MultipleSectionList({
    super.key,
    required this.sections,
    this.onItemTap,
    this.showFirstSectionHeader = false,
    this.itemHeight = 100.0,
  });

  final List<SectionData> sections;
  final void Function(int section, int index)? onItemTap;

  /// iOS: section 0 has no header (height 0), other sections have 40pt header.
  final bool showFirstSectionHeader;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: sections.length,
      itemBuilder: (context, sectionIndex) {
        final section = sections[sectionIndex];

        // iOS: section 0 has no header
        if (sectionIndex == 0 && !showFirstSectionHeader) {
          return _buildSectionItems(section, sectionIndex);
        }

        return CollapsibleSection(
          title: section.name,
          initiallyExpanded: section.initiallyExpanded,
          child: _buildSectionItems(section, sectionIndex),
        );
      },
    );
  }

  Widget _buildSectionItems(SectionData section, int sectionIndex) {
    if (section.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: List.generate(section.items.length, (itemIndex) {
        final hasImage = section.imagePics != null &&
            itemIndex < section.imagePics!.length &&
            section.imagePics![itemIndex].isNotEmpty;

        return InkWell(
          onTap: onItemTap != null
              ? () => onItemTap!(sectionIndex, itemIndex)
              : null,
          child: Container(
            height: itemHeight,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                // iOS: imageUser — only shown for section 0 with images
                if (hasImage) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      section.imagePics![itemIndex],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 60,
                        height: 60,
                        color: AppColors.backgroundGray,
                        child: const Icon(Icons.image,
                            color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                // iOS: lblHeading / lblDescription
                Expanded(
                  child: Text(
                    section.items[itemIndex],
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: hasImage ? 14 : 13,
                      fontWeight: hasImage ? FontWeight.w500 : FontWeight.w400,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
