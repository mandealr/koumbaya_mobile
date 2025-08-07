import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

enum KoumbayaButtonType { primary, secondary, outline, text }

class KoumbayaButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final KoumbayaButtonType type;
  final bool isLoading;
  final Widget? icon;
  final bool fullWidth;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const KoumbayaButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = KoumbayaButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    this.width,
    this.padding,
  });

  const KoumbayaButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    this.width,
    this.padding,
  }) : type = KoumbayaButtonType.primary;

  const KoumbayaButton.secondary({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    this.width,
    this.padding,
  }) : type = KoumbayaButtonType.secondary;

  const KoumbayaButton.outline({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    this.width,
    this.padding,
  }) : type = KoumbayaButtonType.outline;

  const KoumbayaButton.text({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    this.width,
    this.padding,
  }) : type = KoumbayaButtonType.text;

  @override
  Widget build(BuildContext context) {
    Widget child = _buildButtonContent();
    
    switch (type) {
      case KoumbayaButtonType.primary:
        return _buildPrimaryButton(child);
      case KoumbayaButtonType.secondary:
        return _buildSecondaryButton(child);
      case KoumbayaButtonType.outline:
        return _buildOutlineButton(child);
      case KoumbayaButtonType.text:
        return _buildTextButton(child);
    }
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }

    return Text(text);
  }

  Widget _buildPrimaryButton(Widget child) {
    return SizedBox(
      width: fullWidth ? double.infinity : width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: AppConstants.elevationLow,
          shadowColor: AppConstants.primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: AppConstants.primaryFontFamily,
          ),
        ).copyWith(
          overlayColor: MaterialStateProperty.all(
            Colors.white.withOpacity(0.1),
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildSecondaryButton(Widget child) {
    return SizedBox(
      width: fullWidth ? double.infinity : width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.secondaryColor,
          foregroundColor: Colors.white,
          elevation: AppConstants.elevationLow,
          shadowColor: AppConstants.secondaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: AppConstants.primaryFontFamily,
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildOutlineButton(Widget child) {
    return SizedBox(
      width: fullWidth ? double.infinity : width,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.primaryColor,
          side: BorderSide(
            color: AppConstants.primaryColor,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: AppConstants.primaryFontFamily,
          ),
        ).copyWith(
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          overlayColor: MaterialStateProperty.all(
            AppConstants.primaryColor.withOpacity(0.05),
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildTextButton(Widget child) {
    return SizedBox(
      width: fullWidth ? double.infinity : width,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppConstants.primaryColor,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: AppConstants.primaryFontFamily,
          ),
        ).copyWith(
          overlayColor: MaterialStateProperty.all(
            AppConstants.primaryColor.withOpacity(0.05),
          ),
        ),
        child: child,
      ),
    );
  }
}