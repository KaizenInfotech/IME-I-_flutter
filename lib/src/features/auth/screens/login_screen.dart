import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_loader.dart';
import '../../../core/widgets/common_toast.dart';
import '../providers/auth_provider.dart';
import '../widgets/country_code_picker.dart';
import 'otp_screen.dart';

/// Port of iOS MobileLoginController.swift.
/// Blue ocean background, white LOGIN card, country picker, mobile field, Confirm button.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _mobileController = TextEditingController();
  CountryCode _selectedCountry = defaultCountryCode;

  /// iOS: Session_SelectedIndexValue — "0" = Member, "1" = Family.
  final int _selectedUserType = 0;

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  /// iOS: phoneNumberValidation — rejects if contains letters.
  bool _isValidMobile(String value) {
    if (value.isEmpty) return false;
    return !RegExp(r'[a-zA-Z]').hasMatch(value);
  }

  /// iOS: ProceedNextAction -> showAlert -> alertView confirm.
  void _onContinue() {
    final mobile = _mobileController.text.trim();

    if (mobile.isEmpty) {
      CommonToast.show(context, 'Please enter mobile number.');
      return;
    }

    if (!_isValidMobile(mobile)) {
      CommonToast.show(
          context, 'Please enter a valid mobile number.');
      return;
    }

    if (_selectedCountry.name.isEmpty) {
      CommonToast.show(context, 'Please select country.');
      return;
    }

    // iOS: UIAlertView with "Edit" and "Confirm" buttons.
    _showConfirmDialog(mobile);
  }

  void _showConfirmDialog(String mobile) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${_selectedCountry.dialCode} $mobile'),
        content:
            const Text('One Time Password will be sent to this number'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _performLogin(mobile);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogin(String mobile) async {
    final authProvider = context.read<AuthProvider>();
    CommonLoader.show(context, message: 'Processing...');

    final loginType = _selectedUserType.toString();
    final success = await authProvider.login(
      mobileNumber: mobile,
      countryCode: _selectedCountry.dialCode,
      loginType: loginType,
    );

    if (!mounted) return;
    CommonLoader.dismiss(context);

    if (success) {
      // iOS: push to otp_verify
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpScreen(
            mobileNumber: mobile,
            countryCode: _selectedCountry.dialCode,
            loginType: loginType,
            otp: authProvider.loginResult?.otp,
          ),
        ),
      );
    } else {
      // iOS: "Member not registered" toast
      final error = authProvider.error ?? 'Member not registered';
      CommonToast.error(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/imei_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // iOS: loginVieww with corner radius 15 and shadow
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // iOS: "LOGIN" header with purple bg
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'LOGIN',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textOnPrimary,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // "Select Country" label
                              const Text(
                                'Select Country',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Country picker row with checkmark
                              GestureDetector(
                                onTap: () async {
                                  final selected =
                                      await CountryCodePicker.show(context);
                                  if (selected != null) {
                                    setState(() {
                                      _selectedCountry = selected;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 12),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          color: AppColors.border, width: 1),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _selectedCountry.name,
                                          style: const TextStyle(
                                            fontFamily:
                                                AppTextStyles.fontFamily,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        color: AppColors.primary,
                                        size: 30,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // "Mobile No." label
                              const Text(
                                'Mobile No.',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Mobile number input with dial code prefix
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    _selectedCountry.dialCode,
                                    style: const TextStyle(
                                      fontFamily: AppTextStyles.fontFamily,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _mobileController,
                                      keyboardType: TextInputType.phone,
                                      maxLength: 20,
                                      style: const TextStyle(
                                        fontFamily: AppTextStyles.fontFamily,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.textPrimary,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: 'Your Mobile Number*',
                                        hintStyle: TextStyle(
                                          fontFamily: AppTextStyles.fontFamily,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.grayMedium,
                                        ),
                                        counterText: '',
                                        border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColors.border,
                                          ),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColors.border,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColors.border,
                                          ),
                                        ),
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 8),
                                        isDense: true,
                                      ),
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(20),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Blue "Confirm" button
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _onContinue,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.textOnPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: const Text(
                                    'Confirm',
                                    style: TextStyle(
                                      fontFamily: AppTextStyles.fontFamily,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textOnPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
