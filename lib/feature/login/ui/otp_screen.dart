import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:ysr_reg_incident/feature/login/repo/login_api.dart';
import 'package:ysr_reg_incident/feature/signup/ui/signup_screen.dart';
import 'package:ysr_reg_incident/services/dio_provider.dart';
import 'package:ysr_reg_incident/utils/reg_background_theme.dart';
import 'package:ysr_reg_incident/utils/reg_buttons.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String number;
  const OtpScreen({super.key, required this.number});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());

  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  bool _allFieldsValid = false;

  Timer? _timer;
  int _secondsRemaining = 60;

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() {
          _allFieldsValid = false;
        });
        timer.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    _allFieldsValid = _controllers.every((element) => element.text.isNotEmpty);
    setState(() {});
  }

  String getOtpString() {
    return _controllers.map((controller) => controller.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return RegBackgroundTheme(
      showBackButton: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type a Verification Code that we have sent',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            Gap(10),
            Text(
              'Enter your Verification Code below.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            Gap(30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  height: 40,
                  width: 50,
                  child: TextField(
                    cursorHeight: 20,
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(vertical: 5),
                      counterText: "",
                    ),
                    onChanged: (value) => _onChanged(value, index),
                  ),
                );
              }),
            ),
            SizedBox(height: 40),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Didn\'t receive the OTP?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  Gap(4),
                  InkWell(
                    onTap: () async {
                      _timer?.cancel();

                      _secondsRemaining = 60;
                      _startTimer();
                      _controllers.forEach((element) => element.clear());
                      getOtp(context, ref);
                    },
                    child: Text(
                      'Resend',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Gap(4),
                  Text(
                    _secondsRemaining > 0
                        ? ' 00:${_secondsRemaining.toString().padLeft(2, '0')}'
                        : '',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Gap(40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RegButton(
                    isEnabled: _allFieldsValid,
                    onPressed: _allFieldsValid
                        ? () {
                            verifyOtp(context, ref);
                          }
                        : null,
                    child: Text(
                      "Verify OTP",
                      style: TextStyle(
                        color: _allFieldsValid ? Colors.white : Colors.white,
                      ),
                    )),
              ],
            ),
            Gap(100)
          ],
        ),
      ),
    );
  }

  void verifyOtp(BuildContext context, WidgetRef ref) {
    EasyLoading.show();
    LoginApi(ref.read(dioProvider))
        .verifyOtpIncident(mobile: widget.number, otp: getOtpString())
        .then((value) {
      ref.read(mobileNumberProvider.notifier).state = widget.number;
      showSuccessDialog(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Otp verified scuccessfully"),
      ));

      EasyLoading.dismiss();
    }).onError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.toString()),
      ));
      EasyLoading.dismiss();
    });
  }

  void getOtp(BuildContext context, WidgetRef ref) {
    EasyLoading.show();
    LoginApi(ref.read(dioProvider))
        .generateOtpIncident(mobile: widget.number)
        .then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("otp Sent scuccessfully"),
      ));
    }).onError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.toString()),
      ));
    }).whenComplete(() {
      EasyLoading.dismiss();
    });
  }

  void showSuccessDialog(BuildContext context) {
    EasyLoading.dismiss();
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing manually
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 50)
                    .animate()
                    .scale()
                    .then()
                    .shimmer(),
                SizedBox(height: 10),
                Text(
                  textAlign: TextAlign.center,
                  "Mobile Number Verified Successfully",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Wait for 2 seconds and navigate to next screen
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context); // Close dialog
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignupScreen()),
      );
    });
  }
}

final mobileNumberProvider = StateProvider<String>((ref) {
  return '';
});
