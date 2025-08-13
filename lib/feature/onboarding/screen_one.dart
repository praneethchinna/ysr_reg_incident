import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:ysr_reg_incident/app_colors/app_colors.dart';
import 'package:ysr_reg_incident/feature/incident_registration/ui/incident_home_page.dart';
import 'package:ysr_reg_incident/feature/onboarding/screen_two.dart';
import 'package:ysr_reg_incident/feature/onboarding/video_screen.dart';
import 'package:ysr_reg_incident/widgets/language_selector.dart';

class ScreenOne extends StatefulWidget {
  final bool isUserVerified;
  const ScreenOne({super.key, this.isUserVerified = false});

  @override
  State<ScreenOne> createState() => _ScreenOneState();
}

class _ScreenOneState extends State<ScreenOne> {
  // final scrollController = ScrollController();

  // @override
  // void initState() {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     Future.delayed(Duration(milliseconds: 100), () {
  //       scrollController.animateTo(
  //         scrollController.position.maxScrollExtent,
  //         duration: Duration(seconds: 3),
  //         curve: Curves.easeOut,
  //       );
  //     });
  //   });
  //   super.initState();
  // }

  // @override
  // void dispose() {
  //   scrollController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    context.locale;
    return SafeArea(
      child: Container(
        alignment: Alignment.bottomRight,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/jagan_digital_library.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoScreen(
                          videoPath: "assets/videos/jagan_digital_library.mp4",
                          isUserVerified: widget.isUserVerified,
                        ),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        "Next",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward)
                    ],
                  )),
            ),
            Gap(20),
          ],
        ),
      ),
    );
  }
}
