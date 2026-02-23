import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_loader.dart';
import '../../../core/widgets/common_toast.dart';
import '../models/member_detail_result.dart';
import '../providers/directory_provider.dart';

/// Port of iOS EditDirectoryController.swift — editable profile form.
/// Handles profile update (name, mobile, email), personal details update,
/// address update, and family member update.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.member,
    required this.profileId,
    required this.groupId,
  });

  final MemberDetail member;
  final String profileId;
  final String groupId;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;

  // Personal detail controllers — iOS: key-value pairs from personalMemberDetails
  final Map<String, TextEditingController> _personalControllers = {};

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.member.memberName ?? '');
    _mobileController =
        TextEditingController(text: widget.member.memberMobile ?? '');
    _emailController =
        TextEditingController(text: widget.member.memberEmail ?? '');

    // Initialize personal detail controllers
    if (widget.member.personalMemberDetails != null) {
      for (final detail in widget.member.personalMemberDetails!) {
        if (detail.uniquekey != null) {
          _personalControllers[detail.uniquekey!] =
              TextEditingController(text: detail.value ?? '');
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    for (final controller in _personalControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// iOS: UpdateMemberDetail → POST Member/UpdateProfile
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<DirectoryProvider>();
    CommonLoader.show(context);

    final success = await provider.updateProfile(
      profileId: widget.profileId,
      memberName: _nameController.text.trim(),
      memberMobile: _mobileController.text.trim(),
      memberEmailId: _emailController.text.trim(),
    );

    if (!mounted) return;
    CommonLoader.dismiss(context);

    if (success) {
      CommonToast.success(context, 'Profile updated successfully');
      Navigator.of(context).pop(true);
    } else {
      CommonToast.error(context, 'Failed to update profile');
    }
  }

  /// iOS: updatepersonalProfile → POST Member/UpdateProfilePersonalDetails
  Future<void> _savePersonalDetails() async {
    final provider = context.read<DirectoryProvider>();
    CommonLoader.show(context);

    final keyValuePairs = <Map<String, String>>[];
    for (final entry in _personalControllers.entries) {
      keyValuePairs.add({
        'uniquekey': entry.key,
        'value': entry.value.text.trim(),
      });
    }

    final success = await provider.updatePersonalDetails(
      profileId: widget.profileId,
      keyValuePairs: keyValuePairs,
    );

    if (!mounted) return;
    CommonLoader.dismiss(context);

    if (success) {
      CommonToast.success(context, 'Personal details updated');
    } else {
      CommonToast.error(context, 'Failed to update personal details');
    }
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
          'Edit Profile',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: AppColors.textOnPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Save',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic profile fields
            _buildSectionTitle('Basic Information'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              label: 'Name',
              icon: Icons.person,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _mobileController,
              label: 'Mobile',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            // Personal detail fields
            if (_personalControllers.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildSectionTitle('Personal Details')),
                  TextButton(
                    onPressed: _savePersonalDetails,
                    child: const Text(
                      'Save Details',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._personalControllers.entries.map((entry) {
                // Find the display key name from original details
                final displayKey = widget.member.personalMemberDetails
                        ?.firstWhere(
                          (d) => d.uniquekey == entry.key,
                          orElse: () => PersonalMemberDetail(key: entry.key),
                        )
                        .key ??
                    entry.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildTextField(
                    controller: entry.value,
                    label: displayKey,
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.textSecondary, size: 20)
            : null,
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      style: const TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
    );
  }
}
