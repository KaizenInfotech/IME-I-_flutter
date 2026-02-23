import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Country model for the picker.
class CountryCode {
  final String name;
  final String dialCode;

  const CountryCode({required this.name, required this.dialCode});
}

/// Replaces iOS UIPickerView for country code selection.
/// Shows a bottom sheet with searchable list of countries.
/// Data matches iOS CountyCodes.plist exactly.
class CountryCodePicker extends StatefulWidget {
  const CountryCodePicker({
    super.key,
    this.onSelected,
    this.selectedCountry,
  });

  final ValueChanged<CountryCode>? onSelected;
  final CountryCode? selectedCountry;

  /// Show as a bottom sheet (replaces iOS UIPickerView overlay).
  static Future<CountryCode?> show(BuildContext context) {
    return showModalBottomSheet<CountryCode>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => _CountryListSheet(
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  State<CountryCodePicker> createState() => _CountryCodePickerState();
}

class _CountryCodePickerState extends State<CountryCodePicker> {
  @override
  Widget build(BuildContext context) {
    final country = widget.selectedCountry ?? _defaultCountry;
    return GestureDetector(
      onTap: () async {
        final selected = await CountryCodePicker.show(context);
        if (selected != null) {
          widget.onSelected?.call(selected);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                country.name,
                style: AppTextStyles.body2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              country.dialCode,
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet with search and country list.
class _CountryListSheet extends StatefulWidget {
  const _CountryListSheet({required this.scrollController});

  final ScrollController scrollController;

  @override
  State<_CountryListSheet> createState() => _CountryListSheetState();
}

class _CountryListSheetState extends State<_CountryListSheet> {
  final _searchController = TextEditingController();
  List<CountryCode> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = countryCodes;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = countryCodes;
      } else {
        final q = query.toLowerCase();
        _filtered = countryCodes
            .where((c) =>
                c.name.toLowerCase().contains(q) || c.dialCode.contains(q))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle bar
        Container(
          margin: const EdgeInsets.only(top: 8),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.grayMedium,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Title
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Select Country',
            style: AppTextStyles.heading5,
          ),
        ),
        // Search field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearch,
            decoration: InputDecoration(
              hintText: 'Search country...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Country list
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            itemCount: _filtered.length,
            itemBuilder: (context, index) {
              final country = _filtered[index];
              return ListTile(
                title: Text(country.name, style: AppTextStyles.body2),
                trailing: Text(
                  country.dialCode,
                  style: AppTextStyles.body3.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                onTap: () => Navigator.of(context).pop(country),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Default country: India (matching iOS default).
const CountryCode _defaultCountry =
    CountryCode(name: 'India', dialCode: '+91');

/// Default country getter for external use.
CountryCode get defaultCountryCode => _defaultCountry;

/// Country codes data matching iOS CountyCodes.plist exactly.
const List<CountryCode> countryCodes = [
  CountryCode(name: 'Abkhazia', dialCode: '+7 840'),
  CountryCode(name: 'Afghanistan', dialCode: '+93'),
  CountryCode(name: 'Albania', dialCode: '+355'),
  CountryCode(name: 'Algeria', dialCode: '+213'),
  CountryCode(name: 'American Samoa', dialCode: '+1 684'),
  CountryCode(name: 'Andorra', dialCode: '+376'),
  CountryCode(name: 'Angola', dialCode: '+244'),
  CountryCode(name: 'Anguilla', dialCode: '+1 264'),
  CountryCode(name: 'Antigua and Barbuda', dialCode: '+1 268'),
  CountryCode(name: 'Argentina', dialCode: '+54'),
  CountryCode(name: 'Armenia', dialCode: '+374'),
  CountryCode(name: 'Aruba', dialCode: '+297'),
  CountryCode(name: 'Ascension', dialCode: '+247'),
  CountryCode(name: 'Australia', dialCode: '+61'),
  CountryCode(name: 'Australian External Territories', dialCode: '+672'),
  CountryCode(name: 'Austria', dialCode: '+43'),
  CountryCode(name: 'Azerbaijan', dialCode: '+994'),
  CountryCode(name: 'Bahamas', dialCode: '+1 242'),
  CountryCode(name: 'Bahrain', dialCode: '+973'),
  CountryCode(name: 'Bangladesh', dialCode: '+880'),
  CountryCode(name: 'Barbados', dialCode: '+1 246'),
  CountryCode(name: 'Barbuda', dialCode: '+1 268'),
  CountryCode(name: 'Belarus', dialCode: '+375'),
  CountryCode(name: 'Belgium', dialCode: '+32'),
  CountryCode(name: 'Belize', dialCode: '+501'),
  CountryCode(name: 'Benin', dialCode: '+229'),
  CountryCode(name: 'Bermuda', dialCode: '+1 441'),
  CountryCode(name: 'Bhutan', dialCode: '+975'),
  CountryCode(name: 'Bolivia', dialCode: '+591'),
  CountryCode(name: 'Bosnia and Herzegovina', dialCode: '+387'),
  CountryCode(name: 'Botswana', dialCode: '+267'),
  CountryCode(name: 'Brazil', dialCode: '+55'),
  CountryCode(name: 'Brunei', dialCode: '+673'),
  CountryCode(name: 'Bulgaria', dialCode: '+359'),
  CountryCode(name: 'Burkina Faso', dialCode: '+226'),
  CountryCode(name: 'Burundi', dialCode: '+257'),
  CountryCode(name: 'Cambodia', dialCode: '+855'),
  CountryCode(name: 'Cameroon', dialCode: '+237'),
  CountryCode(name: 'Canada', dialCode: '+1'),
  CountryCode(name: 'Cape Verde', dialCode: '+238'),
  CountryCode(name: 'Cayman Islands', dialCode: '+1 345'),
  CountryCode(name: 'Central African Republic', dialCode: '+236'),
  CountryCode(name: 'Chad', dialCode: '+235'),
  CountryCode(name: 'Chile', dialCode: '+56'),
  CountryCode(name: 'China', dialCode: '+86'),
  CountryCode(name: 'Colombia', dialCode: '+57'),
  CountryCode(name: 'Congo', dialCode: '+242'),
  CountryCode(name: 'Costa Rica', dialCode: '+506'),
  CountryCode(name: 'Croatia', dialCode: '+385'),
  CountryCode(name: 'Cuba', dialCode: '+53'),
  CountryCode(name: 'Cyprus', dialCode: '+357'),
  CountryCode(name: 'Czech Republic', dialCode: '+420'),
  CountryCode(name: 'Denmark', dialCode: '+45'),
  CountryCode(name: 'Djibouti', dialCode: '+253'),
  CountryCode(name: 'Dominica', dialCode: '+1 767'),
  CountryCode(name: 'Dominican Republic', dialCode: '+1 809'),
  CountryCode(name: 'Ecuador', dialCode: '+593'),
  CountryCode(name: 'Egypt', dialCode: '+20'),
  CountryCode(name: 'El Salvador', dialCode: '+503'),
  CountryCode(name: 'Equatorial Guinea', dialCode: '+240'),
  CountryCode(name: 'Eritrea', dialCode: '+291'),
  CountryCode(name: 'Estonia', dialCode: '+372'),
  CountryCode(name: 'Ethiopia', dialCode: '+251'),
  CountryCode(name: 'Fiji', dialCode: '+679'),
  CountryCode(name: 'Finland', dialCode: '+358'),
  CountryCode(name: 'France', dialCode: '+33'),
  CountryCode(name: 'Gabon', dialCode: '+241'),
  CountryCode(name: 'Gambia', dialCode: '+220'),
  CountryCode(name: 'Georgia', dialCode: '+995'),
  CountryCode(name: 'Germany', dialCode: '+49'),
  CountryCode(name: 'Ghana', dialCode: '+233'),
  CountryCode(name: 'Greece', dialCode: '+30'),
  CountryCode(name: 'Grenada', dialCode: '+1 473'),
  CountryCode(name: 'Guatemala', dialCode: '+502'),
  CountryCode(name: 'Guinea', dialCode: '+224'),
  CountryCode(name: 'Guyana', dialCode: '+592'),
  CountryCode(name: 'Haiti', dialCode: '+509'),
  CountryCode(name: 'Honduras', dialCode: '+504'),
  CountryCode(name: 'Hong Kong', dialCode: '+852'),
  CountryCode(name: 'Hungary', dialCode: '+36'),
  CountryCode(name: 'Iceland', dialCode: '+354'),
  CountryCode(name: 'India', dialCode: '+91'),
  CountryCode(name: 'Indonesia', dialCode: '+62'),
  CountryCode(name: 'Iran', dialCode: '+98'),
  CountryCode(name: 'Iraq', dialCode: '+964'),
  CountryCode(name: 'Ireland', dialCode: '+353'),
  CountryCode(name: 'Israel', dialCode: '+972'),
  CountryCode(name: 'Italy', dialCode: '+39'),
  CountryCode(name: 'Ivory Coast', dialCode: '+225'),
  CountryCode(name: 'Jamaica', dialCode: '+1 876'),
  CountryCode(name: 'Japan', dialCode: '+81'),
  CountryCode(name: 'Jordan', dialCode: '+962'),
  CountryCode(name: 'Kazakhstan', dialCode: '+7'),
  CountryCode(name: 'Kenya', dialCode: '+254'),
  CountryCode(name: 'Kuwait', dialCode: '+965'),
  CountryCode(name: 'Kyrgyzstan', dialCode: '+996'),
  CountryCode(name: 'Laos', dialCode: '+856'),
  CountryCode(name: 'Latvia', dialCode: '+371'),
  CountryCode(name: 'Lebanon', dialCode: '+961'),
  CountryCode(name: 'Liberia', dialCode: '+231'),
  CountryCode(name: 'Libya', dialCode: '+218'),
  CountryCode(name: 'Lithuania', dialCode: '+370'),
  CountryCode(name: 'Luxembourg', dialCode: '+352'),
  CountryCode(name: 'Madagascar', dialCode: '+261'),
  CountryCode(name: 'Malawi', dialCode: '+265'),
  CountryCode(name: 'Malaysia', dialCode: '+60'),
  CountryCode(name: 'Maldives', dialCode: '+960'),
  CountryCode(name: 'Mali', dialCode: '+223'),
  CountryCode(name: 'Malta', dialCode: '+356'),
  CountryCode(name: 'Mauritania', dialCode: '+222'),
  CountryCode(name: 'Mauritius', dialCode: '+230'),
  CountryCode(name: 'Mexico', dialCode: '+52'),
  CountryCode(name: 'Moldova', dialCode: '+373'),
  CountryCode(name: 'Monaco', dialCode: '+377'),
  CountryCode(name: 'Mongolia', dialCode: '+976'),
  CountryCode(name: 'Montenegro', dialCode: '+382'),
  CountryCode(name: 'Morocco', dialCode: '+212'),
  CountryCode(name: 'Mozambique', dialCode: '+258'),
  CountryCode(name: 'Myanmar', dialCode: '+95'),
  CountryCode(name: 'Namibia', dialCode: '+264'),
  CountryCode(name: 'Nepal', dialCode: '+977'),
  CountryCode(name: 'Netherlands', dialCode: '+31'),
  CountryCode(name: 'New Zealand', dialCode: '+64'),
  CountryCode(name: 'Nicaragua', dialCode: '+505'),
  CountryCode(name: 'Niger', dialCode: '+227'),
  CountryCode(name: 'Nigeria', dialCode: '+234'),
  CountryCode(name: 'North Korea', dialCode: '+850'),
  CountryCode(name: 'Norway', dialCode: '+47'),
  CountryCode(name: 'Oman', dialCode: '+968'),
  CountryCode(name: 'Pakistan', dialCode: '+92'),
  CountryCode(name: 'Palestine', dialCode: '+970'),
  CountryCode(name: 'Panama', dialCode: '+507'),
  CountryCode(name: 'Papua New Guinea', dialCode: '+675'),
  CountryCode(name: 'Paraguay', dialCode: '+595'),
  CountryCode(name: 'Peru', dialCode: '+51'),
  CountryCode(name: 'Philippines', dialCode: '+63'),
  CountryCode(name: 'Poland', dialCode: '+48'),
  CountryCode(name: 'Portugal', dialCode: '+351'),
  CountryCode(name: 'Qatar', dialCode: '+974'),
  CountryCode(name: 'Romania', dialCode: '+40'),
  CountryCode(name: 'Russia', dialCode: '+7'),
  CountryCode(name: 'Rwanda', dialCode: '+250'),
  CountryCode(name: 'Saudi Arabia', dialCode: '+966'),
  CountryCode(name: 'Senegal', dialCode: '+221'),
  CountryCode(name: 'Serbia', dialCode: '+381'),
  CountryCode(name: 'Sierra Leone', dialCode: '+232'),
  CountryCode(name: 'Singapore', dialCode: '+65'),
  CountryCode(name: 'Slovakia', dialCode: '+421'),
  CountryCode(name: 'Slovenia', dialCode: '+386'),
  CountryCode(name: 'Somalia', dialCode: '+252'),
  CountryCode(name: 'South Africa', dialCode: '+27'),
  CountryCode(name: 'South Korea', dialCode: '+82'),
  CountryCode(name: 'Spain', dialCode: '+34'),
  CountryCode(name: 'Sri Lanka', dialCode: '+94'),
  CountryCode(name: 'Sudan', dialCode: '+249'),
  CountryCode(name: 'Suriname', dialCode: '+597'),
  CountryCode(name: 'Sweden', dialCode: '+46'),
  CountryCode(name: 'Switzerland', dialCode: '+41'),
  CountryCode(name: 'Syria', dialCode: '+963'),
  CountryCode(name: 'Taiwan', dialCode: '+886'),
  CountryCode(name: 'Tajikistan', dialCode: '+992'),
  CountryCode(name: 'Tanzania', dialCode: '+255'),
  CountryCode(name: 'Thailand', dialCode: '+66'),
  CountryCode(name: 'Togo', dialCode: '+228'),
  CountryCode(name: 'Trinidad and Tobago', dialCode: '+1 868'),
  CountryCode(name: 'Tunisia', dialCode: '+216'),
  CountryCode(name: 'Turkey', dialCode: '+90'),
  CountryCode(name: 'Turkmenistan', dialCode: '+993'),
  CountryCode(name: 'Uganda', dialCode: '+256'),
  CountryCode(name: 'Ukraine', dialCode: '+380'),
  CountryCode(name: 'United Arab Emirates', dialCode: '+971'),
  CountryCode(name: 'United Kingdom', dialCode: '+44'),
  CountryCode(name: 'United States', dialCode: '+1'),
  CountryCode(name: 'Uruguay', dialCode: '+598'),
  CountryCode(name: 'Uzbekistan', dialCode: '+998'),
  CountryCode(name: 'Venezuela', dialCode: '+58'),
  CountryCode(name: 'Vietnam', dialCode: '+84'),
  CountryCode(name: 'Yemen', dialCode: '+967'),
  CountryCode(name: 'Zambia', dialCode: '+260'),
  CountryCode(name: 'Zimbabwe', dialCode: '+263'),
];
