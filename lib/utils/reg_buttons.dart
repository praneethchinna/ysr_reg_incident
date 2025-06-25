import 'package:flutter/material.dart';
import 'package:ysr_reg_incident/app_colors/app_colors.dart';

class RegButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isEnabled;

  const
  RegButton({
    super.key,
    required this.child,
    this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 35,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
