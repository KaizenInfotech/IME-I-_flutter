import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_loader.dart';
import '../../../core/widgets/common_toast.dart';
import '../providers/auth_provider.dart';
import '../widgets/otp_input_field.dart';

/// Port of iOS OtpVerifyViewController.swift.
/// Blue ocean background, "Got Your Code?" title, OTP card, CODE inputs, Resend.
class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.mobileNumber,
    required this.countryCode,
    required this.loginType,
    this.otp,
  });

  final String mobileNumber;
  final String countryCode;
  final String loginType;
  final String? otp;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpFieldKey = GlobalKey<OtpInputFieldState>();

  /// iOS: count starts at 59, decrements every second.
  int _countdown = 59;
  Timer? _timer;

  /// Stored OTP from server (iOS: UserDefaults "OTP").
  String? _serverOtp;

  @override
  void initState() {
    super.initState();
    _serverOtp = widget.otp;
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// iOS: timer = NSTimer.scheduledTimerWithTimeInterval(1, ...)
  void _startCountdown() {
    _countdown = 59;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  /// iOS: CountDownTimerLable text format.
  String get _countdownText {
    if (_countdown <= 0) return '';
    final seconds = _countdown.toString().padLeft(2, '0');
    return 'You will receive the code within the next 00:$seconds seconds(s)';
  }

  /// iOS: NextButtonAction — validates OTP then calls OTPverify.
  void _onOtpCompleted(String otp) {
    _verifyOtp(otp);
  }

  Future<void> _verifyOtp(String enteredOtp) async {
    if (enteredOtp.length < 4) {
      _showAlert('Please enter OTP');
      return;
    }

    // iOS: validates OTP against stored value from UserDefaults
    if (_serverOtp != null && enteredOtp != _serverOtp) {
      _showAlert('Please enter a VALID Verification Code');
      _otpFieldKey.currentState?.clear();
      return;
    }

    // iOS: wsm.OTPverify(mobile, deviceTokenStr: "", countryCode: str!, loginType: LoginType)
    final authProvider = context.read<AuthProvider>();
    CommonLoader.show(context, message: 'Processing...');

    final success = await authProvider.verifyOtp(
      otp: enteredOtp,
      mobileNumber: widget.mobileNumber,
    );

    if (!mounted) return;
    CommonLoader.dismiss(context);

    if (success) {
      // Navigate directly to dashboard, clearing the navigation stack
      context.go('/dashboard');
    } else {
      final error = authProvider.error ?? 'Verification failed';
      CommonToast.error(context, error);
    }
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('IME(I)-iConnect'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// iOS: ResendOTPAction — re-calls signinTapped.
  Future<void> _resendOtp() async {
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.login(
      mobileNumber: widget.mobileNumber,
      countryCode: widget.countryCode,
      loginType: widget.loginType,
    );

    if (!mounted) return;

    if (success) {
      _serverOtp = authProvider.loginResult?.otp;
      _otpFieldKey.currentState?.clear();
      _startCountdown();
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
          child: Column(
            children: [
              // iOS: top bar with back button and "Got Your Code?" title
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    // Circular back button
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.textOnPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Got Your Code?',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // Scrollable content — adapts to small screens and keyboard
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // "OTP" header with purple bg
                          Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'OTP',
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
                            padding:
                                const EdgeInsets.fromLTRB(20, 20, 20, 24),
                            child: Column(
                              children: [
                                // "OTP Verification" in blue
                                const Text(
                                  'OTP Verification',
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Countdown timer text
                                if (_countdown > 0)
                                  Text(
                                    _countdownText,
                                    style: const TextStyle(
                                      fontFamily: AppTextStyles.fontFamily,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                const SizedBox(height: 16),
                                // Key icon above the OTP fields
                                const Icon(
                                  Icons.vpn_key,
                                  color: AppColors.textSecondary,
                                  size: 24,
                                ),
                                const SizedBox(height: 12),
                                // OTP input fields — responsive width via Expanded
                                OtpInputField(
                                  key: _otpFieldKey,
                                  length: 4,
                                  onCompleted: _onOtpCompleted,
                                ),
                                const SizedBox(height: 20),
                                // "Did not receive the SMS" text
                                const Text(
                                  'Did not receive the SMS',
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // "Resend" button with purple border
                                SizedBox(
                                  width: 140,
                                  height: 40,
                                  child: OutlinedButton(
                                    onPressed: _countdown <= 0
                                        ? _resendOtp
                                        : null,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: BorderSide(
                                        color: _countdown <= 0
                                            ? AppColors.primary
                                            : AppColors.grayMedium,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text(
                                      'Resend',
                                      style: TextStyle(
                                        fontFamily:
                                            AppTextStyles.fontFamily,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
