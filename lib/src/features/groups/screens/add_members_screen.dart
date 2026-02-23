import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_loader.dart';
import '../../../core/widgets/common_text_field.dart';
import '../../../core/widgets/common_toast.dart';
import '../models/country_result.dart';
import '../providers/groups_provider.dart';

/// Port of iOS AddMemberToGroup screen.
/// Adds a member to a group via Group/AddMemberToGroup.
class AddMembersScreen extends StatefulWidget {
  const AddMembersScreen({
    super.key,
    required this.groupId,
  });

  final String groupId;

  @override
  State<AddMembersScreen> createState() => _AddMembersScreenState();
}

class _AddMembersScreenState extends State<AddMembersScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();

  CountryItem? _selectedCountry;

  @override
  void initState() {
    super.initState();
    final provider = context.read<GroupsProvider>();
    if (provider.countries.isEmpty) {
      provider.fetchCountriesAndCategories();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showCountryPicker() {
    final provider = context.read<GroupsProvider>();
    if (provider.countries.isEmpty) return;

    showModalBottomSheet<CountryItem>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Select Country', style: AppTextStyles.heading6),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: provider.countries.length,
                    itemBuilder: (_, index) {
                      final country = provider.countries[index];
                      return ListTile(
                        title: Text(
                          country.countryName ?? '',
                          style: AppTextStyles.body2,
                        ),
                        trailing: _selectedCountry?.countryId ==
                                country.countryId
                            ? const Icon(Icons.check, color: AppColors.primary)
                            : null,
                        onTap: () => Navigator.pop(ctx, country),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((selected) {
      if (selected != null) {
        setState(() => _selectedCountry = selected);
      }
    });
  }

  Future<void> _addMember() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final mobile = _mobileController.text.trim();
    if (name.isEmpty) {
      CommonToast.show(context, 'Please enter member name');
      return;
    }
    if (mobile.isEmpty) {
      CommonToast.show(context, 'Please enter mobile number');
      return;
    }

    CommonLoader.show(context);
    final provider = context.read<GroupsProvider>();
    final masterId = LocalStorage.instance.masterUid ?? '';

    final result = await provider.addMemberToGroup(
      mobile: mobile,
      userName: name,
      groupId: widget.groupId,
      masterId: masterId,
      countryId: _selectedCountry?.countryId ?? '',
      memberEmail: _emailController.text.trim(),
    );

    if (!mounted) return;
    CommonLoader.dismiss(context);

    if (result != null && result.isSuccess) {
      CommonToast.success(context, result.message ?? 'Member added');
      Navigator.of(context).pop(true);
    } else {
      CommonToast.error(
          context, result?.message ?? 'Failed to add member');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(
        title: 'Add Member',
        actions: [
          TextButton(
            onPressed: _addMember,
            child: const Text(
              'Add',
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
      body: Consumer<GroupsProvider>(
        builder: (context, provider, _) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                CommonTextField(
                  controller: _nameController,
                  label: 'Name *',
                  hint: 'Enter member name',
                  validator: (val) => (val == null || val.trim().isEmpty)
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: 16),
                CommonTextField(
                  controller: _mobileController,
                  label: 'Mobile *',
                  hint: 'Enter mobile number',
                  keyboardType: TextInputType.phone,
                  validator: (val) => (val == null || val.trim().isEmpty)
                      ? 'Mobile is required'
                      : null,
                ),
                const SizedBox(height: 16),
                CommonTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter email address',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Country Picker
                Text('Country', style: AppTextStyles.label),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _showCountryPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedCountry?.countryName ??
                                'Select Country',
                            style: _selectedCountry != null
                                ? AppTextStyles.body2
                                : AppTextStyles.body2
                                    .copyWith(color: AppColors.textHint),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down,
                            color: AppColors.textSecondary),
                      ],
                    ),
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
