import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ysr_reg_incident/feature/login/repo/login_api.dart';
import 'package:ysr_reg_incident/feature/profile/model/profile_response_model.dart';
import 'package:ysr_reg_incident/feature/profile/repo/profile_repo.dart';

final profileIncidentProvider =
    FutureProvider.autoDispose<ProfileResponseModel>(
  (ref) async {
    final repo = ref.read(profileRepoProvider);
    return await repo
        .getProfileIncident(ref.read(loginResponseProvider)!.mobile.toString());
  },
);
