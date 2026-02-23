import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_loader.dart';
import '../../../core/widgets/common_toast.dart';
import '../models/bod_member_result.dart';
import '../providers/profile_provider.dart';

/// Port of iOS ChangeRequestViewController.
/// Allows members to submit change requests with category + remark.
/// APIs: FindRotarian/GetCategoryList, Member/Saveprofile.
class ChangeRequestScreen extends StatefulWidget {
  const ChangeRequestScreen({
    super.key,
    required this.memberId,
  });

  final String memberId;

  @override
  State<ChangeRequestScreen> createState() => _ChangeRequestScreenState();
}

class _ChangeRequestScreenState extends State<ChangeRequestScreen> {
  final _remarkController = TextEditingController();
  CategoryItem? _selectedCategory;

  @override
  void initState() {
    super.initState();
    context.read<ProfileProvider>().fetchCategories();
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  void _showCategoryPicker() {
    final provider = context.read<ProfileProvider>();
    final categories = provider.categories;
    if (categories.isEmpty) return;

    // Find initial index based on current selection
    int selectedIndex = 0;
    if (_selectedCategory != null) {
      final idx = categories.indexWhere((c) => c.id == _selectedCategory!.id);
      if (idx >= 0) selectedIndex = idx;
    }

    CategoryItem tempSelected = categories[selectedIndex];

    showModalBottomSheet<CategoryItem>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: 300,
            child: Column(
              children: [
                // Toolbar with Cancel and Done
                Container(
                  color: AppColors.backgroundGray,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        'Select Category',
                        style: AppTextStyles.heading6,
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, tempSelected),
                        child: Text(
                          'Done',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Cupertino Picker
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: selectedIndex,
                    ),
                    itemExtent: 40,
                    onSelectedItemChanged: (index) {
                      tempSelected = categories[index];
                    },
                    children: categories.map((cat) {
                      return Center(
                        child: Text(
                          cat.name ?? '',
                          style: AppTextStyles.body2,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((selected) {
      if (selected != null) {
        setState(() => _selectedCategory = selected);
      }
    });
  }

  /// iOS validation: text.count > 0 AND Id != ""
  Future<void> _submitRequest() async {
    final remark = _remarkController.text.trim();
    if (remark.isEmpty) {
      CommonToast.show(context, 'Please enter your remark');
      return;
    }
    if (_selectedCategory == null || _selectedCategory!.id == null) {
      CommonToast.show(context, 'Please select a category');
      return;
    }

    CommonLoader.show(context);
    final provider = context.read<ProfileProvider>();
    final success = await provider.submitChangeRequest(
      memberId: widget.memberId,
      remark: remark,
      categoryId: _selectedCategory!.id!,
    );

    if (!mounted) return;
    CommonLoader.dismiss(context);

    if (success) {
      CommonToast.success(context, 'Request submitted successfully');
      Navigator.of(context).pop(true);
    } else {
      CommonToast.error(context, 'Failed to submit request');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(title: 'Change Request'),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Category selector
                Text(
                  'Category',
                  style: AppTextStyles.label,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: provider.isLoadingCategories
                      ? null
                      : _showCategoryPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedCategory?.name ?? 'Select Category',
                            style: _selectedCategory != null
                                ? AppTextStyles.body2
                                : AppTextStyles.body2.copyWith(
                                    color: AppColors.textHint,
                                  ),
                          ),
                        ),
                        if (provider.isLoadingCategories)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          const Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.textSecondary,
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Remark text area
                Text(
                  'Remark',
                  style: AppTextStyles.label,
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _remarkController,
                    maxLines: 6,
                    style: AppTextStyles.input,
                    decoration: InputDecoration(
                      hintText: 'Enter your change request details...',
                      hintStyle: AppTextStyles.inputHint,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Submit button
                ElevatedButton(
                  onPressed: provider.isLoading ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Submit',
                    style: AppTextStyles.button,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
