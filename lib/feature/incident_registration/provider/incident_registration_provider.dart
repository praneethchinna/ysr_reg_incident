import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as loc;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ysr_reg_incident/feature/incident_registration/repo/incident_registration_data.dart';
import 'package:ysr_reg_incident/feature/login/repo/login_api.dart';
import 'package:ysr_reg_incident/feature/login/ui/validate_otp_screen.dart';
import 'package:ysr_reg_incident/feature/signup/models/assembly.dart';
import 'package:ysr_reg_incident/feature/signup/models/parliament.dart';
import 'package:ysr_reg_incident/feature/signup/ui/signup_screen_two.dart';
import 'package:ysr_reg_incident/main.dart';
import 'package:ysr_reg_incident/services/dio_provider.dart';
part 'incident_registration_provider.g.dart';

class IncidentTypes {
  final String id;
  final String name;
  IncidentTypes({required this.id, required this.name});

  factory IncidentTypes.fromJson(Map<String, dynamic> json) {
    return IncidentTypes(
      id: json['category_id'].toString(),
      name: json['category_name'],
    );
  }
}

class StepperData {
  final String title;
  final String body;

  final StepState stateState;
  StepperData(
      {required this.title,
      required this.body,
      this.stateState = StepState.disabled});
}

@riverpod
class IncidentNotifier extends _$IncidentNotifier {
  late IncidentRegistrationData incidentRegistrationData;
  @override
  Future<IncidentState> build() async {
    final userData = ref.read(loginResponseProvider);

    incidentRegistrationData = IncidentRegistrationData(ref.read(dioProvider));
    final incidentTypes = await incidentRegistrationData
        .getIncidentCategories(ref.watch(localeProvider).languageCode);

    final DateTime now = DateTime.now();
    final String incidentDate = DateFormat('dd MMMM, yyyy').format(now);
    final String incidentTime = DateFormat('h:mm a').format(now);
    loc.Location location = loc.Location();
    String locationAndAddress = await getLocationAndAddress(location);
    return IncidentState(
      stepperDataList: [
        StepperData(
          title: "File Upload",
          body: "Uploading files to server",
        )
      ],
      incidentType: "",
      description: "",
      location: locationAndAddress,
      incidentTypes: incidentTypes,
      incidentDate: incidentDate,
      incidentTime: incidentTime,
      images: [],
      name: userData?.name ?? "",
      parliament: Parliament(
          parliamentName: userData?.parliament ?? "",
          regionalId: 0,
          parliamentId: 0),
      constituency: Assembly(
          assemblyName: userData?.constituency ?? "",
          assemblyId: 0,
          parliamentId: 0,
          regionalId: 0),
      mandal: userData?.mandalName ?? "",
      village: userData?.villageName ?? "",
    );
  }

  Future<int?> submitIncident() async {
    final value = state.value;
    _updateState(state.value?.copyWith(isLoading: true));
    try {
      final response = await incidentRegistrationData.generateMultipleFiles(
          value!.images.map((e) => File(e.path.toString())).toList(),
          File(value.incidentExplanation?.path ?? ""));

      final isUploaded =
          await incidentRegistrationData.uploadFiles(urls: response);
      if (!isUploaded) {
        throw Exception("Failed to upload files");
      }

      final userData = ref.read(loginResponseProvider);
      final mobileNumber = ref.read(mobileNumberProvider);
      final incidentId = await incidentRegistrationData.submitIncident(
        emailId: userData?.email ?? "",
        userId: userData?.userId ?? 0,
        name: value.name,
        gender: userData?.gender ?? "",
        mobile: userData != null ? userData.mobile : mobileNumber,
        parliament: value.parliament?.parliamentName ?? "",
        assembly: value.constituency?.assemblyName ?? "",
        incidentType: value.incidentType,
        incidentPlace: value.location,
        incidentDate: value.incidentDate,
        incidentTime: value.incidentTime,
        incidentDescription: value.description,
        idProofType: value.incidentType,
        mandal: value.mandal,
        village: value.village,
        complaineeName: value.complaineeName,
        complaineeDesignation: value.complaineeDesignation,
        incidentProofsUrls: response
            .where((value) => value.fileType.toLowerCase() == "incident_proofs")
            .map((e) => e.fileUrl)
            .toList(),
        incidentVideoUrl: response
            .where((value) => value.fileType.toLowerCase() == "video_proofs")
            .map((e) => e.fileUrl)
            .toList()
            .first,
      );
      _updateState(state.value?.copyWith(isLoading: false));
      return incidentId;
    } catch (e) {
      _updateState(state.value?.copyWith(isLoading: false));
      rethrow;
    }
  }

