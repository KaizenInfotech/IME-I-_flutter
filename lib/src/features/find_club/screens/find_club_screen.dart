import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_text_field.dart';
import '../../../core/widgets/common_toast.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../models/club_result.dart';
import '../providers/find_club_provider.dart';
import '../widgets/club_card.dart';
import 'club_detail_screen.dart';

/// Port of iOS AnyClubNewViewController + SearchAnyClubNearMeClubViewController.
/// Club search form with keyword/country/state/district fields, plus results list.
class FindClubScreen extends StatefulWidget {
  const FindClubScreen({super.key});

  @override
  State<FindClubScreen> createState() => _FindClubScreenState();
}

class _FindClubScreenState extends State<FindClubScreen> {
  final _keywordController = TextEditingController();
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  final _districtController = TextEditingController();
  final _searchController = TextEditingController();

  bool _showResults = false;

  @override
  void dispose() {
    _keywordController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// iOS: functionForSearchFindAclub() — validate and search.
  void _search() {
    final keyword = _keywordController.text.trim();
    final country = _countryController.text.trim();
    final stateCity = _stateController.text.trim();
    final district = _districtController.text.trim();

    if (keyword.isEmpty && country.isEmpty && stateCity.isEmpty && district.isEmpty) {
      CommonToast.show(context, 'Please fill at least one search criteria');
      return;
    }

    context.read<FindClubProvider>().fetchClubList(
          keyword: keyword,
          country: country,
          stateProvinceCity: stateCity,
          district: district,
        );

    setState(() => _showResults = true);
  }

  void _onSearchChanged(String query) {
    context.read<FindClubProvider>().searchClubs(query);
  }

  void _navigateToDetail(ClubItem club) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClubDetailScreen(
          groupId: club.groupId ?? '',
          clubName: club.clubName ?? 'Club Details',
        ),
      ),
    );
  }

  void _backToSearch() {
    setState(() => _showResults = false);
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(
        title: _showResults ? 'Search Results' : 'Find A Club',
        showBackButton: true,
      ),
      body: _showResults ? _buildResultsView() : _buildSearchForm(),
    );
  }

  /// iOS: Search form with text fields
  Widget _buildSearchForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                Text('Search Criteria', style: AppTextStyles.heading6),
                const SizedBox(height: 12),

                // iOS: textfieldKeyword
                CommonTextField(
                  controller: _keywordController,
                  label: 'Club Name / Keyword',
                  hint: 'Enter club name or keyword',
                ),
                const SizedBox(height: 12),

                // iOS: textfieldCountry
                CommonTextField(
                  controller: _countryController,
                  label: 'Country',
                  hint: 'Enter country',
                ),
                const SizedBox(height: 12),

                // iOS: textfieldStates
                CommonTextField(
                  controller: _stateController,
                  label: 'State / Province / City',
                  hint: 'Enter state, province, or city',
                ),
                const SizedBox(height: 12),

                // iOS: textfieldDistrict
                CommonTextField(
                  controller: _districtController,
                  label: 'District',
                  hint: 'Enter district number',
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
  }

  /// iOS: SearchAnyClubNearMeClubViewController — results list
  Widget _buildResultsView() {
    return Column(
      children: [
        // Search/filter bar
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Back to search
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 18),
                onPressed: _backToSearch,
              ),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Filter results...',
                    hintStyle: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.backgroundGray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Results
        Expanded(
          child: Consumer<FindClubProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.error != null) {
                return EmptyStateWidget(
                  icon: Icons.error_outline,
                  message: provider.error!,
                );
              }

              final list = provider.clubs;
              if (list.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.business,
                  message: 'No clubs found',
                );
              }

              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, index) {
                  final item = list[index];
                  return ClubCard(
                    club: item,
                    onTap: () => _navigateToDetail(item),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
