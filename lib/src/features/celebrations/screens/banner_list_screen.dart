import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state_widget.dart';
import 'celebrations_screen.dart';

/// Port of iOS BannerListViewController.swift — club/group selection list.
/// Loads dashboard banner data (clubs/districts) via Group/GetNewDashboard.
/// User selects a club to navigate to CelebrationsScreen with that club's context.
class BannerListScreen extends StatefulWidget {
  const BannerListScreen({super.key});

  @override
  State<BannerListScreen> createState() => _BannerListScreenState();
}

class _BannerListScreenState extends State<BannerListScreen> {
  List<Map<String, dynamic>> _bannerList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBannerList();
  }

  Future<void> _loadBannerList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final masterUID =
          LocalStorage.instance.masterUid ?? '';

      final response = await ApiClient.instance.post(
        ApiConstants.groupGetNewDashboard,
        body: {'MasterId': masterUID},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final dashResult =
            jsonData['TBDashboardResult'] as Map<String, dynamic>?;

        if (dashResult != null && dashResult['status'] == '0') {
          final resultList = dashResult['Result'] as List<dynamic>?;
          if (resultList != null) {
            _bannerList = resultList
                .map((e) => e as Map<String, dynamic>)
                .toList();
          }
        } else {
          _error = 'No clubs found';
        }
      } else {
        _error = 'Server error';
      }
    } catch (e) {
      _error = 'Error loading clubs: $e';
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onBannerTap(Map<String, dynamic> banner) {
    final clubId = banner['ClubId']?.toString() ?? '';

    // iOS: saves selected group ID and navigates to celebration
    LocalStorage.instance.setAuthGroupId(clubId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CelebrationsScreen(
          groupId: clubId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
        title: const Text(
          'Please Select',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: AppColors.textOnPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? EmptyStateWidget(
                  icon: Icons.error_outline,
                  message: _error!,
                  onRetry: _loadBannerList,
                  retryLabel: 'Retry',
                )
              : _bannerList.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.groups,
                      message: 'No clubs found',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _bannerList.length,
                      itemBuilder: (_, index) {
                        return _buildBannerCard(_bannerList[index]);
                      },
                    ),
    );
  }

  Widget _buildBannerCard(Map<String, dynamic> banner) {
    final clubName = banner['ClubName']?.toString() ?? '';
    final clubImage = banner['club_image']?.toString() ?? '';
    final groupCategory = banner['group_category']?.toString() ?? '1';

    // iOS: blue shadow for Club (1), orange for District (2)
    final isClub = groupCategory == '1';
    final accentColor = isClub ? Colors.blue : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 3,
      shadowColor: accentColor.withAlpha(128),
      child: InkWell(
        onTap: () => _onBannerTap(banner),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Club image — iOS: imgVieww circular
              ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: clubImage.isNotEmpty
                    ? Image.network(
                        clubImage.replaceAll(' ', '%20'),
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
              const SizedBox(width: 16),

              // Club name
              Expanded(
                child: Text(
                  clubName,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: accentColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              Icon(
                Icons.chevron_right,
                color: accentColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: BorderRadius.circular(35),
      ),
      child: const Icon(
        Icons.groups,
        color: AppColors.grayMedium,
        size: 32,
      ),
    );
  }
}
