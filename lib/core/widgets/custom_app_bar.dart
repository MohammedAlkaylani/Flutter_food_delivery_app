import 'package:flutter/material.dart';
import 'package:food2/core/constants/app_colors.dart';
import 'package:food2/core/constants/app_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;
  final double? titleSpacing;
  final double toolbarHeight;
  final TextStyle? titleStyle;
  final VoidCallback? onBackPressed;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.elevation = 0,
    this.backgroundColor,
    this.foregroundColor,
    this.automaticallyImplyLeading = true,
    this.bottom,
    this.titleSpacing,
    this.toolbarHeight = 56,
    this.titleStyle,
    this.onBackPressed,
    this.showBackButton = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(
    toolbarHeight + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor =
        backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor;
    final effectiveForegroundColor =
        foregroundColor ?? Theme.of(context).appBarTheme.foregroundColor;

    return AppBar(
      title: titleWidget ??
          (title != null
              ? Text(
            title!,
            style: titleStyle ??
                AppStyles.headlineSmall.copyWith(
                  color: effectiveForegroundColor,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
              : null),
      leading: leading ??
          (showBackButton && Navigator.of(context).canPop()
              ? IconButton(
            onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_rounded,
              color: effectiveForegroundColor,
            ),
          )
              : null),
      actions: actions,
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: effectiveForegroundColor,
      automaticallyImplyLeading: automaticallyImplyLeading,
      bottom: bottom,
      titleSpacing: titleSpacing,
      toolbarHeight: toolbarHeight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
    );
  }
}

class TransparentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? iconColor;

  const TransparentAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.iconColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleWidget ??
          (title != null
              ? Text(
            title!,
            style: AppStyles.headlineSmall.copyWith(color: Colors.white),
          )
              : null),
      leading: leading ??
          (showBackButton && Navigator.of(context).canPop()
              ? IconButton(
            onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_rounded,
              color: iconColor ?? Colors.white,
            ),
          )
              : null),
      actions: actions,
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: iconColor ?? Colors.white),
    );
  }
}

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSearch;
  final VoidCallback? onBack;
  final String hint;
  final List<Widget>? actions;

  const SearchAppBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSearch,
    this.onBack,
    this.hint = 'Search...',
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: onBack ?? () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: (_) => onSearch?.call(),
        autofocus: true,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          hintStyle: AppStyles.bodyMedium.copyWith(
            color: AppColors.textDisabled,
          ),
        ),
        style: AppStyles.bodyLarge,
      ),
      actions: actions,
      elevation: 0,
    );
  }
}