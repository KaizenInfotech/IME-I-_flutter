import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_loader.dart';
import '../../../core/widgets/common_text_field.dart';
import '../../../core/widgets/common_toast.dart';
import '../providers/profile_provider.dart';

/// Port of iOS address edit form.
/// Updates address via Member/UpdateAddressDetails.
/// iOS: CommonAccessibleHoldVariable.varAddress_*, varCity_*, etc.
class EditAddressScreen extends StatefulWidget {
  const EditAddressScreen({
    super.key,
    required this.profileId,
    required this.groupId,
    this.addressId,
    this.initialAddressType,
    this.initialAddress,
    this.initialCity,
    this.initialState,
    this.initialCountry,
    this.initialPincode,
    this.initialPhoneNo,
    this.initialFax,
  });

  final String profileId;
  final String groupId;

  /// Null / empty for new address, non-null for editing.
  final String? addressId;
  final String? initialAddressType;
  final String? initialAddress;
  final String? initialCity;
  final String? initialState;
  final String? initialCountry;
  final String? initialPincode;
  final String? initialPhoneNo;
  final String? initialFax;

  bool get isEditing => addressId != null && addressId!.isNotEmpty;

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _addressTypeController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _countryController;
  late TextEditingController _pincodeController;
  late TextEditingController _phoneController;
  late TextEditingController _faxController;

  @override
  void initState() {
    super.initState();
    _addressTypeController =
        TextEditingController(text: widget.initialAddressType ?? '');
    _addressController =
        TextEditingController(text: widget.initialAddress ?? '');
    _cityController = TextEditingController(text: widget.initialCity ?? '');
    _stateController = TextEditingController(text: widget.initialState ?? '');
    _countryController =
        TextEditingController(text: widget.initialCountry ?? '');
    _pincodeController =
        TextEditingController(text: widget.initialPincode ?? '');
    _phoneController =
        TextEditingController(text: widget.initialPhoneNo ?? '');
    _faxController = TextEditingController(text: widget.initialFax ?? '');
  }

  @override
  void dispose() {
    _addressTypeController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _pincodeController.dispose();
    _phoneController.dispose();
    _faxController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    CommonLoader.show(context);
    final provider = context.read<ProfileProvider>();
    final success = await provider.updateAddressDetails(
      addressId: widget.addressId ?? '0',
      addressType: _addressTypeController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      country: _countryController.text.trim(),
      pincode: _pincodeController.text.trim(),
      phoneNo: _phoneController.text.trim(),
      fax: _faxController.text.trim(),
      profileId: widget.profileId,
      groupId: widget.groupId,
    );

    if (!mounted) return;
    CommonLoader.dismiss(context);

    if (success) {
      CommonToast.success(context, 'Address updated successfully');
      Navigator.of(context).pop(true);
    } else {
      CommonToast.error(context, 'Failed to update address');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(
        title: widget.isEditing ? 'Edit Address' : 'Add Address',
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
              controller: _addressTypeController,
              label: 'Address Type',
              hint: 'e.g. Business, Residential',
            ),
            const SizedBox(height: 16),
            CommonTextField(
              controller: _addressController,
              label: 'Address',
              hint: 'Enter full address',
              maxLines: 3,
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
              controller: _countryController,
              label: 'Country',
              hint: 'Enter country',
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
              controller: _phoneController,
              label: 'Phone No',
              hint: 'Enter phone number',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            CommonTextField(
              controller: _faxController,
              label: 'Fax',
              hint: 'Enter fax number',
            ),
          ],
        ),
      ),
    );
  }
}
