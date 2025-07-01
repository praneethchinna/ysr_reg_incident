import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ysr_reg_incident/feature/incident_registration/ui/incident_home_page.dart';
import 'package:ysr_reg_incident/feature/login/repo/login_api.dart';
import 'package:ysr_reg_incident/feature/login/ui/login_ui.dart';
import 'package:ysr_reg_incident/feature/onboarding/screen_one.dart';
import 'package:ysr_reg_incident/services/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ysr_reg_incident/services/language_service.dart';

const Color myCustomBlue = Color(0xFF3042E2);
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Create a provider for the SharedPreferences
final sharedPrefsProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// Provider for the current locale
final localeProvider = StateProvider<Locale>((ref) {
  // Default to English
  return const Locale('en');
});

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();



  // Get the saved language
  final savedLanguage = await LanguageService.getLanguage();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'), // English
        Locale('te'), // Telugu
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: Locale(savedLanguage),
      child: ProviderScope(
        child: MyApp(),
      ),
    ),
  );
  configLoading();
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: MaterialColor(
          myCustomBlue.value,
          <int, Color>{
            50: myCustomBlue.withOpacity(1),
            100: myCustomBlue.withOpacity(1),
            200: myCustomBlue.withOpacity(1),
            300: myCustomBlue.withOpacity(1),
            400: myCustomBlue.withOpacity(1),
            500: myCustomBlue.withOpacity(1),
            600: myCustomBlue.withOpacity(1),
            700: myCustomBlue.withOpacity(1),
            800: myCustomBlue.withOpacity(1),
            900: myCustomBlue.withOpacity(1),
          },
        ),
        inputDecorationTheme: InputDecorationTheme(
          // focusedBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(15),
          //   borderSide: BorderSide(width: 0.5, color: myCustomBlue),
          // ),
          // enabledBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(15),
          //   borderSide: BorderSide(width: 0.5),
          // ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: 0.0,
            horizontal: 12.0,
          ),
        ),
      ),
      home: const InitialScreenBuild(),
    );
  }
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.chasingDots
    ..maskType = EasyLoadingMaskType.custom
    ..maskColor = myCustomBlue.withOpacity(0.2)
    ..displayDuration = const Duration(seconds: 2)
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 36.0
    ..radius = 100.0
    ..contentPadding = EdgeInsets.zero
    ..progressColor = Colors.black
    ..backgroundColor = Colors.white
    ..indicatorColor = myCustomBlue
    ..textColor = Colors.black
    ..userInteractions = false
    ..dismissOnTap = false;
}

class InitialScreenBuild extends ConsumerWidget {
  const InitialScreenBuild({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future.delayed(const Duration(seconds: 2), () async {
      final sharedPreferences =
          await ref.read(sharedPreferencesProvider.future);
      String? userData = sharedPreferences.getString("userData");
      if (userData != null && userData.isNotEmpty) {
        final decodeData = jsonDecode(userData);
        ref.read(loginResponseProvider.notifier).state =
            LoginResponse.fromMap(decodeData);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const IncidentHomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ScreenOne()),
        );
      }
    });
    return Scaffold(
      appBar: null,
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset("assets/gif/DB Flash.gif", width: 700, height: 700),
      ),
    );
  }
}
