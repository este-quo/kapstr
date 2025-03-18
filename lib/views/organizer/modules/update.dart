import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/controllers/modules/modules.dart';
import 'package:kapstr/views/organizer/modules/update_module/place_picker.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/widgets/organizer/modules/change_module_picture.dart';
import 'package:kapstr/widgets/organizer/modules/infos_image.dart';
import 'package:kapstr/widgets/organizer/modules/infos_textfield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UpdateModule extends StatefulWidget {
  final Module module;
  final GlobalKey<UpdateModuleState> key;

  const UpdateModule({required this.module, required this.key}) : super(key: key);

  @override
  UpdateModuleState createState() => UpdateModuleState();
}

class UpdateModuleState extends State<UpdateModule> {
  bool isImageLoading = false;
  File? imageFile;
  TextEditingController moduleNameController = TextEditingController();
  TextEditingController placeNameController = TextEditingController();
  TextEditingController moreInfosController = TextEditingController();

  final FocusNode _infoFocusNode = FocusNode();

  final moduleNameFocusNode = FocusNode();
  final modulePlaceFocusNode = FocusNode();
  DateTime? selectedDateFromPicker;

  Future<void> saveData() async {
    if (moduleNameController.text != '') {
      widget.module.name = moduleNameController.text;
      await context.read<ModulesController>().updateModuleField(moduleId: widget.module.id, key: "name", value: moduleNameController.text);

      if (context.mounted) {
        context.read<EventsController>().updateModules(await context.read<ModulesController>().getModules(Event.instance.id));
      }
    }

    await updateAllFields(selectedDateFromPicker!);
  }

  @override
  void initState() {
    super.initState();
    selectedDateFromPicker = widget.module.date ?? DateTime.now();

    moduleNameController = TextEditingController(text: widget.module.name);

    placeNameController = TextEditingController(text: widget.module.placeName == "Nom du lieu" ? "" : widget.module.placeName);

    moreInfosController = TextEditingController(text: widget.module.moreInfos == 'Plus d\'informations' ? "" : widget.module.moreInfos);
  }