  Future<void> updateStateData(
      {required List<StepperData> stepperDataList}) async {
    _updateState(state.value?.copyWith(stepperData: [
      ...stepperDataList,
      ...state.value!.stepperDataList,
    ]));
  }

  Future<void> updateParliament(Parliament value) async {
    _updateState(state.value?.copyWith(parliament: value));
  }

  Future<void> updateConstituency(Assembly value) async {
    _updateState(state.value?.copyWith(constituency: value));
  }

  void updateIncidentExplanationFile(File? incidentExplanationFile) {
    if (incidentExplanationFile == null) {
      state = AsyncValue.data(state.value!.copyWithExceptIncidentExplanation());
    }
    _updateState(
        state.value?.copyWith(incidentExplanation: incidentExplanationFile));
  }

  void updateIsCurrentIncident(bool isCurrentIncident) {
    _updateState(state.value?.copyWith(
        isCurrentIncident: isCurrentIncident,
        incidentDate: isCurrentIncident
            ? DateFormat('dd MMMM, yyyy').format(DateTime.now())
            : "",
        incidentTime: isCurrentIncident
            ? DateFormat('h:mm a').format(DateTime.now())
            : ""));
  }

  void updateComplaineeDesignation(String complaineeDesignation) {
    _updateState(
        state.value?.copyWith(complaineeDesignation: complaineeDesignation));
  }

  void updateMandal(String mandal) {
    _updateState(state.value?.copyWith(mandal: mandal));
  }

  void updateStep(int newStep) {
    _updateState(state.value?.copyWith(step: newStep));
  }

  void updateAgreed(bool newAgreed) {
    _updateState(state.value?.copyWith(agreed: newAgreed));
  }

  Future<void> refresh() async {
    final incidentTypes = await incidentRegistrationData
        .getIncidentCategories(ref.watch(localeProvider).languageCode);

    final DateTime now = DateTime.now();
    final String incidentDate = DateFormat('dd MMMM, yyyy').format(now);
    final String incidentTime = DateFormat('h:mm a').format(now);
    loc.Location location = loc.Location();
    String locationAndAddress = await getLocationAndAddress(location);
    state = AsyncValue.data(
      IncidentState(
        stepperDataList: [
          StepperData(
            title: "Incident Type",
            body: "Uploading files to server",
          )
        ],
        incidentType: "",
        description: "",
        location: locationAndAddress,
        incidentTypes: incidentTypes,
        incidentDate: incidentDate,
        incidentTime: incidentTime,
        images: [],
      ),
    );
  }

  void updateName(String newName) {
    _updateState(state.value?.copyWith(name: newName));
  }

  void updateVillage(String newVillage) {
    _updateState(state.value?.copyWith(village: newVillage));
  }

  void updateComplainantName(String newComplainantName) {
    _updateState(state.value?.copyWith(complaineeName: newComplainantName));
  }

  Future<void> getIncidentTypes() async {
    final incidentTypes = await incidentRegistrationData
        .getIncidentCategories(ref.watch(localeProvider).languageCode);
    _updateState(state.value?.copyWith(incidentTypes: incidentTypes));
  }

  void updateIncidentType(String newType) {
    _updateState(state.value?.copyWith(incidentType: newType));
  }

  void updateLocation(String newLocation) {
    _updateState(state.value?.copyWith(location: newLocation));
  }

  void updateDescription(String newDescription) {
    _updateState(state.value?.copyWith(description: newDescription));
  }

  void updateIncidentDate(String newDate) {
    _updateState(state.value?.copyWith(incidentDate: newDate));
  }

  void updateIncidentTime(String newTime) {
    _updateState(state.value?.copyWith(incidentTime: newTime));
  }

  void updateImages(List<PlatformFile> newImages) {
    _updateState(
        state.value?.copyWith(images: [...state.value!.images, ...newImages]));
  }

  void clearImages() {
    _updateState(state.value?.copyWith(images: []));
  }

  void removeFile(PlatformFile file) {
    _updateState(state.value?.copyWith(
        images: state.value!.images
            .where((element) => element.name != file.name)
            .toList()));
  }

