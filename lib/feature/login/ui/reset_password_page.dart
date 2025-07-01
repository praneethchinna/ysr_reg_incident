import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ysr_reg_incident/feature/login/repo/forgot_password_repo.dart';
import 'package:ysr_reg_incident/feature/login/ui/login_ui.dart';
import 'package:ysr_reg_incident/services/dio_provider.dart';
import 'package:ysr_reg_incident/utils/reg_background_theme.dart';
import 'package:ysr_reg_incident/utils/reg_buttons.dart';

class ResetPassword extends ConsumerStatefulWidget {
  const ResetPassword(this.phoneNumber, {super.key});
  final String phoneNumber;

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends ConsumerState<ResetPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return RegBackgroundTheme(
      showBackButton: true,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
                    hintStyle: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                        fontSize: 11),
                    labelText: 'reset_password.new_password'.tr(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    )),
                obscureText: !_isPasswordVisible,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'reset_password.password_required'.tr();
                  }
                  if (value.length < 8) {
                    return 'reset_password.password_min_length'.tr();
                  }
                  return null;
                },
              ),
              Gap(40),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
                    hintStyle: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                        fontSize: 11),
                    labelText: 'reset_password.confirm_password'.tr(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    )),
                obscureText: !_isConfirmPasswordVisible,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'reset_password.confirm_password_required'.tr();
                  }
                  if (value != _passwordController.text) {
                    return 'reset_password.passwords_dont_match'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RegButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        EasyLoading.show();
                        ForgotPasswordRepo(ref.read(dioProvider))
                            .resetPassword(
                          widget
                              .phoneNumber, // Assuming mobile number is handled elsewhere
                          _passwordController.text,
                        )
                            .then((value) {
                          EasyLoading.dismiss();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('reset_password.reset_success'.tr()),
                          ));
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginUi(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        }).onError((error, stackTrace) {
                          EasyLoading.dismiss();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(error.toString()),
                          ));
                        });
                      }
                    },
                    child: Text(
                      'reset_password.reset_button'.tr(),
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
              Gap(500),
            ],
          ),
        ),
      ),
    );
  }
}
