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

/// Port of iOS CreateGroup screen.
/// Form for creating a new group via Group/CreateGroup.
class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _websiteController = TextEditingController();

  CountryItem? _selectedCountry;
  CategoryItem? _selectedCategory;
  String _selectedType = 'Personal';

  final List<String> _groupTypes = ['Personal', 'Social', 'Business'];

  @override
  void initState() {
    super.initState();
    context.read<GroupsProvider>().fetchCountriesAndCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _websiteController.dispose();
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

  void _showCategoryPicker() {
    final provider = context.read<GroupsProvider>();
    if (provider.categories.isEmpty) return;

    showModalBottomSheet<CategoryItem>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Select Category', style: AppTextStyles.heading6),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: provider.categories.length,
                  itemBuilder: (_, index) {
                    final cat = provider.categories[index];
                    return ListTile(
                      title: Text(
                        cat.catName ?? '',
                        style: AppTextStyles.body2,
                      ),
                      trailing:
                          _selectedCategory?.catId == cat.catId
                              ? const Icon(Icons.check,
                                  color: AppColors.primary)
                              : null,
                      onTap: () => Navigator.pop(ctx, cat),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    ).then((selected) {
      if (selected != null) {
        setState(() => _selectedCategory = selected);
      }
    });
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      CommonToast.show(context, 'Please enter group name');
      return;
    }

    CommonLoader.show(context);
    final provider = context.read<GroupsProvider>();
    final userId = LocalStorage.instance.masterUid ?? '';

    final result = await provider.createGroup(
      grpName: name,
      grpType: _selectedType,
      grpCategory: _selectedCategory?.catId ?? '',
      userId: userId,
      address1: _address1Controller.text.trim(),
      address2: _address2Controller.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      pincode: _pincodeController.text.trim(),
      country: _selectedCountry?.countryId ?? '',
      email: _emailController.text.trim(),
      mobile: _mobileController.text.trim(),
      website: _websiteController.text.trim(),
    );

    if (!mounted) return;
    CommonLoader.dismiss(context);

    if (result != null && result.isSuccess) {
      CommonToast.success(context, result.message ?? 'Group created');
      Navigator.of(context).pop(true);
    } else {
      CommonToast.error(
          context, result?.message ?? 'Failed to create group');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(
        title: 'Create Group',
        actions: [
          TextButton(
            onPressed: _createGroup,
            child: const Text(
              'Create',
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
                // Group Name
                CommonTextField(
                  controller: _nameController,
                  label: 'Group Name *',
                  hint: 'Enter group name',
                  validator: (val) => (val == null || val.trim().isEmpty)
                      ? 'Group name is required'
                      : null,
                ),
                const SizedBox(height: 16),

                // Group Type
                Text('Group Type', style: AppTextStyles.label),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  children: _groupTypes.map((type) {
                    final isSelected = _selectedType == type;
                    return ChoiceChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _selectedType = type),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        color: isSelected
                            ? AppColors.textOnPrimary
                            : AppColors.textPrimary,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Category Picker
                Text('Category', style: AppTextStyles.label),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _showCategoryPicker,
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
                            _selectedCategory?.catName ?? 'Select Category',
                            style: _selectedCategory != null
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
                const SizedBox(height: 16),

                // Address fields
                CommonTextField(
                  controller: _address1Controller,
                  label: 'Address Line 1',
                  hint: 'Enter address',
                ),
                const SizedBox(height: 16),
                CommonTextField(
                  controller: _address2Controller,
                  label: 'Address Line 2',
                  hint: 'Enter address',
                ),
                const SizedBox(height: 16),
                CommonTextField(
                  controller: _cityController,
                  label: 'City',
                  hint: 'Enter city',
                ),
                const SizedBox(height: 16),
                CommonTextField(
                  controller: _stateController,
                  label: 'State',
                  hint: 'Enter state',
                ),
                const SizedBox(height: 16),
                CommonTextField(
                  controller: _pincodeController,
                  label: 'Pincode',
                  hint: 'Enter pincode',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CommonTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CommonTextField(
                  controller: _mobileController,
                  label: 'Mobile',
                  hint: 'Enter mobile number',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                CommonTextField(
                  controller: _websiteController,
                  label: 'Website',
                  hint: 'Enter website URL',
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
