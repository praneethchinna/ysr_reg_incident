
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LanguageService {
  static const String _languageKey = 'selected_language';
  
  // Save the selected language code
  static Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }
  
  // Get the saved language code, defaults to English
  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }
  
  // Change the app's language
  static Future<void> changeLanguage(BuildContext context, String languageCode) async {
    await setLanguage(languageCode);
    await context.setLocale(Locale(languageCode));
  }
  
  // Get the current locale
  static Future<Locale> getCurrentLocale() async {
    final languageCode = await getLanguage();
    return Locale(languageCode);
  }
}
