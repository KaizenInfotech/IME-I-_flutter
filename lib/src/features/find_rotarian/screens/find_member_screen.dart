import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_toast.dart';
import '../providers/find_rotarian_provider.dart';
import 'search_rotarian_screen.dart';

/// Port of iOS FinddArotarianViewControllerers for IMEI "Find Member" module.
/// Shows Name text field, Membership Grade picker, Branch/Chapter picker,
/// Category picker, and Search button.
class FindMemberScreen extends StatefulWidget {
  const FindMemberScreen({super.key});

  @override
  State<FindMemberScreen> createState() => _FindMemberScreenState();
}

class _FindMemberScreenState extends State<FindMemberScreen> {
  final _nameController = TextEditingController();
  String _selectedGrade = '';
  String _selectedClub = '';
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
    context.read<FindRotarianProvider>().fetchFindMemberDropdowns();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// iOS: validate and search with FindRotarian/GetRotarianList.
  void _search() {
    final name = _nameController.text.trim();

    // iOS: "Please fill at least one field for Member Search"
    if (name.isEmpty &&
        _selectedGrade.isEmpty &&
        _selectedClub.isEmpty &&
        _selectedCategory.isEmpty) {
      CommonToast.show(
          context, 'Please fill at least one field for Member Search');
      return;
    }

    context.read<FindRotarianProvider>().fetchRotarianList(
          name: name,
          grade: _selectedGrade,
          club: _selectedClub,
          category: _selectedCategory,
        );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SearchRotarianScreen(),
      ),
    );
  }

  /// iOS-style CupertinoPicker bottom sheet.
  void _showPicker({
    required String title,
    required List<DropdownItem> items,
    required String currentValue,
    required ValueChanged<String> onSelected,
  }) {
    if (items.isEmpty) return;

    int selectedIndex = 0;
    if (currentValue.isNotEmpty) {
      final idx = items.indexWhere((item) => item.name == currentValue);
      if (idx >= 0) selectedIndex = idx;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with title and Done button
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 50),
                    Text(
                      title,
                      style: AppTextStyles.body2
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () {
                        final selected =
                            items[selectedIndex].name ?? '';
                        onSelected(selected);
                        Navigator.pop(ctx);
                      },
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

              // Cupertino picker wheel
              SizedBox(
                height: 200,
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                      initialItem: selectedIndex),
                  itemExtent: 44,
                  onSelectedItemChanged: (index) {
                    selectedIndex = index;
                  },
                  children: items.map((item) {
                    return Center(
                      child: Text(
                        item.name ?? '',
                        style: AppTextStyles.body1,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: MediaQuery.of(ctx).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const CommonAppBar(title: 'Find Member'),
      body: Consumer<FindRotarianProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingDropdowns) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text('Name', style: AppTextStyles.body2),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Enter Name',
                          hintStyle: AppTextStyles.body2
                              .copyWith(color: AppColors.grayMedium),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          suffixIcon: _nameController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      size: 18,
                                      color: AppColors.grayMedium),
                                  onPressed: () {
                                    _nameController.clear();
                                  },
                                )
                              : null,
                          border: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Membership Grade picker
                      Text('Membership Grade', style: AppTextStyles.body2),
                      const SizedBox(height: 6),
                      _buildPickerField(
                        value: _selectedGrade,
                        hint: 'Select Grade',
                        onTap: () => _showPicker(
                          title: 'Select Grade',
                          items: provider.gradeList,
                          currentValue: _selectedGrade,
                          onSelected: (val) =>
                              setState(() => _selectedGrade = val),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Members of Branches / Chapters picker
                      Text('Members of Branches / Chapters',
                          style: AppTextStyles.body2),
                      const SizedBox(height: 6),
                      _buildPickerField(
                        value: _selectedClub,
                        hint: 'Select',
                        onTap: () => _showPicker(
                          title: 'Select',
                          items: provider.clubList,
                          currentValue: _selectedClub,
                          onSelected: (val) =>
                              setState(() => _selectedClub = val),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Category picker
                      Text('Category', style: AppTextStyles.body2),
                      const SizedBox(height: 6),
                      _buildPickerField(
                        value: _selectedCategory,
                        hint: 'Select',
                        onTap: () => _showPicker(
                          title: 'Select',
                          items: provider.categoryList,
                          currentValue: _selectedCategory,
                          onSelected: (val) =>
                              setState(() => _selectedCategory = val),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Search button at bottom
              const Divider(height: 1),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _search,
                      child: Text(
                        'Search',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Builds a tappable field that looks like a text field but opens a picker.
  Widget _buildPickerField({
    required String value,
    required String hint,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border),
          ),
        ),
        child: Text(
          value.isEmpty ? hint : value,
          style: value.isEmpty
              ? AppTextStyles.body2.copyWith(color: AppColors.grayMedium)
              : AppTextStyles.body2,
        ),
      ),
    );
  }
}
