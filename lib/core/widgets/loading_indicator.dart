import 'package:flutter/material.dart';
import 'package:food2/core/constants/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;
  final String? message;
  final TextStyle? messageStyle;
  final Axis direction;
  final double spacing;

  const LoadingIndicator({
    super.key,
    this.size = 24,
    this.color,
    this.strokeWidth = 2,
    this.message,
    this.messageStyle,
    this.direction = Axis.vertical,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primaryColor;
    final child = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: effectiveColor,
      ),
    );

    if (message == null) {
      return child;
    }

    if (direction == Axis.horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          SizedBox(width: spacing),
          Text(
            message!,
            style: messageStyle ??
                TextStyle(
                  color: effectiveColor,
                  fontSize: 14,
                ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        SizedBox(height: spacing),
        Text(
          message!,
          style: messageStyle ??
              TextStyle(
                color: effectiveColor,
                fontSize: 14,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor ?? AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? backgroundColor;
  final Color? loadingColor;
  final bool dismissible;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.backgroundColor,
    this.loadingColor,
    this.dismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          ModalBarrier(
            dismissible: dismissible,
            color: backgroundColor ?? Colors.black.withOpacity(0.5),
          ),
        if (isLoading)
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LoadingIndicator(
                    size: 32,
                    color: loadingColor ?? AppColors.primaryColor,
                    strokeWidth: 3,
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class PageLoadingIndicator extends StatelessWidget {
  final String? message;
  final EdgeInsetsGeometry padding;

  const PageLoadingIndicator({
    super.key,
    this.message,
    this.padding = const EdgeInsets.all(32),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingIndicator(
              size: 48,
              strokeWidth: 3,
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SkeletonLoader extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final Axis scrollDirection;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const SkeletonLoader({
    super.key,
    this.itemCount = 3,
    required this.itemBuilder,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = true,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: scrollDirection,
      shrinkWrap: shrinkWrap,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}