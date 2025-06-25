import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:ysr_reg_incident/feature/login/repo/login_api.dart';
import 'package:ysr_reg_incident/feature/login/ui/otp_screen.dart';
import 'package:ysr_reg_incident/services/dio_provider.dart';
import 'package:ysr_reg_incident/utils/reg_background_theme.dart';
import 'package:ysr_reg_incident/utils/reg_buttons.dart';

class ValidateOtpScreen extends ConsumerStatefulWidget {
  const ValidateOtpScreen({super.key});

  @override
  _ValidateOtpScreenState createState() => _ValidateOtpScreenState();
}

class _ValidateOtpScreenState extends ConsumerState<ValidateOtpScreen> {
  final phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return RegBackgroundTheme(
        showBackButton: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Gap(40),
              buildPhoneNumberField(context, ref),
              Gap(MediaQuery.of(context).size.height / 2)
            ],
          ),
        ));
  }

  Widget buildPhoneNumberField(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(
              "Type Your Phone Number",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 17,
              ),
            ),
            Spacer()
          ],
        ),
        Gap(20),
        TextField(
          maxLength: 10,
          controller: phoneNumberController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            contentPadding:
                EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
            hintStyle: TextStyle(
                color: Colors.grey, fontWeight: FontWeight.w400, fontSize: 11),
            hintText: 'Enter your phone number',
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        Gap(20),
        RegButton(
          onPressed: () {
            if (phoneNumberController.text.length < 10) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Please enter a valid phone number"),
              ));
              return;
            }
            getNewUserOtp(context, ref);
          },
          child: Text("Send OTP",
              style: TextStyle(
                color: Colors.white,
              )),
        ),
      ],
    );
  }

  void getNewUserOtp(BuildContext context, WidgetRef ref) {
    EasyLoading.show();
    LoginApi(ref.read(dioProvider))
        .generateOtpIncident(mobile: phoneNumberController.text)
        .then((value) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("otp Sent scuccessfully"),
      ));
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(number: phoneNumberController.text),
          ));
    }).onError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(error.toString()),
        ),
      );
    }).whenComplete(() {
      EasyLoading.dismiss();
    });
  }


}