  @override
  void dispose() {
    _infoFocusNode.dispose();
    moduleNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var currentModule = widget.module;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name label
            const Text('Nom du module', style: TextStyle(fontSize: 18, color: kBlack, fontWeight: FontWeight.w500)),
            // Module name
            CustomModuleTextField(controller: moduleNameController, hintText: 'Nom du module', maxCharacters: 20),

            const SizedBox(height: 15),

            if (widget.module.type == "wedding" || widget.module.type == "mairie" || widget.module.type == "event")
              // Place name
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Lieu', style: TextStyle(fontSize: 18, color: kBlack, fontWeight: FontWeight.w500)),
                  TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    focusNode: moduleNameFocusNode,
                    style: const TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w400),
                    controller: placeNameController,
                    textInputAction: TextInputAction.done,
                    onTapOutside: (event) {
                      FocusScope.of(context).unfocus();
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
                      hintText: placeNameController.text.isEmpty ? 'Entrez nom du lieu' : placeNameController.text,
                      hintStyle: const TextStyle(color: kLightGrey, fontWeight: FontWeight.w400, fontSize: 16),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      filled: true,
                      fillColor: Colors.transparent,
                      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
                    ),
                  ),

                  const SizedBox(height: 12),

                  GestureDetector(
                    onTap: () async {
                      showModalBottomSheet(
                        isScrollControlled: true, // This allows the bottom sheet to take the full height
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        backgroundColor: kWhite,
                        elevation: 0,
                        context: context,
                        builder: (context) {
                          return DraggableScrollableSheet(
                            initialChildSize: 0.95, // Adjust this value as needed, up to 1 for full screen
                            minChildSize: 0.5, // Adjust this value as needed, minimum fraction of the screen occupied by the sheet
                            maxChildSize: 1, // Can expand to full screen
                            builder: (context, scrollController) {
                              return Column(
                                children: [
                                  // Custom drag handle
                                  Container(
                                    width: 40, // Adjust the width as needed
                                    height: 5, // Adjust the height as needed
                                    margin: const EdgeInsets.only(top: 8, bottom: 4), // Adjust the margin as needed
                                    decoration: BoxDecoration(
                                      color: kWhite, // Handle color
                                      borderRadius: BorderRadius.circular(2.5), // Adjust the border radius as needed
                                    ),
                                  ),
                                  // Your PlacePicker widget or other content
                                  Expanded(child: PlacePicker(module: widget.module, moduleId: widget.module.id, placeAdress: widget.module.placeAddress ?? '')),
                                ],
                              );
                            },
                          );
                        },
                      ).then((value) {
                        if (value != null) {
                          setState(() {
                            widget.module.placeAddress = value;
                          });
                        }
                      });
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width - 40,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: (const BoxDecoration(border: Border(bottom: BorderSide(color: kBlack, width: 1)))),
                      child: Text(
                        widget.module.placeAddress == null || widget.module.placeAddress == '' || widget.module.placeAddress == 'Adresse du lieu' ? 'Entrez l\'adresse du lieu' : widget.module.placeAddress!,
                        style: TextStyle(color: widget.module.placeAddress == null || widget.module.placeAddress == '' || widget.module.placeAddress == 'Adresse du lieu' ? kLightGrey : kBlack, fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text('Date', style: TextStyle(fontSize: 18, color: kBlack, fontWeight: FontWeight.w500)),

                  // Date selector
                  GestureDetector(
                    onTap: () async {
                      if (Theme.of(context).platform == TargetPlatform.iOS) {
                        await showModalBottomSheet(
                          context: context,
                          builder: (BuildContext builder) {
                            return SizedBox(
                              height: MediaQuery.of(context).copyWith().size.height / 3,
                              child: CupertinoDatePicker(
                                mode: CupertinoDatePickerMode.date,
                                minimumDate: DateTime.now(),
                                maximumDate: DateTime(2100),
                                initialDateTime: selectedDateFromPicker!.isBefore(DateTime.now()) ? DateTime.now() : selectedDateFromPicker!,
                                onDateTimeChanged: (DateTime newDate) {
                                  // remove time from the date
                                  newDate = DateTime(newDate.year, newDate.month, newDate.day, selectedDateFromPicker!.hour, selectedDateFromPicker!.minute);
                                  setState(() {
                                    selectedDateFromPicker = newDate;
                                  });

                                  saveData();
                                },
                              ),
                            );
                          },
                        );
                      } else {
                        showDatePicker(
                          context: context,
                          initialDatePickerMode: DatePickerMode.day,
                          initialEntryMode: DatePickerEntryMode.calendarOnly,
                          locale: const Locale('fr', 'FR'),
                          helpText: 'Date de début',
                          confirmText: 'Valider',
                          cancelText: 'Annuler',
                          errorInvalidText: 'Valeur invalide',
                          fieldLabelText: 'Date de début',
                          fieldHintText: 'Date de début',
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                          initialDate: selectedDateFromPicker!.isBefore(DateTime.now()) ? DateTime.now() : selectedDateFromPicker!,
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                dialogTheme: DialogTheme(backgroundColor: kWhite, surfaceTintColor: kWhite, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                colorScheme: const ColorScheme.light(primary: kPrimary, onPrimary: kWhite, surface: kWhite, onSurface: kBlack, background: Colors.white),
                                dialogBackgroundColor: kWhite,
                              ),
                              child: child!,
                            );
                          },
                        ).then((value) {
                          if (value != null) {
                            setState(() {
                              selectedDateFromPicker = DateTime(value.year, value.month, value.day, selectedDateFromPicker!.hour, selectedDateFromPicker!.minute);
                            });
                          }
                          saveData();

                          printOnDebug(selectedDateFromPicker.toString());
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      width: MediaQuery.of(context).size.width - 40,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: kBlack, width: 1),
                          // color: kLightGrey,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [Text(DateFormat('dd/MM/yyyy').format(selectedDateFromPicker!), style: const TextStyle(color: kLightGrey, fontSize: 16, fontWeight: FontWeight.w400)), Icon(Icons.calendar_month_outlined, color: kBlack, size: 24)],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Time selector
                  GestureDetector(
                    onTap: () {
                      showTimePicker(
                        initialEntryMode: TimePickerEntryMode.inputOnly,
                        hourLabelText: 'Heure',
                        minuteLabelText: 'Minute',
                        helpText: 'Heure de début',
                        confirmText: 'Valider',
                        cancelText: 'Annuler',
                        errorInvalidText: 'Valeur invalide',
                        context: context,
                        initialTime: TimeOfDay(hour: selectedDateFromPicker!.hour, minute: selectedDateFromPicker!.minute),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              dialogTheme: DialogTheme(backgroundColor: kWhite, surfaceTintColor: kWhite, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              colorScheme: const ColorScheme.light(primary: kPrimary, onPrimary: kWhite, surface: kWhite, onSurface: kBlack, background: Colors.white),
                              dialogBackgroundColor: kWhite,
                            ),
                            child: child!,
                          );
                        },
                      ).then((value) {
                        if (value != null) {
                          setState(() {
                            selectedDateFromPicker = DateTime(selectedDateFromPicker!.year, selectedDateFromPicker!.month, selectedDateFromPicker!.day, value.hour, value.minute);
                          });
                        }
                        saveData();

                        printOnDebug(selectedDateFromPicker.toString());
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      width: MediaQuery.of(context).size.width - 40,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: kBlack, width: 1),
                          // color: kLightGrey,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('${selectedDateFromPicker!.hour.toString().padLeft(2, '0')}h${selectedDateFromPicker!.minute.toString().padLeft(2, '0')}', style: const TextStyle(color: kLightGrey, fontSize: 16, fontWeight: FontWeight.w400)),

                          // Time picker
                          Icon(Icons.access_time_rounded, color: kBlack, size: 24),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text('Informations supplémentaires', style: TextStyle(fontSize: 18, color: kBlack, fontWeight: FontWeight.w500)),

                  TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    focusNode: _infoFocusNode,
                    style: const TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w400),
                    minLines: 1,
                    maxLines: 5,
                    maxLength: 200,
                    controller: moreInfosController,
                    textInputAction: TextInputAction.done,
                    onTapOutside: (event) {
                      FocusScope.of(context).unfocus();
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
                      hintText: moreInfosController.text.isEmpty ? 'Informations supplémentaires' : moreInfosController.text,
                      hintStyle: const TextStyle(color: kLightGrey, fontSize: 16, fontWeight: FontWeight.w400),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      filled: true,
                      fillColor: Colors.transparent,
                      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),

            const SizedBox(height: 150),
          ],
        ),
      ],
    );

    // Affichage du PopupMenuButton
  }

  Future<void> updateAllFields(DateTime selectedDateFromPicker) async {
    if (placeNameController.text != '') {
      widget.module.placeName = placeNameController.text;
      await context.read<ModulesController>().updatePlaceName(moduleId: widget.module.id, placeName: placeNameController.text).then((value) {
        const SnackBar(content: Text('Nom du lieu mis à jour'));
      });

      if (widget.module.type == "wedding") {
        await context.read<ModulesController>().updateInvitationCardDateTime(placeNameController.text, selectedDateFromPicker);
      }
    }

    if (selectedDateFromPicker != widget.module.date) {
      widget.module.date = selectedDateFromPicker;
      await context.read<ModulesController>().updateDate(newDateTime: selectedDateFromPicker, moduleId: widget.module.id);

      if (widget.module.type == "wedding") {
        await context.read<ModulesController>().updateInvitationCardDateTime(placeNameController.text, selectedDateFromPicker);
        Event.instance.date = DateTime(selectedDateFromPicker.year, selectedDateFromPicker.month, selectedDateFromPicker.day, selectedDateFromPicker.hour, selectedDateFromPicker.minute, selectedDateFromPicker.second);

        context.read<EventsController>().updateEvent(Event.instance);

        await context.read<EventsController>().updateEventFields(fieldsToUpdate: {'date': Event.instance.date.toString()}, eventId: Event.instance.id);
      }
    }

    widget.module.moreInfos = moreInfosController.text;
    await context.read<ModulesController>().updateMoreInfos(moreInfos: moreInfosController.text, moduleId: widget.module.id);

    if (!mounted) return;
    context.read<EventsController>().updateModules(await context.read<ModulesController>().getModules(Event.instance.id));
  }
}
