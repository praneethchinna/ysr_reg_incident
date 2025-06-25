import 'package:flutter/material.dart';
import 'package:ysr_reg_incident/app_colors/app_colors.dart';

class RegAppBar extends StatelessWidget implements PreferredSizeWidget {
  // These properties directly map to AppBar's properties
  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;
  final bool? centerTitle; // Use nullable bool as AppBar's default can vary
  final double? elevation; // Use nullable double as AppBar's default can vary

  // Custom properties for this specific AppBar's styling
  final Gradient? gradient;
  final Color?
      defaultContentColor; // Color for title text, leading icon, and action icons

  const RegAppBar({
    super.key,
    this.leading,
    this.title,
    this.actions,
    this.centerTitle, // Pass directly to AppBar
    this.elevation, // Pass directly to AppBar
    this.gradient,
    this.defaultContentColor = Colors.black, // Default to white as per your UI
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // --- Standard AppBar properties ---
      leading: leading,
      // `automaticallyImplyLeading` is managed by AppBar internally.
      // If `leading` is null and can pop, it will show a back button.
      automaticallyImplyLeading: true,

      title: title, // Pass the title widget directly
      actions: actions, // Pass the list of action widgets directly
      centerTitle: centerTitle, // AppBar's internal logic handles centering
      elevation: elevation, // AppBar's internal logic handles shadow

      // --- Custom styling for the YsrAppBar ---
      // Make AppBar's own background transparent so the flexibleSpace gradient is visible
      backgroundColor: Colors.transparent,

      // Set the default color for text and icons within the AppBar
      foregroundColor: defaultContentColor,

      // Use flexibleSpace to add the custom gradient background
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient:
              gradient ?? // Use custom gradient if provided, otherwise default
                  const LinearGradient(
                    colors: [
                      AppColors.secondaryLightBlue,
                      AppColors.secondaryDarkBlue
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
        ),
      ),

      // If you need more specific control over icon themes (e.g., if you override
      // Theme.of(context).appBarTheme.iconTheme elsewhere), you can uncomment these:
      // iconTheme: IconThemeData(color: defaultContentColor), // Applies to leading icon
      // actionsIconTheme: IconThemeData(color: defaultContentColor), // Applies to icons in actions list
    );
  }
}
