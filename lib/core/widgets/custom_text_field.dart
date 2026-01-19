import 'package:flutter/material.dart';
import 'package:food2/core/constants/app_colors.dart';
import 'package:food2/core/constants/app_styles.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final String? prefixText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? suffixText;
  final String? errorText;
  final String? helperText;
  final bool isRequired;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;
  final bool autoFocus;
  final EdgeInsetsGeometry? contentPadding;
  final InputDecoration? decoration;
  final TextStyle? style;
  final TextAlign textAlign;
  final bool expands;
  final TextAlignVertical? textAlignVertical;
  final bool showCounter;
  final AutovalidateMode? autovalidateMode;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.initialValue,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixText,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixText,
    this.errorText,
    this.helperText,
    this.isRequired = false,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
    this.autoFocus = false,
    this.contentPadding,
    this.decoration,
    this.style,
    this.textAlign = TextAlign.start,
    this.expands = false,
    this.textAlignVertical,
    this.showCounter = false,
    this.autovalidateMode,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;
  bool _isObscured = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveDecoration = widget.decoration ??
        InputDecoration(
          labelText: widget.label != null
              ? '${widget.label}${widget.isRequired ? ' *' : ''}'
              : null,
          hintText: widget.hint,
          prefixIcon: widget.prefixIcon,
          prefixText: widget.prefixText,
          suffixIcon: _buildSuffixIcon(),
          suffixText: widget.suffixText,
          errorText: widget.errorText,
          helperText: widget.helperText,
          counterText: widget.showCounter && widget.maxLength != null
              ? '${_controller.text.length}/${widget.maxLength}'
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.errorColor, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.errorColor, width: 1.5),
          ),
          filled: true,
          fillColor: widget.enabled
              ? AppColors.backgroundColor
              : AppColors.backgroundColor.withOpacity(0.5),
          contentPadding: widget.contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: AppStyles.titleMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          hintStyle: AppStyles.bodyMedium.copyWith(
            color: AppColors.textDisabled,
          ),
          errorStyle: AppStyles.bodySmall.copyWith(
            color: AppColors.errorColor,
          ),
          helperStyle: AppStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          counterStyle: AppStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null && widget.decoration?.labelText == null) ...[
          RichText(
            text: TextSpan(
              text: widget.label,
              style: AppStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              children: widget.isRequired
                  ? [
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: AppColors.errorColor,
                  ),
                ),
              ]
                  : null,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: _controller,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: _isObscured,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          validator: widget.validator,
          textCapitalization: widget.textCapitalization,
          autofocus: widget.autoFocus,
          style: widget.style ??
              AppStyles.bodyLarge.copyWith(
                color: widget.enabled
                    ? AppColors.textPrimary
                    : AppColors.textDisabled,
              ),
          textAlign: widget.textAlign,
          expands: widget.expands,
          textAlignVertical: widget.textAlignVertical,
          autovalidateMode: widget.autovalidateMode,
          decoration: effectiveDecoration,
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        onPressed: () {
          setState(() {
            _isObscured = !_isObscured;
          });
        },
        icon: Icon(
          _isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColors.textSecondary,
        ),
      );
    }
    return widget.suffixIcon;
  }
}

class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSearch;
  final VoidCallback? onFilter;
  final bool showFilter;

  const SearchTextField({
    super.key,
    required this.controller,
    this.hint = 'Search...',
    this.onChanged,
    this.onSearch,
    this.onFilter,
    this.showFilter = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: (_) => onSearch?.call(),
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                hintStyle: AppStyles.bodyMedium.copyWith(
                  color: AppColors.textDisabled,
                ),
              ),
              style: AppStyles.bodyLarge,
            ),
          ),
          if (showFilter && onFilter != null) ...[
            const VerticalDivider(
              color: AppColors.borderColor,
              thickness: 1,
              width: 1,
              indent: 12,
              endIndent: 12,
            ),
            IconButton(
              onPressed: onFilter,
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.filter_list_rounded,
                  size: 20,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}