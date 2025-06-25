import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:ysr_reg_incident/app_colors/app_colors.dart';
import 'package:ysr_reg_incident/feature/incident_registration/provider/incident_registration_provider.dart';
import 'package:ysr_reg_incident/feature/incident_registration/ui/incident_home_page.dart';
import 'package:ysr_reg_incident/feature/incident_registration/ui/register_incident_page.dart';
import 'package:ysr_reg_incident/feature/incident_registration/widgets/reg_app_bar.dart';
import 'package:ysr_reg_incident/feature/login/repo/login_api.dart';
import 'package:ysr_reg_incident/feature/login/ui/login_ui.dart';
import 'package:ysr_reg_incident/feature/profile/provider/profile_provider.dart';
import 'package:ysr_reg_incident/feature/profile/ui/profile_edit.dart';
import 'package:ysr_reg_incident/services/shared_preferences.dart';
import 'package:ysr_reg_incident/utils/reg_buttons.dart';

class UserProfileUI extends ConsumerWidget {
  const UserProfileUI({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileData = ref.watch(profileIncidentProvider);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: RegAppBar(
          title: Text(
            "Profile",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          actions: [
            GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfileEdit()));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(MdiIcons.accountEdit),
                ))
          ],
        ),
        body: profileData.when(
            data: (value) {
              final data = value;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Column(
                      children: [
                        Image.asset(
                          'assets/profile.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                        Gap(10),
                        Text(
                          data.name,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                        Gap(10),
                      ],
                    ),
                    Gap(10),
                    if (data.mobile.isNotEmpty) ...[
                      ProfileCard(
                        imagePath: 'assets/number_icon.png',
                        title: "Phone",
                        value: data.mobile,
                      ),
                    ],
                    if (data.email.isNotEmpty) ...[
                      ProfileCard(
                        imagePath: 'assets/email_icon.png',
                        title: "Email",
                        value: data.email,
                      ),
                    ],
                    if (data.gender.isNotEmpty) ...[
                      ProfileCard(
                        imagePath: 'assets/gender.png',
                        title: "Gender",
                        value: data.gender,
                      ),
                    ],
                    if (data.country.isNotEmpty) ...[
                      ProfileCard(
                        imagePath: 'assets/country_icon.png',
                        title: "Country",
                        value: data.country,
                      ),
                    ],
                    if (data.parliament.isNotEmpty) ...[
                      ProfileCard(
                        imagePath: 'assets/parliament_icon.png',
                        title: "Parliament",
                        value: data.parliament,
                      ),
                    ],
                    if (data.constituency.isNotEmpty) ...[
                      ProfileCard(
                        imagePath: 'assets/assembly_icon.png',
                        title: "Constituency",
                        value: data.constituency,
                      ),
                    ],
                    Gap(10),
                    SizedBox(height: 30),
                    RegButton(
                        child: Text("Logout"),
                        onPressed: () async {
                          ref.read(loginResponseProvider.notifier).state = null;

                          ref.read(tabIndexProvider.notifier).state = 0;
                          final sharedPreferences =
                              await ref.read(sharedPreferencesProvider.future);
                          await sharedPreferences.setString("userData", "");

                          ref.invalidate(profileIncidentProvider);

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginUi(),
                            ),
                                (Route<dynamic> route) => false,
                          );
                        }),
                  ],
                ),
              );
            },
            error: (error, stack) {
              return Center(
                child: Text(error.toString()),
              );
            },
            loading: () => Center(
                  child: CircularProgressIndicator.adaptive(),
                )));
  }
}

class ProfileCard extends StatelessWidget {
  final String imagePath; // Path to asset image
  final String title;
  final String value;
  final double imageSize;

  const ProfileCard(
      {super.key,
      required this.imagePath,
      required this.title,
      required this.value,
      this.imageSize = 25,
      th});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              imagePath,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class LikeStatCard extends StatelessWidget {
  final String label;
  final int count;
  final String imagePath; // PNG or asset path
  final Color? bgColor;
  final Color? iconColor;

  const LikeStatCard({
    super.key,
    required this.label,
    required this.count,
    required this.imagePath,
    this.bgColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon (PNG image)
          Image.asset(
            imagePath,
            height: 24,
            width: 24,
          ),
          const SizedBox(width: 8),
          // Text content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
              Text(
                count.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
