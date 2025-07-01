import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:ysr_reg_incident/feature/login/repo/forgot_password_repo.dart';
import 'package:ysr_reg_incident/feature/login/repo/login_api.dart';
import 'package:ysr_reg_incident/feature/login/ui/validate_otp_screen.dart';
import 'package:ysr_reg_incident/services/dio_provider.dart';
import 'package:ysr_reg_incident/utils/reg_background_theme.dart';
import 'package:ysr_reg_incident/utils/reg_buttons.dart';
import 'package:easy_localization/easy_localization.dart';

class OtpScreen1 extends ConsumerStatefulWidget {
  final bool isNewUser;
  final String? phoneNumber;
  OtpScreen1({super.key, this.isNewUser = true, this.phoneNumber});

  @override
  _ValidateOtpScreenState createState() => _ValidateOtpScreenState();
}

class _ValidateOtpScreenState extends ConsumerState<OtpScreen1> {
  final phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.phoneNumber != null) {
      phoneNumberController.text = widget.phoneNumber!;
    }
  }

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
              "type_your_phone_number".tr(),
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
            hintText: 'enter_your_phone_number'.tr(),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        Gap(20),
        RegButton(
          onPressed: () {
            if (phoneNumberController.text.length < 10) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("enter_valid_phone_number".tr()),
              ));
              return;
            }
            if (widget.isNewUser) {
              getNewUserOtp(context, ref);
            } else {
              getOldUserOtp(context, ref);
            }
          },
          child: Text("send_otp".tr(),
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
        content: Text("otp_sent_successfully".tr()),
      ));
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ValidateOtpScreen(number: phoneNumberController.text),
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

  void getOldUserOtp(BuildContext context, WidgetRef ref) {
    EasyLoading.show();
    ForgotPasswordRepo(ref.read(dioProvider))
        .forgotPassword(phoneNumberController.text)
        .then((value) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("otp_sent_successfully".tr()),
      ));
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ValidateOtpScreen(
              number: phoneNumberController.text,
              isNewUser: false,
            ),
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
