import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ysr_reg_incident/feature/incident_history/model/incident_details_model.dart';
import 'package:ysr_reg_incident/feature/incident_history/model/incident_history_model.dart';

import 'package:ysr_reg_incident/feature/incident_history/repo/incident_history_repository.dart';
import 'package:ysr_reg_incident/feature/login/repo/login_api.dart';
import 'package:ysr_reg_incident/services/dio_provider.dart';

final incidentHistoryRepositoryProvider =
    Provider<IncidentHistoryRepository>((ref) {
  return IncidentHistoryRepository(ref.read(dioProvider));
});

final incidentHistoryProvider =
    FutureProvider.autoDispose<List<IncidentHistoryModel>>((ref) async {
  // TODO: Replace '4' with actual user ID from authentication
  final repository = ref.read(incidentHistoryRepositoryProvider);
  return repository
      .getIncidentHistory(ref.read(loginResponseProvider)!.userId.toString());
});

final incidentDetailsProvider = FutureProvider.autoDispose
    .family<MainIncidentModel, int>((ref, incidentId) async {
  final repository = ref.read(incidentHistoryRepositoryProvider);
  return repository.getIncidentDetails(incidentId);
});

final incidentProofFilesProvider = FutureProvider.autoDispose
    .family<List<String>, int>((ref, incidentId) async {
  final repository = ref.read(incidentHistoryRepositoryProvider);
  return repository.getIncidentProofFiles(incidentId);
});

final incidentHistoryStatusProvider = FutureProvider.autoDispose
    .family<List<HistoryModel>, int>((ref, incidentId) async {
  final repository = ref.read(incidentHistoryRepositoryProvider);
  return repository.getIncidentHistoryStatus(incidentId);
});
