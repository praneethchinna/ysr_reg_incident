import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ysr_reg_incident/app_colors/app_colors.dart';
import 'package:ysr_reg_incident/feature/onboarding/screen_three.dart';

class ScreenTwo extends StatefulWidget {
  const ScreenTwo({super.key});

  @override
  State<ScreenTwo> createState() => _ScreenTwoState();
}

class _ScreenTwoState extends State<ScreenTwo> {
  final scrollController = ScrollController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 100), () {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(seconds: 3),
          curve: Curves.easeOut,
        );
      });
    });
    super.initState();
  }
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.backgroundGrey,
              AppColors.backgroundGrey,
              Colors.white
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              SizedBox(height: 50),
              Image.asset(
                'assets/screen_2.png',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
              SizedBox(height: 20),
              Text(
                "with_you".tr(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E1861),
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(16),
              Text(
                'no_matter'.tr(),
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
                      builder: (context) => const ScreenThree(),
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
                        'how_it_works'.tr(),
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
