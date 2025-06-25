import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ysr_reg_incident/app_colors/app_colors.dart';

class RegBackgroundTheme extends StatelessWidget {
  final Widget child;
  final bool? showBackButton;
  const RegBackgroundTheme(
      {super.key, required this.child, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryLightBlue, Colors.white, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.only(bottom: 100), // Extra space for keyboard
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Gap(20),
              if (showBackButton!) ...[
                Gap(20),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Image.asset(
                          'assets/backbutton_icon.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                    Spacer()
                  ],
                ),
              ],
              Image.asset(
                'assets/background_theme.png',
                width: 250,
                height: 250,
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
