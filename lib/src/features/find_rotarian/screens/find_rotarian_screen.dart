import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_text_field.dart';
import '../../../core/widgets/common_toast.dart';
import '../providers/find_rotarian_provider.dart';
import '../widgets/zone_chapter_picker.dart';
import 'search_rotarian_screen.dart';

/// Port of iOS FinddArotarianViewController — find rotarian search form.
/// Zone/Chapter cascading dropdowns + name/classification/city search fields.
class FindRotarianScreen extends StatefulWidget {
  const FindRotarianScreen({super.key});

  @override
  State<FindRotarianScreen> createState() => _FindRotarianScreenState();
}

class _FindRotarianScreenState extends State<FindRotarianScreen> {
  final _nameController = TextEditingController();
  final _classificationController = TextEditingController();
  final _cityClubController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<FindRotarianProvider>().fetchZoneChapterList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _classificationController.dispose();
    _cityClubController.dispose();
    super.dispose();
  }

  /// iOS: functionForSearchFindAclub() — validate and search.
  void _search() {
    final name = _nameController.text.trim();
    final classification = _classificationController.text.trim();
    final cityClub = _cityClubController.text.trim();

    // iOS: "Please Fill Atleast One Search Criteria"
    if (name.isEmpty && classification.isEmpty && cityClub.isEmpty) {
      CommonToast.show(context, 'Please fill at least one search criteria');
      return;
    }

    context.read<FindRotarianProvider>().fetchRotarianList(
          name: name,
          category: classification,
          club: cityClub,
        );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SearchRotarianScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(title: 'Find A Rotarian'),
      body: Consumer<FindRotarianProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Zone / Chapter cascading dropdowns
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Filter by Zone / Chapter',
                          style: AppTextStyles.heading6),
                      const SizedBox(height: 12),
                      ZoneChapterPicker(
                        zones: provider.zones,
                        chapters: provider.filteredChapters,
                        selectedZone: provider.selectedZone,
                        selectedChapter: provider.selectedChapter,
                        onZoneChanged: (zone) =>
                            provider.selectZone(zone),
                        onChapterChanged: (chapter) =>
                            provider.selectChapter(chapter),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Search fields
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Search Criteria',
                          style: AppTextStyles.heading6),
                      const SizedBox(height: 12),

                      // iOS: textfieldName
                      CommonTextField(
                        controller: _nameController,
                        label: 'Name',
                        hint: 'Enter name',
                      ),
                      const SizedBox(height: 12),

                      // iOS: textfieldClassificationKeyword
                      CommonTextField(
                        controller: _classificationController,
                        label: 'Classification / Keyword',
                        hint: 'Enter classification or keyword',
                      ),
                      const SizedBox(height: 12),

                      // iOS: textfieldCityClub
                      CommonTextField(
                        controller: _cityClubController,
                        label: 'City / Club',
                        hint: 'Enter city or club name',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Search button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _search,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Search',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
