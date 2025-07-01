import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:ysr_reg_incident/feature/incident_registration/ui/incident_home_page.dart';
import 'package:ysr_reg_incident/feature/login/repo/login_api.dart';
import 'package:ysr_reg_incident/feature/login/ui/otp_screen1.dart';
import 'package:ysr_reg_incident/services/dio_provider.dart';
import 'package:ysr_reg_incident/services/google_sign_in_helper.dart';
import 'package:ysr_reg_incident/services/shared_preferences.dart';
import 'package:ysr_reg_incident/utils/reg_background_theme.dart';
import 'package:ysr_reg_incident/utils/reg_buttons.dart';
import 'package:ysr_reg_incident/utils/show_error_dialog.dart';
import 'package:ysr_reg_incident/widgets/language_selector.dart';

class LoginUi extends ConsumerStatefulWidget {
  const LoginUi({super.key});

  @override
  ConsumerState<LoginUi> createState() => _LoginUiState();
}

class _LoginUiState extends ConsumerState<LoginUi> {
  UserCredential? userCredential;
  bool _isPasswordVisible = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    context.locale;
    return RegBackgroundTheme(
        showBackButton: false,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Language selector at top right
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 16.0),
                  child: LanguageSelector(showLabel: false),
                ),
              ),
              Gap(10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Gap(10),
                        Text("mobile_number_or_email".tr(),
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.black)),
                        Gap(5),
                        TextFormField(
                          controller: _emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter Mobile Number or Email';
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Enter Mobile Number or Email',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("password".tr(),
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.black)),
                        Gap(5),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter Password';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter Password',
                            filled: true,
                            fillColor: Colors.white,
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
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OtpScreen1(isNewUser: false),
                            ),
                          );
                        },
                        child: Text(
                          "forgot_password".tr(),
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: RegButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            EasyLoading.show();
                            LoginApi(ref.read(dioProvider))
                                .loginIncident(
                                    mobile: _emailController.text,
                                    password: _passwordController.text)
                                .then((value) async {
                              final prefs = await ref
                                  .read(sharedPreferencesProvider.future);
                              prefs.setString(
                                  "userData", jsonEncode(value.toJson()));
                              ref.read(loginResponseProvider.notifier).state =
                                  value;

                              EasyLoading.dismiss();
                              showSuccessDialog(context);
                            }).onError((error, stackTrace) {
                              EasyLoading.dismiss();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(error.toString()),
                              ));
                            }).whenComplete(() {
                              EasyLoading.dismiss();
                            });
                          }
                        },
                        child: Text(
                          "sign_in".tr(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        )),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      "or_sign_in_with".tr(),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        EasyLoading.show();
                        signInWithGoogle().then((result) async {
                          userCredential = result;
                          if (userCredential == null) {
                            EasyLoading.dismiss();
                            throw Error();
                          }
                          final value = userCredential?.user?.email;
                          await signOut();
                          return LoginApi(ref.read(dioProvider))
                              .googleSigninIncident(token: value!);

                        }).then((value) async {
                          EasyLoading.dismiss();
                          if (value != null) {
                            final prefs = await ref
                                .read(sharedPreferencesProvider.future);
                            prefs.setString(
                                "userData", jsonEncode(value.toJson()));
                            ref.read(loginResponseProvider.notifier).state =
                                value;
                            showSuccessDialog(context);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OtpScreen1(
                                        phoneNumber:
                                            userCredential?.user?.phoneNumber,
                                        isNewUser: true,
                                      )),
                            );
                          }
                        }).catchError((e, stack) {
                          showDialog(
                            context: context,
                            builder: (builder) => ErrorDialog(
                              title: 'Error',
                              message: e.toString(),
                            ),
                          );
                        }).whenComplete(() {
                          EasyLoading.dismiss();
                        });
                      },
                      icon: Image.asset('assets/google.png', height: 35),
                      label: Text(
                        'Sign in with Google',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.black),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                        minimumSize: Size(200, 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(
                              color: Colors.black,
                              width: 1.0,
                            )),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtpScreen1(),
                            ),
                          );
                        },
                        child: Text(
                          'sign_up'.tr(),
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Gap(50),
            ],
          ),
        ));
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
                  "Login Successful!",
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
        MaterialPageRoute(builder: (context) => IncidentHomePage()),
      );
    });
  }
}
