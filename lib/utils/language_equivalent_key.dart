import 'package:easy_localization/easy_localization.dart';

String equivalentKey(String value) {
  switch (value) {
    case 'TDP attacks - Default':
      return 'tdp_attacks'.tr();
    case 'Governance issue - General':
      return 'Gov_issue'.tr();
    case 'Scams of Kutami - Sand/Gravel':
      return 'scams_kutami'.tr();
    case 'Liquor Issues - Belt shop price hike':
      return 'liq_issues'.tr();
    case 'Local leader Bribe':
      return 'local_lead_bribe'.tr();
    case 'Roads issues':
      return 'road_issues'.tr();
    case 'Satchavalayam issues':
      return 'satch_issues'.tr();
    case 'RBK issues':
      return 'rbk_issues'.tr();
    case 'Schools issues':
      return 'school_issues'.tr();
    case 'Hospital issues':
      return 'hospital_issues'.tr();
    case 'Pension issues':
      return 'pension_issues'.tr();
    case 'Ration issues':
      return 'ration_issues'.tr();
    case 'Farmer issues':
      return 'farmer_issues'.tr();
    default:
      return '';
  }
}