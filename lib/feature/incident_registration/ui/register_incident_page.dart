import 'dart:developer';
import 'dart:io';

import 'package:location/location.dart' as loc;
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:ysr_reg_incident/app_colors/app_colors.dart';
import 'package:ysr_reg_incident/feature/incident_history/provider/incident_history_provider.dart';
import 'package:ysr_reg_incident/feature/incident_history/ui/incident_history_page.dart';
import 'package:ysr_reg_incident/feature/incident_registration/provider/incident_registration_provider.dart';
import 'package:ysr_reg_incident/feature/incident_registration/repo/incident_registration_data.dart';
import 'package:ysr_reg_incident/feature/incident_registration/ui/incident_home_page.dart';
import 'package:ysr_reg_incident/feature/incident_registration/ui/video_recorder.dart';
import 'package:ysr_reg_incident/feature/incident_registration/utils.dart';
import 'package:ysr_reg_incident/feature/incident_registration/widgets/build_information_row.dart';
import 'package:ysr_reg_incident/feature/incident_registration/widgets/reg_text_widget.dart';
import 'package:ysr_reg_incident/feature/login/repo/login_api.dart';
import 'package:ysr_reg_incident/feature/login/ui/validate_otp_screen.dart';
import 'package:ysr_reg_incident/feature/signup/models/assembly.dart';
import 'package:ysr_reg_incident/feature/signup/models/parliament.dart';
import 'package:ysr_reg_incident/feature/signup/ui/signup_screen_two.dart';
import 'package:ysr_reg_incident/services/dio_provider.dart';
import 'package:ysr_reg_incident/utils/awsome_snakbar.dart';
import 'package:ysr_reg_incident/utils/generic_dropdown_selector.dart';
import 'package:ysr_reg_incident/utils/language_equivalent_key.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart'
    as contentType;
import 'package:ysr_reg_incident/utils/low_quality_video_recorder.dart';

class RegisterIncidentPage extends ConsumerStatefulWidget {
  const RegisterIncidentPage({super.key});

  @override
  _RegisterIncidentPageState createState() => _RegisterIncidentPageState();
}

