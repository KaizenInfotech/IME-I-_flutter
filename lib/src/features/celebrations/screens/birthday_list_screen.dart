import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../models/birthday_result.dart';
import '../providers/celebrations_provider.dart';

/// Port of iOS birthday/anniversary list from CelebrationViewController.
/// Shows today's birthdays and anniversaries from Celebrations/GetTodaysBirthday.
/// iOS: BirthAnnivPopupTableViewCell with call/SMS actions.
class BirthdayListScreen extends StatefulWidget {
  const BirthdayListScreen({
    super.key,
    this.groupId,
  });

  final String? groupId;

  @override
  State<BirthdayListScreen> createState() => _BirthdayListScreenState();
}

class _BirthdayListScreenState extends State<BirthdayListScreen> {
  int _selectedTabIndex = 0;
  String _groupId = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _groupId = widget.groupId ??
        LocalStorage.instance.authGroupId ??
        '';

    if (!mounted) return;

    context.read<CelebrationsProvider>().fetchTodaysBirthday(
          groupID: _groupId,
        );
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
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
          "Today's Celebrations",
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: AppColors.textOnPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<CelebrationsProvider>(
        builder: (context, provider, _) {
          final birthdayResult = provider.todaysBirthday;

          return Column(
            children: [
              // Tab bar — same style as Events & Celebrations
              _buildTabBar(),
              // Tab content
              Expanded(
                child: birthdayResult == null
                    ? const Center(child: CircularProgressIndicator())
                    : _selectedTabIndex == 0
                        ? _buildBirthdayList(birthdayResult.birthdayOnly)
                        : _buildBirthdayList(birthdayResult.anniversaryOnly),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildTab(0, 'BIRTHDAY'),
          _buildTab(1, 'ANNIVERSARY'),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabChanged(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBirthdayList(List<BirthdayItem> items) {
    if (items.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.cake,
        message: 'No celebrations today',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length,
        itemBuilder: (_, index) {
          return _buildBirthdayTile(items[index]);
        },
      ),
    );
  }

  Widget _buildBirthdayTile(BirthdayItem item) {
    final isBirthday = item.isBirthday;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          // Type icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isBirthday
                  ? const Color(0xFFE91E63).withAlpha(25)
                  : const Color(0xFFFF9800).withAlpha(25),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              isBirthday ? Icons.cake : Icons.favorite,
              color: isBirthday
                  ? const Color(0xFFE91E63)
                  : const Color(0xFFFF9800),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Name and relation
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.memberName ?? '',
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.relation != null && item.relation!.isNotEmpty)
                  Text(
                    item.relation!,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 8),
          // Contact actions — same style as CelebrationListTile
          if (item.hasPhone)
            _buildActionIcon(Icons.phone, AppColors.primary, () => _makeCall(item.firstPhone!))
          else
            _buildDisabledIcon(Icons.phone),
          const SizedBox(width: 16),
          if (item.hasPhone)
            _buildActionIcon(Icons.chat, Colors.amber.shade700, () => _sendSms(item.firstPhone!))
          else
            _buildDisabledIcon(Icons.chat),
          const SizedBox(width: 16),
          if (item.hasEmail)
            _buildActionIcon(Icons.email, AppColors.primaryBlue, () => _sendEmail(item.firstEmail!))
          else
            _buildDisabledIcon(Icons.email),
          const SizedBox(width: 16),
          if (item.hasPhone)
            GestureDetector(
              onTap: () => _openWhatsApp(item.firstPhone!),
              child: Image.asset('assets/images/whatsapp.png', width: 26, height: 26),
            )
          else
            Image.asset('assets/images/whats_grey.png', width: 30, height: 30, color: AppColors.grayMedium),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Icon(icon, size: 26, color: color),
    );
  }

  Future<void> _makeCall(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendSms(String phone) async {
    final uri = Uri(scheme: 'sms', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    var cleaned = phone;
    if (cleaned.startsWith('+91 ')) {
      cleaned = cleaned.substring(4);
    }
    cleaned = cleaned.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse('https://api.whatsapp.com/send?phone=91$cleaned');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildDisabledIcon(IconData icon) {
    return Icon(icon, size: 26, color: AppColors.grayMedium);
  }
}
