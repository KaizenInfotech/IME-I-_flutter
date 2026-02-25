import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';

/// Port of iOS BranchDashboardViewController.
/// Sub-dashboard for a specific branch/chapter with 8 module grid:
/// Members, Past Events, Announcements, Past Chairmen,
/// Executive Committee, Events Attendance, Birthdays, To Branches/Chapter.
class BranchDashboardScreen extends StatelessWidget {
  const BranchDashboardScreen({
    super.key,
    required this.branchName,
    required this.clubName,
  });

  /// iOS: email — the branch name from UserDefaults "GrpName"
  final String branchName;

  /// iOS: branch — the club name label text (e.g. "Testing")
  final String clubName;

  /// iOS: email-to mapping based on branch name
  static const Map<String, String> _branchEmailMap = {
    'Chandigarh Chapter': 'arun1714@gmail.com',
    'Chennai Branch': 'chairmanchennai@imare.in',
    'Delhi Branch': 'chairmandelhi@imare.in',
    'Goa Branch': 'imehousegoa@gmail.com',
    'Gujarat Chapter': 'servtech@sify.com',
    'Hyderabad Chapter': 'subbarajupbv@gmail.com',
    'Karnataka Chapter': 'vivaeng@hotmail.com',
    'Kochi Branch': 'kochi@imare.in',
    'Kolkata Branch': 'imeikol@yahoo.co.in',
    'Mumbai Branch': 'mumbai@imare.in',
    'Navi Mumbai Chapter': 'administration@imare.in',
    'Patna Chapter': 'imeipatna@gmail.com',
    'Pune Branch': 'pune@imare.in',
  };

  void _onModuleTap(BuildContext context, int index) {
    final storage = LocalStorage.instance;
    final groupId = storage.groupIdPrimary ?? '';

    switch (index) {
      case 0: // Members
        context.push('/branch-dashboard/members', extra: {
          'branchName': branchName,
          'groupId': groupId,
        });
        break;
      case 1: // Past Events
        context.push('/branch-dashboard/past-events', extra: {
          'groupId': groupId,
        });
        break;
      case 2: // Announcements
        context.push('/announcements', extra: {
          'groupId': groupId,
          'profileId': storage.imeiMemberId ?? storage.masterUid ?? '',
          'moduleId': '3',
        });
        break;
      case 3: // Past Chairmen
        context.push('/branch-dashboard/past-chairmen', extra: {
          'groupId': groupId,
        });
        break;
      case 4: // Executive Committee
        context.push('/branch-dashboard/executive-committee', extra: {
          'groupId': groupId,
        });
        break;
      case 5: // Events Attendance
        context.push('/attendance', extra: {
          'groupId': groupId,
        });
        break;
      case 6: // Birthdays
        context.push('/celebrations/birthday', extra: {
          'groupId': groupId,
        });
        break;
      case 7: // To Branches/Chapter (Feedback email)
        _launchFeedbackEmail();
        break;
    }
  }

  void _launchFeedbackEmail() async {
    final email = _branchEmailMap[branchName] ?? 'registration@imare.in';
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(title: branchName.isNotEmpty ? branchName : clubName),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
          children: List.generate(_modules.length, (index) {
            final module = _modules[index];
            return _buildModuleCell(context, module, index);
          }),
        ),
      ),
    );
  }

  Widget _buildModuleCell(
      BuildContext context, _BranchModule module, int index) {
    return GestureDetector(
      onTap: () => _onModuleTap(context, index),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: 
            Image.asset(
                      module.assetPath,
                      fit: BoxFit.contain,
                    ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              module.label,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w500,
              ),
              
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Module definition for branch dashboard grid.
class _BranchModule {
  const _BranchModule({
    required this.label,
    required this.assetPath,
  });

  final String label;
  final String assetPath;
}

/// iOS: 8 modules in BranchDashboardViewController collectionView
const _modules = [
  _BranchModule(
    label: 'Members',
    assetPath: 'assets/images/direct.png',
  ),
  _BranchModule(
    label: 'Past Events',
    assetPath: 'assets/images/eventss.png',
  ),
  _BranchModule(
    label: 'Announcements',
    assetPath: 'assets/images/announce.png',
  ),
  _BranchModule(
    label: 'Past Chairman',
    assetPath: 'assets/images/pastchair.png',
  ),
  _BranchModule(
    label: 'Executive Committee',
    assetPath: 'assets/images/execu.png',
  ),
  _BranchModule(
    label: 'Events Attendance',
    assetPath: 'assets/images/att.png',
  ),
  _BranchModule(
    label: 'Birthdays',
    assetPath: 'assets/images/calender.png',
  ),
  _BranchModule(
    label: 'To Branches/\nChapter',
    assetPath: 'assets/images/feedback.png',
  ),
];
