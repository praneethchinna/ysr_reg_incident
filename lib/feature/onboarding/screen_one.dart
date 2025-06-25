import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ysr_reg_incident/app_colors/app_colors.dart';
import 'package:ysr_reg_incident/feature/onboarding/screen_two.dart';

class ScreenOne extends StatelessWidget {
  const ScreenOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundLightGrey,AppColors.backgroundLightGrey, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 100),
              Image.asset(
                'assets/screen_1.png',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
              SizedBox(height: 20),
              Text(
                "Speak Up.\nWe’re Listening",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E1861),
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(16),
              Text(
                ''''“Everyone concern is important.\nRaise it securely and confidently.”''',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              Gap(40),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScreenTwo(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    width: 1,
                    color: Colors.grey.shade400,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Raise Your First Issue',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2E1861),
                        ),
                      ),
                      Gap(10),
                      Icon(Icons.arrow_forward,
                          color: Color(0xFF2E1861), size: 15),
                    ],
                  ),
                ),
              ),
              Gap(20),
            ],
          ),
        ));
  }
}
