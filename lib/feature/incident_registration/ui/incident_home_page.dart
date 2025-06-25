import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:ysr_reg_incident/app_colors/app_colors.dart';
import 'package:ysr_reg_incident/feature/incident_history/provider/incident_history_provider.dart';
import 'package:ysr_reg_incident/feature/incident_registration/ui/register_incident_page.dart';
import 'package:ysr_reg_incident/feature/incident_registration/widgets/reg_app_bar.dart';
import 'package:ysr_reg_incident/feature/profile/ui/profile_ui.dart';

import '../../incident_history/ui/incident_history_page.dart';


final tabIndexProvider = StateProvider<int>((ref) => 0);

final class IncidentHomePage extends ConsumerStatefulWidget {
  const IncidentHomePage({super.key});

  @override
  ConsumerState<IncidentHomePage> createState() => _RegisterIncidentPageState();
}

class _RegisterIncidentPageState extends ConsumerState<IncidentHomePage> {

  final _indexStack=[
    RegisterIncidentPage(),
    IncidentHistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final tabIndex = ref.watch(tabIndexProvider);
    return Scaffold(
      appBar: RegAppBar(
        centerTitle: true,
        leading: Image.asset(
          "assets/ysr_logo.png",
          width: 60,
          height: 60,
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => UserProfileUI()),
              );
            },
            child: Image.asset(
              "assets/profile.png",
              width: 35,
              height: 35,
            ),
          ),
          Gap(10),
        ],
        elevation: 0,
        title: Text(
          ref.watch(tabIndexProvider) == 0
              ? 'Register Incident'
              : 'Incident History',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: IndexedStack(
        index: tabIndex,
        children: _indexStack,
      ),
      bottomNavigationBar: Stack(
        children: [
          Container(
            height: Platform.isIOS ? 100 : 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.secondaryLightBlue,
                  AppColors.secondaryDarkBlue
                ],
              ),
            ),
          ),
          BottomNavigationBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.black,
            unselectedItemColor: AppColors.primaryColor,
            selectedLabelStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            currentIndex: ref.watch(tabIndexProvider),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.app_registration),
                  label: 'Register Incident'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Incident History'),
            ],
            onTap: (index) {
              ref.read(tabIndexProvider.notifier).state = index;
              if (index == 1) {
                ref.invalidate(incidentHistoryProvider);
              }
            },
          ),
        ],
      ),
    );
  }
}
