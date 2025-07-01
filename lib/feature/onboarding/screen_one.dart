import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:ysr_reg_incident/app_colors/app_colors.dart';
import 'package:ysr_reg_incident/feature/onboarding/screen_two.dart';
import 'package:ysr_reg_incident/widgets/language_selector.dart';

class ScreenOne extends StatefulWidget {
  const ScreenOne({super.key});

  @override
  State<ScreenOne> createState() => _ScreenOneState();
}

class _ScreenOneState extends State<ScreenOne> {
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
    context.locale;
    return Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.backgroundLightGrey,
              AppColors.backgroundLightGrey,
              Colors.white
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: 100),
                  Image.asset(
                    'assets/screen_1.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "speak_up".tr(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E1861),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(16),
                  Text(
                    'everyone_concern'.tr(),
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
                      minimumSize: Size(200, 50),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        width: 1,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'raise'.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF2E1861),
                            ),
                          ),
                          Gap(10),
                          Icon(Icons.arrow_forward,
                                  color: Color(0xFF2E1861), size: 18)
                              .animate(
                                  onPlay: (controller) => controller.repeat())
                              .shakeX(
                                duration:
                                    Duration(seconds: 1), // slower animation
                                hz: 1, // 2 shakes per second (default is 5)
                                amount: 8, // how far it moves in px (optional)
                              )
                        ],
                      ),
                    ),
                  ),
                  Gap(20),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40, right: 16.0),
                child: LanguageSelector(showLabel: false),
              ),
            ],
          ),
        ));
  }
}
