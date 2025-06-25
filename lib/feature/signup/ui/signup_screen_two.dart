import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ysr_reg_incident/app_colors/app_colors.dart';
import 'package:ysr_reg_incident/feature/login/ui/login_ui.dart';
import 'package:ysr_reg_incident/feature/login/ui/otp_screen.dart';
import 'package:ysr_reg_incident/feature/signup/models/assembly.dart';
import 'package:ysr_reg_incident/feature/signup/models/parliament.dart';
import 'package:ysr_reg_incident/feature/signup/repo/data.dart';
import 'package:ysr_reg_incident/feature/signup/ui/signup_screen.dart';
import 'package:ysr_reg_incident/services/dio_provider.dart';
import 'package:ysr_reg_incident/utils/country_state_response_model.dart';
import 'package:ysr_reg_incident/utils/generic_dropdown_selector.dart';
import 'package:ysr_reg_incident/utils/reg_background_theme.dart';
import 'package:ysr_reg_incident/utils/reg_buttons.dart';
import 'package:ysr_reg_incident/utils/show_error_dialog.dart';

class SelectLocationScreen extends ConsumerStatefulWidget {
  const SelectLocationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SelectLocationScreen> createState() =>
      _SelectLocationScreenState();
}

class _SelectLocationScreenState extends ConsumerState<SelectLocationScreen> {
  final parliamentTFController = TextEditingController();
  final assemblyTFController = TextEditingController();

  String country = "";
  String state = "";
  Parliament? parliament;
  Assembly? assembly;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RegBackgroundTheme(
        showBackButton: true,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(children: [
            DropdownSearch<String>(
              popupProps: PopupProps.menu(
                showSearchBox: true,
                showSelectedItems: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: "Search country...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              items: (String filter, LoadProps? props) {
                List<String> allCountries = CountryStateResponseModel.country;
                return allCountries
                    .where((country) =>
                        country.toLowerCase().contains(filter.toLowerCase()))
                    .toList();
              },
              decoratorProps: DropDownDecoratorProps(
                decoration: InputDecoration(
                  suffixIcon:
                      Icon(Icons.keyboard_arrow_down, color: Colors.teal),
                  labelText: 'Country ',
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green, width: 1.2),
                  ),
                ),
              ),
              onChanged: (String? value) {
                setState(() {
                  country = value!;
                });
                print('Selected country: $value');
              },
            ),
            SizedBox(height: 20),
            if (country.isNotEmpty && country.toLowerCase() == "india")
              DropdownSearch<String>(
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  showSelectedItems: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: "Search State...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                items: (String filter, LoadProps? props) {
                  List<String> allStates = CountryStateResponseModel.state;
                  return allStates
                      .where((state) =>
                          state.toLowerCase().contains(filter.toLowerCase()))
                      .toList();
                },
                decoratorProps: DropDownDecoratorProps(
                  decoration: InputDecoration(
                    suffixIcon:
                        Icon(Icons.keyboard_arrow_down, color: Colors.teal),
                    labelText: 'State ',
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.green, width: 1.2),
                    ),
                  ),
                ),
                onChanged: (String? value) {
                  setState(() {
                    state = value!;
                  });
                  print('Selected State: $value');
                },
              ),
            SizedBox(height: 20),
            AsyncDropdownSelector<Parliament>(
              showSubtitle: false,
              hintText: "Parliament",
              subTitle: "",
              itemsProvider: parliamentProvider,
              textEditingController: parliamentTFController,
              suffixIconColor: AppColors.primaryColor,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.green, width: 1.2),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.green, width: 1.2),
              ),
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
                    parliamentTFController.text =
                        entity.parliamentName.toString();
                    setState(() {
                      parliament = Parliament(
                          parliamentName: entity.parliamentName,
                          regionalId: entity.regionalId,
                          parliamentId: entity.parliamentId);
                    });
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
            SizedBox(height: 20),
            if (parliament != null)
              AsyncDropdownSelector<Assembly>(
                showSubtitle: false,
                hintText: "Assembly",
                subTitle: "Select Assembly",
                suffixIconColor: AppColors.textFieldColor,
                itemsProvider: assemblyProvider(parliament!.parliamentId),
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
                      assemblyTFController.text =
                          entity.assemblyName.toString();
                      final assemblyName = entity;
                      setState(() {
                        assembly = Assembly(
                            assemblyName: entity.assemblyName,
                            parliamentId: entity.parliamentId,
                            assemblyId: entity.assemblyId,
                            regionalId: entity.regionalId);
                      });
                      Navigator.pop(itemContext);
                    },
                  );
                },
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green, width: 1.2),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green, width: 1.2),
                ),
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
            SizedBox(height: 90),
            RegButton(
              onPressed: country.isNotEmpty &&
                      state.isNotEmpty &&
                      parliament != null &&
                      assembly != null
                  ? () {
                      EasyLoading.show();
                      SignupIncidentData(ref.read(dioProvider))
                          .signupIncident(
                        name: ref.read(nameControllerProvider).text,
                        gender: ref.read(genderProvider),
                        country: country,
                        state: state,
                        parliament: parliament!.parliamentId,
                        constituency: assembly!.assemblyId,
                        mobile: ref.read(mobileNumberProvider),
                        email: (ref.read(emailControllerProvider).text),
                        password: ref.read(passwordControllerProvider).text,
                      )
                          .then((value) {
                        EasyLoading.dismiss();
                        if (value) {
                          ref.read(nameControllerProvider.notifier).state =
                              TextEditingController();
                          ref.read(emailControllerProvider.notifier).state =
                              TextEditingController();
                          ref.read(passwordControllerProvider.notifier).state =
                              TextEditingController();
                          ref.read(genderProvider.notifier).state = "Male";
                          ref.read(mobileNumberProvider.notifier).state = "";

                          _showSuccessDialog(context);
                        } else {
                          showDialog(
                              context: context,
                              builder: (context) => ErrorDialog(
                                  title: "somthing went wrong",
                                  message: "can't sign up"));
                        }
                      }, onError: (error, stackTrace) {
                        EasyLoading.dismiss();
                        showDialog(
                            context: context,
                            builder: (context) => ErrorDialog(
                                title: "somthing went wrong",
                                message: error.toString()));
                      }).whenComplete(() {
                        EasyLoading.dismiss();
                      });
                    }
                  : null,
              child: Text(
                "Finish",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ]),
        ));
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing manually
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 50),
                SizedBox(height: 10),
                Text(
                  "Signup Successful!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context); // Close dialog
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginUi()),
      );
    });
  }
}

final parliamentProvider =
    FutureProvider.autoDispose<List<Parliament>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get<List<dynamic>>('/parliaments');
  if (response.statusCode == 200) {
    if (response.data == null || (response.data as List).isEmpty) {
      return [];
    }
    return (response.data as List).map((e) => Parliament.fromJson(e)).toList();
  } else {
    return throw Exception("Failed fetch Assembly");
  }
});

final assemblyProvider =
    FutureProvider.autoDispose.family<List<Assembly>, int>((ref, id) async {
  final dio = ref.read(dioProvider);
  final response =
      await dio.get<List<dynamic>>('/assemblies?parliament_id=$id');
  if (response.statusCode == 200) {
    if (response.data == null || (response.data as List).isEmpty) {
      return [];
    }
    return (response.data as List).map((e) => Assembly.fromJson(e)).toList();
  } else {
    return throw Exception("Failed fetch Assembly");
  }
});
