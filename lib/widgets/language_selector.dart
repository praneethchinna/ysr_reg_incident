import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ysr_reg_incident/services/language_service.dart';

class LanguageSelector extends StatelessWidget {
  final bool showLabel;
  final EdgeInsets? padding;

  const LanguageSelector({
    Key? key,
    this.showLabel = true,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;
    
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showLabel) Text(
            'language'.tr(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ) else const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentLocale.languageCode,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                elevation: 16,
                style: const TextStyle(color: Colors.black, fontSize: 14),
                onChanged: (String? newValue) async {
                  if (newValue != null) {
                    await LanguageService.changeLanguage(context, newValue);
                  }
                },
                items: <String>['en', 'te']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value == 'en' ? 'English' : 'తెలుగు',
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
