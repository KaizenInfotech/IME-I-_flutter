import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Replaces iOS 4 separate UITextFields (OTPField1–4) with auto-focus.
/// Each box accepts a single digit and automatically advances to the next.
/// On completing the last digit, calls [onCompleted] with the full OTP string.
class OtpInputField extends StatefulWidget {
  const OtpInputField({
    super.key,
    this.length = 4,
    this.onCompleted,
    this.onChanged,
  });

  /// Number of OTP digits (iOS uses 4).
  final int length;

  /// Called when all digits are filled.
  final ValueChanged<String>? onCompleted;

  /// Called on every digit change.
  final ValueChanged<String>? onChanged;

  @override
  State<OtpInputField> createState() => OtpInputFieldState();
}

class OtpInputFieldState extends State<OtpInputField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  /// Get the current OTP string.
  String get otp => _controllers.map((c) => c.text).join();

  /// Clear all fields and focus the first one (iOS: clears all 4 fields).
  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    if (_focusNodes.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }
    setState(() {});
  }

  void _onChanged(int index, String value) {
    if (value.length == 1 && index < widget.length - 1) {
      // iOS: textFieldDidChange1–3 advance to next field
      _focusNodes[index + 1].requestFocus();
    }

    if (value.length == 1 && index == widget.length - 1) {
      // iOS: textFieldDidChange4 triggers NextButtonAction and resigns
      _focusNodes[index].unfocus();
      final otpValue = otp;
      widget.onCompleted?.call(otpValue);
    }

    widget.onChanged?.call(otp);
    setState(() {});
  }

  /// iOS: textFieldDidBeginEditing — tapping any filled field clears all and
  /// refocuses field 1.
  void _onTap(int index) {
    final hasValue = _controllers[index].text.isNotEmpty;
    if (hasValue) {
      clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (index) {
        return Container(
          width: 50,
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            border: Border.all(
              color: _controllers[index].text.isNotEmpty
                  ? AppColors.primary
                  : AppColors.gray,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: AppTextStyles.heading3,
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) => _onChanged(index, value),
            onTap: () => _onTap(index),
          ),
        );
      }),
    );
  }
}
