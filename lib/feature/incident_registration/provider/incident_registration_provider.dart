import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as loc;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ysr_reg_incident/feature/incident_registration/repo/incident_registration_data.dart';
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

@riverpod
class IncidentNotifier extends _$IncidentNotifier {
  @override
  Future<IncidentState> build() async {
    IncidentRegistrationData incidentRegistrationData =
        IncidentRegistrationData(ref.read(dioProvider));
    final incidentTypes =
        await incidentRegistrationData.getIncidentCategories();

    final DateTime now = DateTime.now();
    final String incidentDate = DateFormat('dd MMMM, yyyy').format(now);
    final String incidentTime = DateFormat('h:mm a').format(now);
    loc.Location location = loc.Location();
    String locationAndAddress = await getLocationAndAddress(location);
    return IncidentState(
      incidentType: "",
      description: "",
      location: locationAndAddress,
      incidentTypes: incidentTypes,
      incidentDate: incidentDate,
      incidentTime: incidentTime,
      images: [],
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

  void updateStep(int newStep) {
    _updateState(state.value?.copyWith(step: newStep));
  }

  void updateAgreed(bool newAgreed) {
    _updateState(state.value?.copyWith(agreed: newAgreed));
  }

  Future<void> refresh() async {
    IncidentRegistrationData incidentRegistrationData =
        IncidentRegistrationData(ref.read(dioProvider));

    final incidentTypes =
        await incidentRegistrationData.getIncidentCategories();

    final DateTime now = DateTime.now();
    final String incidentDate = DateFormat('dd MMMM, yyyy').format(now);
    final String incidentTime = DateFormat('h:mm a').format(now);
    loc.Location location = loc.Location();
    String locationAndAddress = await getLocationAndAddress(location);
    state = AsyncValue.data(
      IncidentState(
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
  final List<IncidentTypes> incidentTypes;
  final String incidentType;
  final String description;
  final String location;
  final String incidentDate;
  final String incidentTime;
  final List<PlatformFile> images;
  final bool agreed;
  final int step;
  final bool isCurrentIncident;

  IncidentState(
      {required this.incidentType,
      required this.description,
      required this.location,
      required this.incidentTypes,
      this.incidentDate = '',
      this.incidentTime = '',
      this.agreed = false,
      this.step = 1,
      this.isCurrentIncident = true,
      this.images = const []});

  IncidentState copyWith({
    List<IncidentTypes>? incidentTypes,
    String? incidentType,
    String? description,
    String? location,
    String? incidentDate,
    String? incidentTime,
    List<PlatformFile>? images,
    bool? agreed,
    bool? isCurrentIncident,
    int? step,
  }) =>
      IncidentState(
          incidentTypes: incidentTypes ?? this.incidentTypes,
          incidentType: incidentType ?? this.incidentType,
          description: description ?? this.description,
          location: location ?? this.location,
          incidentDate: incidentDate ?? this.incidentDate,
          incidentTime: incidentTime ?? this.incidentTime,
          images: images ?? this.images,
          agreed: agreed ?? this.agreed,
          isCurrentIncident: isCurrentIncident ?? this.isCurrentIncident,
          step: step ?? this.step);
}