class _RegisterIncidentPageState extends ConsumerState<RegisterIncidentPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;
  final parliamentTFController = TextEditingController();
  final assemblyTFController = TextEditingController();
  final nameController = TextEditingController();
  final villageController = TextEditingController();
  final complaineeNameController = TextEditingController();
  final mandalController = TextEditingController();
  final complaineeDesignationController = TextEditingController();

  @override
  void initState() {
    final userData = ref.read(loginResponseProvider);
    if (userData != null) {
      parliamentTFController.text = userData.parliament;
      assemblyTFController.text = userData.constituency;
      nameController.text = userData.name;
      villageController.text = userData.villageName ?? "";
      mandalController.text = userData.mandalName ?? "";
    }
    _locationController = TextEditingController();
    _descriptionController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    parliamentTFController.dispose();
    assemblyTFController.dispose();
    nameController.dispose();
    villageController.dispose();
    complaineeNameController.dispose();
    mandalController.dispose();
    complaineeDesignationController.dispose();
    super.dispose();
  }

  Widget _buildButton(
      {bool isSelected = false,
      required String title,
      required VoidCallback onPress}) {
    return InkWell(
      onTap: onPress,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade400,
            width: 1.5,
          ),
        ),
        child: Text(
          title.tr(),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;

    log(locale.languageCode);
    final incidentState = ref.watch(incidentNotifierProvider);
    final notifier = ref.read(incidentNotifierProvider.notifier);
    return incidentState.when(
        loading: () => Skeletonizer(
              enabled: true,
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Current Incident',
                                ),
                              ),
                            ),
                            Gap(10),
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Past Incident',
                                ),
                              ),
                            ),
                          ],
                        ),
                        Gap(20),
                        Text('Complaint Info'),
                        Gap(20),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Select Incident',
                          ),
                        ),
                        Gap(15),
                        Text('Incident Location'),
                        Gap(5),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Enter Location',
                          ),
                        ),
                        Gap(15),
                        Text('Incident Date'),
                        Gap(5),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Select Date',
                            prefixIcon: Icon(Icons.calendar_month),
                          ),
                        ),
                        Gap(15),
                        Text('Incident Time'),
                        Gap(5),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Select Time',
                            prefixIcon: Icon(Icons.access_time_outlined),
                          ),
                        ),
                        Gap(15),
                        Text('Incident Description'),
                        Gap(5),
                        TextFormField(
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Describe the incident...',
                          ),
                        ),
                        Gap(15),
                        Text('Incident Time'),
                        Gap(5),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Select Time',
                            prefixIcon: Icon(Icons.access_time_outlined),
                          ),
                        ),
                        Gap(15),
                        Text('Incident Description'),
                        Gap(5),
                        TextFormField(
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Describe the incident...',
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (incidentState) {
          if (_locationController.text != incidentState.location) {
            _locationController.text = incidentState.location;
            _locationController.selection = TextSelection.fromPosition(
              TextPosition(offset: _locationController.text.length),
            );
          }

          if (_descriptionController.text != incidentState.description) {
            _descriptionController.text = incidentState.description;
            _descriptionController.selection = TextSelection.fromPosition(
              TextPosition(offset: _descriptionController.text.length),
            );
          }

          final stepCount = incidentState.step;
          return Stack(
            children: [
              Stepper(
                controlsBuilder: (context, details) => SizedBox.shrink(),
                stepIconBuilder: (index, state) {
                  if (state == StepState.complete) {
                    return CircleAvatar(
                      backgroundColor: Colors.green,
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                    );
                  } else {
                    return Text(
                      "${index + 1}",
                      style: TextStyle(color: Colors.white),
                    );
                  }
                },
                elevation: 2,
                type: StepperType.horizontal,
                currentStep: stepCount - 1,
                steps: [
                  Step(
                    label: Text('incident_info'.tr()),
                    state:
                        stepCount > 1 ? StepState.complete : StepState.editing,
                    isActive: stepCount >= 1,
                    title: const Text(''),
                    content: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildButton(
                                    onPress: () {
                                      notifier.updateIsCurrentIncident(true);
                                    },
                                    title: "current_incident",
                                    isSelected:
                                        incidentState.isCurrentIncident),
                              ),
                              Gap(10),
                              Expanded(
                                child: _buildButton(
                                    onPress: () {
                                      notifier.updateIsCurrentIncident(false);
                                    },
                                    title: "past_incident",
                                    isSelected:
                                        !incidentState.isCurrentIncident),
                              ),
                            ],
                          ),
                          // if (ref.read(loginResponseProvider) == null)
                          ...personalInformationWidget(notifier, incidentState),
                          Gap(20),
                          Text(
                            'complaint_info'.tr(),
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          Gap(20),
                          ...[
                            RegTextWidget(
                              text: 'incident_type'.tr(),
                            ),
                            Gap(5),
                            DropdownButtonFormField<String>(
                              onTap: () async {
                                // notifier.getIncidentTypes();
                              },
                              value: incidentState.incidentType.isEmpty
                                  ? null
                                  : incidentState.incidentType,
                              hint: Text(
                                'select_incident'.tr(),
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 16),
                              ),
                              items: incidentState.incidentTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type.name,
                                  child: Text(type.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  notifier.updateIncidentType(value);
                                }
                              },
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'pls_select_incident'.tr()
                                      : null,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 0),
                              ),
                              icon:
                                  const Icon(Icons.keyboard_arrow_down_rounded),
                            )
                          ],
                          Gap(15),
                          ...[
                            RegTextWidget(
                              text: 'incident_location'.tr(),
                            ),
                            Gap(5),
                            TextFormField(
                              onChanged: (value) {
                                notifier.updateLocation(value);
                              },
                              controller: _locationController,
                              decoration: InputDecoration(
                                hintText: 'enter_location'.tr(),
                                suffixIcon: GestureDetector(
                                  onTap: () async {
                                    try {
                                      EasyLoading.show();
                                      loc.Location location = loc.Location();
                                      String locationAndAddress =
                                          await getLocationAndAddress(location);
                                      if (locationAndAddress != null) {
                                        notifier
                                            .updateLocation(locationAndAddress);
                                      }
                                    } catch (e) {
                                      log(e.toString());
                                    } finally {
                                      EasyLoading.dismiss();
                                    }
                                  },
                                  child: Icon(
                                    Icons.location_on,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'pls_enter_location'.tr()
                                      : null,
                            )
                          ],
                          Gap(15),
                          if (!incidentState.isCurrentIncident) ...[
                            RegTextWidget(
                              text: 'incident_date'.tr(),
                            ),
                            Gap(5),
                            TextFormField(
                              readOnly: true,
                              controller: TextEditingController(
                                text: incidentState.incidentDate,
                              ),
                              decoration: InputDecoration(
                                prefixIcon: GestureDetector(
                                    onTap: () {
                                      showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime.now(),
                                      ).then((selectedDate) {
                                        if (selectedDate != null) {
                                          var newDate =
                                              "${selectedDate.day} ${DateFormat('MMMM').format(selectedDate)}, ${selectedDate.year}";
                                          notifier.updateIncidentDate(newDate);
                                        }
                                      });
                                    },
                                    child: Icon(Icons.calendar_month)),
                                hintText: 'incident_date'.tr(),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'pls_enter_location'.tr()
                                      : null,
                            )
                          ],
                          Gap(15),
                          if (!incidentState.isCurrentIncident) ...[
                            RegTextWidget(
                              text: 'incident_time'.tr(),
                            ),
                            Gap(5),
                            TextFormField(
                              readOnly: true,
                              controller: TextEditingController(
                                text: incidentState.incidentTime,
                              ),
                              decoration: InputDecoration(
                                prefixIcon: GestureDetector(
                                    onTap: () {
                                      showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      ).then((selectedTime) {
                                        if (selectedTime != null) {
                                          final formattedTime =
                                              selectedTime.format(context);
                                          notifier.updateIncidentTime(
                                              formattedTime);
                                        }
                                      });
                                    },
                                    child: Icon(Icons.access_time_outlined)),
                                hintText: 'incident_time'.tr(),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'pls_enter_location'.tr()
                                      : null,
                            )
                          ],
                          Gap(15),
                          ...[
                            RegTextWidget(
                              text: 'enter_complainee_name'.tr(),
                            ),
                            Gap(5),
                            TextFormField(
                              onChanged: (value) {
                                log(value);
                                notifier.updateComplainantName(value);
                              },
                              controller: complaineeNameController,
                              decoration: InputDecoration(
                                hintText: 'enter_complainee_name'.tr(),
                                contentPadding: EdgeInsets.only(
                                    top: 20, left: 12, right: 12),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'pls_enter_complainee_name'.tr()
                                      : null,
                            )
                          ],
                          Gap(15),
                          ...[
                            RegTextWidget(
                              text: 'enter_complainee_designation'.tr(),
                            ),
                            Gap(5),
                            TextFormField(
                              onChanged: (value) {
                                notifier.updateComplaineeDesignation(value);
                              },
                              controller: complaineeDesignationController,
                              decoration: InputDecoration(
                                hintText: 'enter_complainee_designation'.tr(),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'pls_enter_complainee_designation'.tr()
                                      : null,
                            )
                          ],
                          Gap(15),
                          ...[
                            RegTextWidget(
                              text: 'incident_desc'.tr(),
                            ),
                            Gap(5),
                            TextFormField(
                              maxLines: 10,
                              onChanged: (value) {
                                log(value);
                                notifier.updateDescription(value);
                              },
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                hintText: 'enter_desc'.tr(),
                                contentPadding: EdgeInsets.only(
                                    top: 20, left: 12, right: 12),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'pls_enter_desc'.tr()
                                      : null,
                            )
                          ],

                          Gap(30),
                          Text(
                            'selfie_video_description'.tr(),
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),

                          Gap(5),
                          if (incidentState.incidentExplanation == null)
                            DottedBorder(
                              borderType: BorderType.RRect,
                              radius: Radius.circular(12),
                              dashPattern: [8, 4],
                              color: Colors.deepPurple,
                              strokeWidth: 1.5,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    // Text('max_file_size'.tr(),
                                    //     style: TextStyle(color: Colors.grey)),
                                    SizedBox(height: 10),
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        // String? path =
                                        //     await LowQualityVideoRecorder
                                        //         .recordLowQualityVideo();
                                        // if (path != null) {
                                        //   notifier
                                        //       .updateIncidentExplanationFile(
                                        //           File(path));
                                        // } else {
                                        //   log("Recording cancelled or failed");
                                        // }
                                        // final result = await ImagePicker()
                                        //     .pickVideo(
                                        //         source: ImageSource.camera);
                                        //
                                        // if (result != null) {
                                        //   notifier
                                        //       .updateIncidentExplanationFile(
                                        //           File(result.path));
                                        // }

                                        final path = await recordVideo(context);

                                        if (path != null) {
                                          debugPrint("✅ Video saved at: $path");
                                          notifier
                                              .updateIncidentExplanationFile(
                                                  File(path));
                                        } else {
                                          debugPrint("⚠ Recording cancelled");
                                        }
                                      },
                                      icon: Icon(
                                        Icons.upload,
                                      ),
                                      label: Text('upload_live_video'.tr()),
                                    ),
                                    SizedBox(height: 10),
                                    Text('live_video'.tr(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.shade200,
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      OpenFile.open(incidentState
                                          .incidentExplanation!.path);
                                    },
                                    child: Icon(
                                      Icons.video_library,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'incident_explanation_video'.tr(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                  Spacer(),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.deepPurple,
                                    ),
                                    onPressed: () {
                                      notifier
                                          .updateIncidentExplanationFile(null);
                                    },
                                  )
                                ],
                              ),
                            ),
                          Gap(30),
                          Text(
                            'upload_files'.tr(),
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          Gap(5),
                          if (incidentState.images.length < 3)
                            DottedBorder(
                              borderType: BorderType.RRect,
                              radius: Radius.circular(12),
                              dashPattern: [8, 4],
                              color: Colors.deepPurple,
                              strokeWidth: 1.5,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    // Text('max_file_size'.tr(),
                                    //     style: TextStyle(color: Colors.grey)),
                                    SizedBox(height: 10),
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        final result =
                                            await FilePicker.platform.pickFiles(
                                          allowMultiple: true,
                                          type: FileType.custom,
                                          allowedExtensions: [
                                            'jpg',
                                            'jpeg',
                                            'png',
                                            'mp4',
                                            'mov',
                                            'mp3',
                                            'm4a',
                                            "pdf"
                                          ],
                                        );

                                        if (result != null) {
                                          final picked = result.files;

                                          // checking not duplicates should exists
                                          // bool isExists = incidentState.images.any(
                                          //     (element) =>
                                          //         picked.contains(element));
                                          // if (isExists) {
                                          //   ScaffoldMessenger.of(context)
                                          //       .showSnackBar(
                                          //     SnackBar(
                                          //         content: Text(
                                          //             'file_already_exists'.tr())),
                                          //   );
                                          //   return;
                                          // }

                                          // file size should not be more that 50 mb
                                          for (var element in picked) {
                                            if (element.size >
                                                50 * 1024 * 1024) {
                                              AwsomeSnackbar.showSuccessSnackbar(
                                                  context: context,
                                                  contentType: contentType
                                                      .ContentType.failure,
                                                  title: "Failure",
                                                  message:
                                                      "file should not exceed 50 mb");

                                              return;
                                            }
                                          }

                                          // checking max files allowed only 3 or less than 3
                                          if (incidentState.images.length +
                                                  picked.length >
                                              3) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'max_files_allowed'
                                                          .tr())),
                                            );
                                            return;
                                          }

                                          notifier.updateImages(picked);
                                        }
                                      },
                                      icon: Icon(
                                        Icons.upload,
                                      ),
                                      label: Text('upload_media'.tr()),
                                    ),
                                    SizedBox(height: 10),
                                    Text('img_vid_aud'.tr(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ),
                          ListView(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: incidentState.images
                                .map(_buildFileTile)
                                .toList(),
                          ),
                          Gap(15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();

                                    if (incidentState.images.isEmpty ||
                                        incidentState.incidentExplanation ==
                                            null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('upload_images'.tr())),
                                      );
                                      return;
                                    }

                                    notifier.updateStep(stepCount + 1);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(200, 40),
                                ),
                                child: Text('next'.tr()),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Step(
                      label: Text('preview_submit'.tr()),
                      state: stepCount > 2
                          ? StepState.complete
                          : StepState.editing,
                      isActive: stepCount >= 2,
                      title: const Text(''),
                      content: SingleChildScrollView(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'preview_and_submit'.tr(),
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          Gap(20),
                          Text(
                            'almost_done'.tr(),
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'please_review'.tr(),
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w400),
                          ),
                          Gap(10),
                          // RegTextWidget(
                          //   text: 'personal_info'.tr(),
                          // ),
                          // Container(
                          //   padding: const EdgeInsets.all(10),
                          //   margin: const EdgeInsets.only(top: 10, bottom: 10),
                          //   decoration: BoxDecoration(
                          //     border: Border.all(
                          //         color: Colors.grey.shade400, width: 0.7),
                          //     borderRadius: BorderRadius.circular(10),
                          //   ),
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       buildInformationRow(
                          //           title: 'name'.tr(),
                          //           value: ref.read(loginResponseProvider)!.name),
                          //       buildInformationRow(
                          //           title: 'gender'.tr(),
                          //           value: ref.read(loginResponseProvider)!.gender),
                          //       buildInformationRow(
                          //           title: 'phone_no'.tr(),
                          //           value: ref.read(loginResponseProvider)!.mobile),
                          //       buildInformationRow(
                          //           title: 'email_id'.tr(),
                          //           value: ref
                          //                   .read(loginResponseProvider)!
                          //                   .email
                          //                   .isEmpty
                          //               ? 'not_available'.tr()
                          //               : ref.read(loginResponseProvider)!.email),
                          //       buildInformationRow(
                          //           title: 'parliament'.tr(),
                          //           value: ref
                          //               .read(loginResponseProvider)!
                          //               .parliament),
                          //       buildInformationRow(
                          //           title: 'constituency'.tr(),
                          //           value: ref
                          //               .read(loginResponseProvider)!
                          //               .constituency),
                          //     ],
                          //   ),
                          // ),
                          Gap(5),
                          Row(
                            children: [
                              RegTextWidget(
                                text: 'incident_info'.tr(),
                              ),
                              Spacer(),
                              IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    notifier.updateStep(stepCount - 1);
                                  },
                                  icon: Icon(Icons.edit_note_rounded))
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(top: 10, bottom: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.shade400, width: 0.7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildInformationRow(
                                    title: 'complainee_name'.tr(),
                                    value: incidentState.complaineeName),
                                buildInformationRow(
                                    title: 'complainee_designation'.tr(),
                                    value: incidentState.complaineeDesignation),
                                buildInformationRow(
                                    title: 'incident_type'.tr(),
                                    value: incidentState.incidentType.isEmpty
                                        ? 'select_incident'.tr()
                                        : incidentState.incidentType),
                                buildInformationRow(
                                    title: 'location'.tr(),
                                    value: incidentState.location.isEmpty
                                        ? 'select_location'.tr()
                                        : incidentState.location),
                                buildInformationRow(
                                    title: 'incident_date'.tr(),
                                    value: incidentState.incidentDate.isEmpty
                                        ? 'select_incident_date'.tr()
                                        : incidentState.incidentDate),
                                buildInformationRow(
                                    title: 'incident_time'.tr(),
                                    value: incidentState.incidentTime.isEmpty
                                        ? 'select_incident_time'.tr()
                                        : incidentState.incidentTime),
                                buildInformationRow(
                                    title: 'incident_desc'.tr(),
                                    value: incidentState.description.isEmpty
                                        ? 'enter_incident_desc'.tr()
                                        : incidentState.description),
                                if (incidentState.images.isNotEmpty) ...[
                                  Gap(5),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Text('incident_images'.tr(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14)),
                                      ),
                                      Text("   :   "),
                                      Expanded(
                                        flex: 6,
                                        child: SizedBox(
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount:
                                                incidentState.images.length,
                                            itemBuilder: (context, index) {
                                              switch (incidentState
                                                  .images[index].name
                                                  .toLowerCase()
                                                  .split('.')
                                                  .last) {
                                                case 'jpg':
                                                case 'jpeg':
                                                case 'png':
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 8),
                                                    child: GestureDetector(
                                                        onTap: () {
                                                          _openFile(
                                                              incidentState
                                                                      .images[
                                                                  index]);
                                                        },
                                                        child: ClipRRect(
                                                          child: Image.file(
                                                              File(incidentState
                                                                  .images[index]
                                                                  .path!),
                                                              width: 100,
                                                              height: 100,
                                                              fit:
                                                                  BoxFit.cover),
                                                        )),
                                                  );
                                                case 'mp4':
                                                case 'mov':
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 8),
                                                    child: GestureDetector(
                                                        onTap: () {
                                                          _openFile(
                                                              incidentState
                                                                      .images[
                                                                  index]);
                                                        },
                                                        child: Container(
                                                          width: 100,
                                                          height: 100,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .deepPurpleAccent
                                                                .withOpacity(
                                                                    0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          child: FutureBuilder<
                                                              File?>(
                                                            future: generateThumbnail(
                                                                videoPath: incidentState
                                                                        .images[
                                                                            index]
                                                                        .path ??
                                                                    ""),
                                                            builder: (context,
                                                                snapshot) {
                                                              if (snapshot
                                                                      .connectionState ==
                                                                  ConnectionState
                                                                      .waiting) {
                                                                return SizedBox(
                                                                  child:
                                                                      const Center(
                                                                    child: CircularProgressIndicator(
                                                                        strokeWidth:
                                                                            2),
                                                                  ),
                                                                );
                                                              }

                                                              if (snapshot
                                                                      .hasData &&
                                                                  snapshot.data !=
                                                                      null) {
                                                                return Container(
                                                                  child: Stack(
                                                                    fit: StackFit
                                                                        .expand,
                                                                    children: [
                                                                      Image
                                                                          .file(
                                                                        snapshot
                                                                            .data!,
                                                                        fit: BoxFit
                                                                            .fill,
                                                                      ),
                                                                      Center(
                                                                          child:
                                                                              Icon(
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            50,
                                                                        Icons
                                                                            .play_arrow,
                                                                      ))
                                                                    ],
                                                                  ),
                                                                );
                                                              }

                                                              // fallback video icon
                                                              return Container(
                                                                color: Colors
                                                                    .black12,
                                                                child: Icon(
                                                                  Icons
                                                                      .play_arrow,
                                                                  size: 50,
                                                                  color: Colors
                                                                      .deepPurpleAccent,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        )),
                                                  );
                                                case 'mp3':
                                                case 'm4a':
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 8),
                                                    child: GestureDetector(
                                                        onTap: () {
                                                          _openFile(
                                                              incidentState
                                                                      .images[
                                                                  index]);
                                                        },
                                                        child: Container(
                                                          width: 100,
                                                          height: 100,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .deepPurpleAccent
                                                                .withOpacity(
                                                                    0.2),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          child: Icon(
                                                            Icons.audio_file,
                                                            size: 50,
                                                            color: Colors
                                                                .deepPurpleAccent,
                                                          ),
                                                        )),
                                                  );
                                                default:
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 8),
                                                    child: GestureDetector(
                                                        onTap: () {
                                                          _openFile(
                                                              incidentState
                                                                      .images[
                                                                  index]);
                                                        },
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .deepPurple
                                                                .withOpacity(
                                                                    0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          width: 100,
                                                          height: 100,
                                                          child: Icon(
                                                            Icons
                                                                .insert_drive_file,
                                                            color: Colors
                                                                .deepPurple,
                                                            size: 50,
                                                          ),
                                                        )),
                                                  );
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (incidentState.incidentExplanation !=
                                    null) ...[
                                  Gap(5),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                            'incident_explanation_video'.tr(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14)),
                                      ),
                                      Text("   :   "),
                                      Expanded(
                                        flex: 6,
                                        child: SizedBox(
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: incidentState
                                                    .incidentExplanation!
                                                    .path
                                                    .isNotEmpty
                                                ? 1
                                                : 0,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8),
                                                child: GestureDetector(
                                                    onTap: () {
                                                      OpenFile.open(incidentState
                                                          .incidentExplanation!
                                                          .path);
                                                    },
                                                    child: Container(
                                                      width: 100,
                                                      height: 100,
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .deepPurpleAccent
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child:
                                                          FutureBuilder<File?>(
                                                        future: generateThumbnail(
                                                            videoPath: incidentState
                                                                .incidentExplanation!
                                                                .path),
                                                        builder: (context,
                                                            snapshot) {
                                                          if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .waiting) {
                                                            return SizedBox(
                                                              child:
                                                                  const Center(
                                                                child: CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        2),
                                                              ),
                                                            );
                                                          }

                                                          if (snapshot
                                                                  .hasData &&
                                                              snapshot.data !=
                                                                  null) {
                                                            return Container(
                                                              child: Stack(
                                                                fit: StackFit
                                                                    .expand,
                                                                children: [
                                                                  Image.file(
                                                                    snapshot
                                                                        .data!,
                                                                    fit: BoxFit
                                                                        .fill,
                                                                  ),
                                                                  Center(
                                                                      child:
                                                                          Icon(
                                                                    color: Colors
                                                                        .white,
                                                                    size: 50,
                                                                    Icons
                                                                        .play_arrow,
                                                                  ))
                                                                ],
                                                              ),
                                                            );
                                                          }

                                                          // fallback video icon
                                                          return Container(
                                                            color:
                                                                Colors.black12,
                                                            child: Icon(
                                                              Icons.play_arrow,
                                                              size: 50,
                                                              color: Colors
                                                                  .deepPurpleAccent,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    )

                                                    // Icon(
                                                    //         isVideo
                                                    //             ? Icons.videocam
                                                    //             : isAudio
                                                    //                 ? Icons
                                                    //                     .audiotrack
                                                    //                 : Icons
                                                    //                     .insert_drive_file,
                                                    //         color:
                                                    //             Colors.deepPurple,
                                                    //       ),
                                                    ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Gap(10),
                          Row(
                            children: [
                              Checkbox(
                                  value: incidentState.agreed,
                                  onChanged: (value) {
                                    notifier.updateAgreed(value!);
                                  }),
                              Gap(5),
                              Expanded(
                                child: Text("terms_submit".tr(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 13)),
                              ),
                            ],
                          ),
                          Gap(10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(200, 40),
                                  ),
                                  onPressed: incidentState.agreed
                                      ? () {
                                          if (!incidentState.agreed) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      "Please read and agree to the Terms and Conditions before submitting.")),
                                            );
                                            return;
                                          }
                                          final userData =
                                              ref.read(loginResponseProvider);
                                          // bool isUserDataAvailable =
                                          //     userData != null;
                                          // final repo = IncidentRegistrationData(
                                          //     ref.read(dioProvider));
                                          // final mobileNumber =
                                          //     ref.read(mobileNumberProvider);

                                          //add stepper data to show stepp check list
                                          // List<StepperData> stepperData = [];
                                          // createStepperData(
                                          //     incidentState, stepperData);
                                          //
                                          // notifier.updateStateData(
                                          //     stepperDataList: stepperData);

                                          notifier.submitIncident().then(
                                              (value) {
                                            if (value != null) {
                                              ref
                                                  .read(userIdProvider.notifier)
                                                  .state = value;
                                              notifier
                                                  .updateComplaineeDesignation(
                                                      '');
                                              notifier
                                                  .updateComplainantName('');
                                              notifier.updateDescription('');
                                              notifier.updateLocation('');
                                              notifier.updateIncidentType('');
                                              notifier.clearImages();
                                              notifier
                                                  .updateIncidentExplanationFile(
                                                      null);
                                              // notifier.updateName('');
                                              //
                                              // notifier.updateMandal('');
                                              // notifier.updateVillage('');

                                              _locationController.clear();
                                              _descriptionController.clear();
                                              // parliamentTFController.clear();
                                              // assemblyTFController.clear();
                                              // nameController.clear();
                                              // villageController.clear();
                                              complaineeNameController.clear();
                                              // mandalController.clear();
                                              complaineeDesignationController
                                                  .clear();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      content: Text(
                                                          "Incident submitted successfully.")));

                                              notifier.updateStep(1);
                                              notifier.refresh();

                                              ref
                                                  .read(
                                                      tabIndexProvider.notifier)
                                                  .update((state) => 1);

                                              // ref.invalidate(
                                              //     incidentHistoryProvider);
                                            }
                                          }, onError: (error, stackTrace) {
                                            AwsomeSnackbar.showSuccessSnackbar(
                                                context: context,
                                                contentType: contentType
                                                    .ContentType.failure,
                                                title: "failed",
                                                message:
                                                    "Error submitting incident: $error");
                                          }).whenComplete(() {});
                                        }
                                      : null,
                                  child: Text("Submit ")),
                            ],
                          )
                        ],
                      ))),
                ],
              ),
              if (incidentState.isLoading)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey.withOpacity(0.7),
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Please dont close the app or press back button until the incident is submitted.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Gap(20),
                      Image.asset(
                        "assets/gif/Loading.gif",
                      ),
                    ],
                  )),
                ),
            ],
          );
        });
  }

  void createStepperData(
      IncidentState incidentState, List<StepperData> stepperData) {
    for (var e in incidentState.images) {
      if (isImage(e.path.toString())) {
        stepperData.add(StepperData(
            title: "incident Details",
            body: e.path.toString().split('/').last));
      } else if (isVideo(e.path.toString())) {
        stepperData.add(StepperData(
            title: "incident Details",
            body: e.path.toString().split('/').last));
      } else {}
    }
    stepperData.add(StepperData(
        title: "incident Explanation", body: "Incident Explanation Video"));
  }

  bool isImage(String path) {
    final extension = path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png'].contains(extension);
  }

  bool isVideo(String path) {
    final extension = path.split('.').last.toLowerCase();
    return ['mp4', 'mov'].contains(extension);
  }

  List<Widget> personalInformationWidget(
      IncidentNotifier notifier, IncidentState incidentState) {
    return [
      Gap(20),
      Text(
        'personal_info'.tr(),
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      Gap(10),
      ...[
        RegTextWidget(
          text: 'name'.tr(),
        ),
        Gap(5),
        TextFormField(
          onChanged: (value) {
            notifier.updateName(value);
          },
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'enter_name'.tr(),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'pls_enter_name'.tr() : null,
        )
      ],
      SizedBox(height: 10),
      ...[
        RegTextWidget(
          text: 'parliament'.tr(),
        ),
        Gap(5),
        AsyncDropdownSelector<Parliament>(
          showSubtitle: false,
          hintText: "Parliament",
          subTitle: "",
          itemsProvider: parliamentProvider,
          textEditingController: parliamentTFController,
          suffixIconColor: AppColors.textFieldColor,
          itemBuilder: (itemContext, entity, isSelected) {
            return ListTile(
              title: Text(
                entity.parliamentName.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                notifier.updateParliament(entity);
                parliamentTFController.text = entity.parliamentName.toString();
                Navigator.pop(itemContext);
              },
            );
          },
          filter: (entity, searchText) {
            return entity.parliamentName
                .toString()
                .toLowerCase()
                .contains(searchText.toLowerCase());
          },
          validator: (value) {
            if (value == "Parliament" || value?.isEmpty == true) {
              return "Please select Parliament";
            }
            return null;
          },
        ),
      ],
      SizedBox(height: 10),
      if (incidentState.parliament != null) ...[
        RegTextWidget(
          text: 'constituency'.tr(),
        ),
        Gap(5),
        AsyncDropdownSelector<Assembly>(
          showSubtitle: false,
          hintText: "Assembly",
          subTitle: "Select Assembly",
          suffixIconColor: AppColors.textFieldColor,
          itemsProvider:
              assemblyProvider(incidentState.parliament!.parliamentId),
          textEditingController: assemblyTFController,
          itemBuilder: (itemContext, entity, isSelected) {
            return ListTile(
              title: Text(
                entity.assemblyName.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                notifier.updateConstituency(entity);
                assemblyTFController.text = entity.assemblyName.toString();
                Navigator.pop(itemContext);
              },
            );
          },
          filter: (entity, searchText) {
            return entity.assemblyName
                .toString()
                .toLowerCase()
                .contains(searchText.toLowerCase());
          },
          validator: (value) {
            if (value == "Assembly" || value?.isEmpty == true) {
              return "Please select Assembly";
            }
            return null;
          },
        ),
      ],
      Gap(10),
      ...[
        RegTextWidget(
          text: 'mandal'.tr(),
        ),
        Gap(5),
        TextFormField(
          onChanged: (value) {
            notifier.updateMandal(value);
          },
          controller: mandalController,
          decoration: InputDecoration(
            hintText: 'enter_mandal_name'.tr(),
          ),
          validator: (value) => value == null || value.isEmpty
              ? 'pls_enter_mandal_name'.tr()
              : null,
        )
      ],
      Gap(10),
      ...[
        RegTextWidget(
          text: 'village'.tr(),
        ),
        Gap(5),
        TextFormField(
          onChanged: (value) {
            notifier.updateVillage(value);
          },
          controller: villageController,
          decoration: InputDecoration(
            hintText: 'enter_village'.tr(),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'pls_enter_village'.tr() : null,
        )
      ],
      Gap(20),
      Divider(
        color: Colors.black,
        height: 20,
        thickness: 1,
      ),
    ];
  }

  void _openFile(PlatformFile file) {
    if (file.path != null) {
      OpenFile.open(file.path!);
    }
  }

  Widget _buildFileTile(PlatformFile file) {
    final notifier = ref.read(incidentNotifierProvider.notifier);
    final isImage =
        ['.jpg', '.jpeg', '.png'].any(file.name.toLowerCase().endsWith);
    final isVideo = ['.mp4', '.mov'].any(file.name.toLowerCase().endsWith);
    final isAudio = ['.mp3', '.m4a'].any(file.name.toLowerCase().endsWith);

    return GestureDetector(
      onTap: () => _openFile(file),
      child: ListTile(
        leading: isImage
            ? Image.file(File(file.path!),
                width: 50, height: 50, fit: BoxFit.cover)
            : Icon(
                isVideo
                    ? Icons.videocam
                    : isAudio
                        ? Icons.audiotrack
                        : Icons.insert_drive_file,
                color: Colors.deepPurple,
              ),
        title: Text(file.name, overflow: TextOverflow.ellipsis),
        trailing: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            setState(() => notifier.removeFile(file));
          },
        ),
      ),
    );
  }
}
