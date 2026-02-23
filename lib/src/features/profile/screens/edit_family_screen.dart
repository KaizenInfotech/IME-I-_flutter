import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_loader.dart';
import '../../../core/widgets/common_text_field.dart';
import '../../../core/widgets/common_toast.dart';
import '../providers/profile_provider.dart';

/// Port of iOS FamilySegmentViewController / AddFamilyMemberVC.
/// Add or edit a family member via Member/UpdateFamilyDetails.
class EditFamilyScreen extends StatefulWidget {
  const EditFamilyScreen({
    super.key,
    required this.profileId,
    this.familyMemberId,
    this.initialName,
    this.initialRelationship,
    this.initialDob,
    this.initialAnniversary,
    this.initialContact,
    this.initialEmail,
    this.initialBloodGroup,
    this.initialParticulars,
  });

  final String profileId;

  /// Null for adding a new member, non-null for editing existing.
  final String? familyMemberId;
  final String? initialName;
  final String? initialRelationship;
  final String? initialDob;
  final String? initialAnniversary;
  final String? initialContact;
  final String? initialEmail;
  final String? initialBloodGroup;
  final String? initialParticulars;

  bool get isEditing => familyMemberId != null && familyMemberId!.isNotEmpty;

  @override
  State<EditFamilyScreen> createState() => _EditFamilyScreenState();
}

class _EditFamilyScreenState extends State<EditFamilyScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _relationshipController;
  late TextEditingController _dobController;
  late TextEditingController _anniversaryController;
  late TextEditingController _contactController;
  late TextEditingController _emailController;
  late TextEditingController _bloodGroupController;
  late TextEditingController _particularsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _relationshipController =
        TextEditingController(text: widget.initialRelationship ?? '');
    _dobController = TextEditingController(text: widget.initialDob ?? '');
    _anniversaryController =
        TextEditingController(text: widget.initialAnniversary ?? '');
    _contactController =
        TextEditingController(text: widget.initialContact ?? '');
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    _bloodGroupController =
        TextEditingController(text: widget.initialBloodGroup ?? '');
    _particularsController =
        TextEditingController(text: widget.initialParticulars ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _dobController.dispose();
    _anniversaryController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _bloodGroupController.dispose();
    _particularsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      controller.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      CommonToast.show(context, 'Please enter member name');
      return;
    }

    CommonLoader.show(context);
    final provider = context.read<ProfileProvider>();
    final success = await provider.updateFamilyDetails(
      familyMemberId: widget.familyMemberId ?? '0',
      memberName: name,
      relationship: _relationshipController.text.trim(),
      dob: _dobController.text.trim(),
      anniversary: _anniversaryController.text.trim(),
      contactNo: _contactController.text.trim(),
      particulars: _particularsController.text.trim(),
      profileId: widget.profileId,
      emailId: _emailController.text.trim(),
      bloodGroup: _bloodGroupController.text.trim(),
    );

    if (!mounted) return;
    CommonLoader.dismiss(context);

    if (success) {
      CommonToast.success(
        context,
        widget.isEditing
            ? 'Family member updated successfully'
            : 'Family member added successfully',
      );
      Navigator.of(context).pop(true);
    } else {
      CommonToast.error(context, 'Failed to save family member');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(
        title: widget.isEditing ? 'Edit Family Member' : 'Add Family Member',
        actions: [
          TextButton(
            onPressed: _save,
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
            CommonTextField(
              controller: _nameController,
              label: 'Member Name',
              hint: 'Enter name',
              validator: (val) =>
                  (val == null || val.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            CommonTextField(
              controller: _relationshipController,
              label: 'Relationship',
              hint: 'e.g. Spouse, Son, Daughter',
            ),
            const SizedBox(height: 16),
            CommonTextField(
              controller: _dobController,
              label: 'Date of Birth',
              hint: 'DD/MM/YYYY',
              readOnly: true,
              onTap: () => _pickDate(_dobController),
              suffixIcon:
                  const Icon(Icons.calendar_today, size: 18),
            ),
            const SizedBox(height: 16),
            CommonTextField(
              controller: _anniversaryController,
              label: 'Anniversary',
              hint: 'DD/MM/YYYY',
              readOnly: true,
              onTap: () => _pickDate(_anniversaryController),
              suffixIcon:
                  const Icon(Icons.calendar_today, size: 18),
            ),
            const SizedBox(height: 16),
            CommonTextField(
              controller: _contactController,
              label: 'Contact No',
              hint: 'Enter phone number',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            CommonTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'Enter email address',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            CommonTextField(
              controller: _bloodGroupController,
              label: 'Blood Group',
              hint: 'e.g. A+, B-, O+',
            ),
            const SizedBox(height: 16),
            CommonTextField(
              controller: _particularsController,
              label: 'Particulars',
              hint: 'Additional details',
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
