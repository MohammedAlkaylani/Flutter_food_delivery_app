import 'package:flutter/material.dart';
import 'package:food2/core/constants/app_colors.dart';
import 'package:food2/core/constants/app_styles.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final Widget? icon;
  final bool disabled;
  final double? width;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 56,
    this.borderRadius = 12,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.padding,
    this.textStyle,
    this.icon,
    this.disabled = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? AppColors.primaryColor;
    final effectiveTextColor = textColor ?? Colors.white;
    final effectiveBorderColor = borderColor ?? AppColors.primaryColor;

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        onPressed: (disabled || isLoading) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          foregroundColor: effectiveTextColor,
          disabledBackgroundColor: effectiveBackgroundColor.withOpacity(0.5),
          disabledForegroundColor: effectiveTextColor.withOpacity(0.5),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(
              color: disabled
                  ? effectiveBorderColor.withOpacity(0.5)
                  : effectiveBorderColor,
              width: borderColor != null ? 1.5 : 0,
            ),
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isLoading
            ? SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: effectiveTextColor,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: textStyle ??
                  AppStyles.titleLarge.copyWith(
                    color: effectiveTextColor,
                    fontWeight: FontWeight.w600,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomOutlineButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final double borderRadius;
  final Color? borderColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final Widget? icon;

  const CustomOutlineButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 56,
    this.borderRadius = 12,
    this.borderColor,
    this.textColor,
    this.padding,
    this.textStyle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? AppColors.primaryColor;
    final effectiveTextColor = textColor ?? AppColors.primaryColor;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveTextColor,
          side: BorderSide(
            color: effectiveBorderColor,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isLoading
            ? SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: effectiveTextColor,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: textStyle ??
                  AppStyles.titleLarge.copyWith(
                    color: effectiveTextColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color? textColor;
  final TextStyle? textStyle;
  final Widget? icon;
  final double? iconSpacing;

  const CustomTextButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.textColor,
    this.textStyle,
    this.icon,
    this.iconSpacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            SizedBox(width: iconSpacing),
          ],
          Text(
            text,
            style: textStyle ??
                AppStyles.labelLarge.copyWith(
                  color: textColor ?? AppColors.primaryColor,
                ),
          ),
        ],
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final BoxBorder? border;

  const CustomIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = 40,
    this.backgroundColor,
    this.iconColor,
    this.borderRadius = 12,
    this.padding,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: size * 0.5,
          color: iconColor ?? AppColors.primaryColor,
        ),
        padding: padding ?? EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}