  void _updateState(IncidentState? newState) {
    if (newState != null) {
      state = AsyncValue.data(newState);
    }
  }
}

class IncidentState {
  final List<StepperData> stepperDataList;
  final List<IncidentTypes> incidentTypes;
  final String incidentType;
  final String description;
  final String location;
  final String incidentDate;
  final String incidentTime;
  final List<PlatformFile> images;
  final String name;
  final bool agreed;
  final int step;
  final bool isCurrentIncident;
  final String village;
  final Parliament? parliament;
  final Assembly? constituency;
  final String mandal;
  final String complaineeName;
  final String complaineeDesignation;
  final File? incidentExplanation;
  final bool isLoading;

  IncidentState({
    required this.stepperDataList,
    required this.incidentType,
    required this.description,
    required this.location,
    required this.incidentTypes,
    this.incidentDate = '',
    this.incidentTime = '',
    this.agreed = false,
    this.step = 1,
    this.isCurrentIncident = true,
    this.village = '',
    this.images = const [],
    this.parliament,
    this.constituency,
    this.mandal = '',
    this.complaineeName = '',
    this.complaineeDesignation = '',
    this.incidentExplanation,
    this.name = "",
    this.isLoading = false,
  });
  IncidentState copyWith(
          {List<IncidentTypes>? incidentTypes,
          String? incidentType,
          String? description,
          String? location,
          String? incidentDate,
          String? incidentTime,
          List<PlatformFile>? images,
          bool? agreed,
          bool? isCurrentIncident,
          int? step,
          String? village,
          Parliament? parliament,
          Assembly? constituency,
          String? mandal,
          String? complaineeName,
          String? complaineeDesignation,
          File? incidentExplanation,
          bool? isLoading,
          String? name,
          List<StepperData>? stepperData}) =>
      IncidentState(
        isLoading: isLoading ?? this.isLoading,
        stepperDataList: stepperData ?? this.stepperDataList,
        incidentTypes: incidentTypes ?? this.incidentTypes,
        incidentType: incidentType ?? this.incidentType,
        description: description ?? this.description,
        location: location ?? this.location,
        incidentDate: incidentDate ?? this.incidentDate,
        incidentTime: incidentTime ?? this.incidentTime,
        images: images ?? this.images,
        agreed: agreed ?? this.agreed,
        isCurrentIncident: isCurrentIncident ?? this.isCurrentIncident,
        step: step ?? this.step,
        village: village ?? this.village,
        parliament: parliament ?? this.parliament,
        constituency: constituency ?? this.constituency,
        mandal: mandal ?? this.mandal,
        complaineeName: complaineeName ?? this.complaineeName,
        complaineeDesignation:
            complaineeDesignation ?? this.complaineeDesignation,
        incidentExplanation: incidentExplanation ?? this.incidentExplanation,
        name: name ?? this.name,
      );

  IncidentState copyWithExceptIncidentExplanation() => IncidentState(
        incidentTypes: this.incidentTypes,
        incidentType: this.incidentType,
        description: this.description,
        location: this.location,
        incidentDate: this.incidentDate,
        incidentTime: this.incidentTime,
        images: this.images,
        agreed: this.agreed,
        isCurrentIncident: this.isCurrentIncident,
        step: this.step,
        village: this.village,
        parliament: this.parliament,
        constituency: this.constituency,
        mandal: this.mandal,
        complaineeName: this.complaineeName,
        complaineeDesignation: this.complaineeDesignation,
        incidentExplanation: null,
        name: this.name,
        stepperDataList: this.stepperDataList,
      );
}

Future<String> getLocationAndAddress(loc.Location location) async {
  bool serviceEnabled;
  loc.PermissionStatus permissionGranted;
  loc.LocationData locationData;

  // Check permission
  permissionGranted = await location.hasPermission();
  if (permissionGranted == loc.PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != loc.PermissionStatus.granted) {
      log("Permission not granted");
      return ""; // Permission not granted
    }
  }

  // Check if location service is enabled
  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      log("Location service not enabled");
      return ""; // Location service not enabled
    }
  }

  // Get location
  locationData = await location.getLocation();
  double lat = locationData.latitude!;
  double lng = locationData.longitude!;

  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
    Placemark place = placemarks.first;
    log(place.toString());
    return "${place.name}, ${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
  } catch (e) {
    log(e.toString());
    return ""; // Failed to get address
  }
}
