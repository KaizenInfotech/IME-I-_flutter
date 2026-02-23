import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Card displaying an address entry.
/// iOS: Address details from CommonAccessibleHoldVariable.varAddress_* fields.
class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    this.addressType = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.country = '',
    this.pincode = '',
    this.phoneNo = '',
    this.fax = '',
    this.onEdit,
  });

  final String addressType;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final String phoneNo;
  final String fax;
  final VoidCallback? onEdit;

  String get _formattedAddress {
    final parts = <String>[
      if (address.isNotEmpty) address,
      if (city.isNotEmpty) city,
      if (state.isNotEmpty) state,
      if (country.isNotEmpty) country,
      if (pincode.isNotEmpty) pincode,
    ];
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    addressType.isNotEmpty ? addressType : 'Address',
                    style: AppTextStyles.body2
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (onEdit != null)
                  GestureDetector(
                    onTap: onEdit,
                    child: const Icon(
                      Icons.edit,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
            if (_formattedAddress.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _formattedAddress,
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
            ],
            if (phoneNo.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.phone,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      phoneNo,
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
            ],
            if (fax.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.fax,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      fax,
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
