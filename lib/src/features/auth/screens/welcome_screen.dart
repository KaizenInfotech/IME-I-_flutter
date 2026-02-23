import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_loader.dart';
import '../../../core/widgets/common_toast.dart';
import '../providers/auth_provider.dart';

/// Port of iOS OTPSuccessController.swift.
/// Shows welcome message and list of groups the member belongs to.
/// User selects a group to proceed to the dashboard.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  List<_GroupItem> _groups = [];
  String _memberName = '';
  String _clubName = '';
  String _districtName = '';
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadWelcomeData());
  }

  Future<void> _loadWelcomeData() async {
    final authProvider = context.read<AuthProvider>();
    CommonLoader.show(context);

    final success = await authProvider.getWelcomeGroups();

    if (!mounted) return;
    CommonLoader.dismiss(context);

    if (success && authProvider.welcomeGroups != null) {
      _parseGroups(authProvider.welcomeGroups!);
    } else {
      // iOS: shows error message in partOfGroupsLabel
      final error = authProvider.error ?? 'No groups found';
      CommonToast.error(context, error);
    }
  }

  /// Parse welcome groups response.
  /// iOS: WelcomeDelegateFunction extracts grpName and grpId from GrpPartResult.
  void _parseGroups(List<dynamic> groupData) {
    final groups = <_GroupItem>[];
    String memberName = '';
    String clubName = '';
    String districtName = '';

    // Try to get member name from local storage
    memberName = LocalStorage.instance.fullName;

    for (int i = 0; i < groupData.length; i++) {
      final item = groupData[i];
      if (item is Map<String, dynamic>) {
        final grpName = item['grpName']?.toString() ??
            item['GrpName']?.toString() ??
            item['grp_name']?.toString() ??
            '';
        final grpId = item['grpId']?.toString() ??
            item['GrpId']?.toString() ??
            item['grp_id']?.toString() ??
            '';
        final grpProfileId = item['grpProfileId']?.toString() ??
            item['GrpProfileId']?.toString() ??
            '';
        final isGrpAdmin = item['isGrpAdmin']?.toString() ??
            item['IsGrpAdmin']?.toString() ??
            '';

        // iOS: name from welcome.name
        if (item['name'] != null) {
          memberName = item['name'].toString();
        }

        groups.add(_GroupItem(
          name: grpName,
          id: grpId,
          grpProfileId: grpProfileId,
          isGrpAdmin: isGrpAdmin,
        ));

        // iOS: first group = club, second = district
        if (i == 0) clubName = grpName;
        if (i == 1) districtName = grpName;
      }
    }

    setState(() {
      _groups = groups;
      _memberName = memberName;
      _clubName = clubName;
      _districtName = districtName;
      _isLoaded = true;
    });

    // iOS: Save first group ID to UserDefaults
    if (groups.isNotEmpty) {
      LocalStorage.instance.setGroupId(groups.first.id);
    }
  }

  /// iOS: NextButtonAction — push to rootDash.
  Future<void> _onNext() async {
    CommonLoader.show(context);

    // Small delay matching iOS DispatchQueue.main.asyncAfter(.now() + 1)
    await Future<void>.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    CommonLoader.dismiss(context);

    // Navigate to dashboard (root route replacement).
    context.go('/dashboard');
  }

  /// iOS: tableView didSelectRow — select a group.
  Future<void> _selectGroup(_GroupItem group) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.selectGroup(
      groupId: group.id,
      groupName: group.name,
      grpProfileId: group.grpProfileId.isNotEmpty ? group.grpProfileId : null,
      isGrpAdmin: group.isGrpAdmin.isNotEmpty ? group.isGrpAdmin : null,
    );
    _onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // iOS: backgroundColor = UIColor(red: 40/255, green: 27/255, blue: 146/255)
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: AppColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
      ),
      body: Column(
        children: [
          // Header section
          if (_isLoaded) _buildHeader(),
          // Group list
          Expanded(
            child: _isLoaded ? _buildGroupList() : const SizedBox.shrink(),
          ),
          // iOS: buttonNext at bottom
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // iOS: labelWelcome "Welcome"
          const Text(
            'Welcome',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: AppColors.textOnPrimary,
            ),
          ),
          const SizedBox(height: 8),
          // iOS: userNameLblll — member name
          if (_memberName.isNotEmpty)
            Text(
              _memberName,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textOnPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 4),
          // iOS: labelFrom "from"
          if (_clubName.isNotEmpty)
            const Text(
              'from',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
                color: AppColors.textOnPrimary,
              ),
            ),
          // iOS: chapterLbllll — club name
          if (_clubName.isNotEmpty)
            Text(
              _clubName,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textOnPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          // iOS: zoneLbll — district name
          if (_districtName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _districtName,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  color: AppColors.textOnPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 8),
          // iOS: mobileNumLabel
          Text(
            LocalStorage.instance.mobileNo ?? '',
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14,
              color: AppColors.textOnPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupList() {
    if (_groups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            context.read<AuthProvider>().error ?? 'No groups found',
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14,
              color: AppColors.textOnPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // iOS: groupNamesTableView with OTPSuccessCell
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // iOS: partOfGroupsLabel "You are part of following groups"
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'You are part of following groups',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _groups.length,
              separatorBuilder: (_, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final group = _groups[index];
                return ListTile(
                  title: Text(
                    group.name,
                    style: AppTextStyles.body2,
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () => _selectGroup(group),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _groups.isNotEmpty ? _onNext : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Next',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Internal group model for the welcome screen.
class _GroupItem {
  final String name;
  final String id;
  final String grpProfileId;
  final String isGrpAdmin;

  const _GroupItem({
    required this.name,
    required this.id,
    this.grpProfileId = '',
    this.isGrpAdmin = '',
  });
}
