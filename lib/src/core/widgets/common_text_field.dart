import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Replaces iOS UITextField with bottom border styling.
/// Port of functionForSetTextFieldBottomBorder, functionTextFieldFullBorder, etc.
class CommonTextField extends StatelessWidget {
  const CommonTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode,
    this.useBorderStyle = false,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FocusNode? focusNode;

  /// false = underline border (default, matching iOS bottom border).
  /// true = outline border (matching iOS functionTextFieldFullBorder).
  final bool useBorderStyle;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      style: AppTextStyles.input,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      onTap: onTap,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: AppTextStyles.inputHint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        // iOS: bottom border = UnderlineInputBorder with 204/255 gray
        // iOS: full border = OutlineInputBorder with lightGray
        border: useBorderStyle
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: AppColors.border),
              )
            : const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.border),
              ),
        enabledBorder: useBorderStyle
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: AppColors.border),
              )
            : const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.border),
              ),
        focusedBorder: useBorderStyle
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              )
            : const UnderlineInputBorder(
                // iOS: functionForSetTextFieldBottomBorderWhenEditing
                // orange-red: 250/255, 104/255, 67/255
                borderSide: BorderSide(color: AppColors.orangeRed, width: 1),
              ),
        errorBorder: useBorderStyle
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: AppColors.systemRed),
              )
            : const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.systemRed),
              ),
      ),
    );
  }
}
