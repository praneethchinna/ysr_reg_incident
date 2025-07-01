import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ysr_reg_incident/app_colors/app_colors.dart';
import 'package:ysr_reg_incident/feature/signup/ui/signup_screen_two.dart';
import 'package:ysr_reg_incident/utils/reg_background_theme.dart';
import 'package:ysr_reg_incident/utils/reg_buttons.dart';

final nameControllerProvider = StateProvider<TextEditingController>((ref) {
  return TextEditingController();
});

final emailControllerProvider = StateProvider<TextEditingController>((ref) {
  return TextEditingController();
});

final passwordControllerProvider = StateProvider<TextEditingController>((ref) {
  return TextEditingController();
});

final genderProvider = StateProvider<String>((ref) {
  return "Male";
});

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  bool _isPasswordVisible = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget build(BuildContext context) {
    return RegBackgroundTheme(
        showBackButton: true,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 8),
                TextFormField(
                  controller: ref.watch(nameControllerProvider),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'enter_your_name'.tr();
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        child: Image.asset(
                          'assets/signup_icons/profile_icon.png',
                          height: 10,
                          width: 10,
                        ),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
                      hintText: 'enter_your_full_name'.tr(),
                      filled: true,
                      fillColor: Colors.white),
                ),
                SizedBox(height: 16),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildGenderButton("Male"),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildGenderButton("Female"),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(height: 8),
                TextFormField(
                  controller: ref.watch(emailControllerProvider),
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'enter_valis_email_ID'.tr();
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Image.asset(
                        'assets/signup_icons/email_icon.png',
                        height: 5,
                        width: 5,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    hintText: 'enter_your_email_ID'.tr(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(height: 8),
                TextFormField(
                  controller: ref.watch(passwordControllerProvider),
                  obscureText: _isPasswordVisible,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 8) {
                      return 'password_8_chars'.tr();
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0.0, horizontal: 14.0),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Image.asset(
                        'assets/signup_icons/password_icon.png',
                        height: 5,
                        width: 5,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    hintText: 'password'.tr(),
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
                SizedBox(height: 16),
                SizedBox(height: 30),
                RegButton(
                    child: Text(
                      'next'.tr(),
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // notifier.updateMobileNumber(widget.phone ?? "");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SelectLocationScreen()));
                      }
                    }),
              ],
            ),
          ),
        ));
  }

  Widget _buildGenderButton(String gender) {
    bool isSelected = ref.watch(genderProvider) == gender;
    return GestureDetector(
      onTap: () {
        ref.read(genderProvider.notifier).state = gender;
      },
      child: Container(
        height: 45,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
              color: gender.toLowerCase() == 'male'
                  ? AppColors.textFieldColor
                  : Colors.pinkAccent.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: isSelected
                ? gender.toLowerCase() == 'male'
                    ? [AppColors.initalScreenColor1, AppColors.textFieldColor]
                    : [Colors.pinkAccent.withOpacity(0.3), Colors.pinkAccent]
                : [Colors.grey.shade100, Colors.grey.shade100],
          ),
          color: isSelected ? AppColors.electricOcean : Colors.grey.shade100,
        ),
        child: Text(
          gender,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
