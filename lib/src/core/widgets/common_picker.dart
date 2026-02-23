import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Replaces iOS UIPickerView — bottom sheet picker / dropdown.
class CommonPicker extends StatelessWidget {
  const CommonPicker({
    super.key,
    required this.items,
    this.selectedValue,
    this.onChanged,
    this.hint,
    this.label,
    this.enabled = true,
  });

  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?>? onChanged;
  final String? hint;
  final String? label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(label!, style: AppTextStyles.label),
          ),
        DropdownButtonFormField<String>(
          initialValue: (selectedValue != null && items.contains(selectedValue))
              ? selectedValue
              : null,
          hint: hint != null
              ? Text(hint!, style: AppTextStyles.inputHint)
              : null,
          isExpanded: true,
          style: AppTextStyles.input,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.border),
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }

  /// Show a bottom sheet picker (iOS UIPickerView style).
  static Future<String?> showBottomSheet({
    required BuildContext context,
    required List<String> items,
    String? selectedValue,
    String? title,
  }) async {
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(title, style: AppTextStyles.heading6),
                ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item == selectedValue;
                    return ListTile(
                      title: Text(
                        item,
                        style: AppTextStyles.body2.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () => Navigator.of(context).pop(item),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
