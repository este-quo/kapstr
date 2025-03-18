import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/modules/modules.dart';
import 'package:kapstr/controllers/notification.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/views/organizer/home/configuration.dart';
import 'package:kapstr/views/organizer/modules/update_module/place_picker.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UpdateModuleInfos extends StatefulWidget {
  final Module module;
  const UpdateModuleInfos({super.key, required this.module});

  @override
  UpdateModuleInfosState createState() => UpdateModuleInfosState();
}

class UpdateModuleInfosState extends State<UpdateModuleInfos> {
  TextEditingController placeNameController = TextEditingController();
  TextEditingController moreInfosController = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  final FocusNode _infoFocusNode = FocusNode();

  final moduleNameFocusNode = FocusNode();
  final modulePlaceFocusNode = FocusNode();
  DateTime? selectedDateFromPicker;

  @override
  void initState() {
    super.initState();

    selectedDateFromPicker = widget.module.date ?? DateTime.now();

    placeNameController = TextEditingController(text: widget.module.placeName == "Nom du lieu" ? "" : widget.module.placeName);

    moreInfosController = TextEditingController(text: widget.module.moreInfos == 'Plus d\'informations' ? "" : widget.module.moreInfos);
  }

  @override
  void dispose() {
    _infoFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Module module = widget.module;

    printOnDebug(module.placeAddress!);

    return Container(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Title
              const SizedBox(height: 16),

              const Text('Date', style: TextStyle(fontSize: 18, color: kBlack, fontWeight: FontWeight.w500)),

              // Date selector
              Container(
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
                    Text(DateFormat('dd/MM/yyyy').format(selectedDateFromPicker!), style: const TextStyle(color: kLightGrey, fontSize: 16, fontWeight: FontWeight.w400)),

                    // Date picker
                    // Date picker
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
                                  initialDateTime: selectedDateFromPicker!,
                                  onDateTimeChanged: (DateTime newDate) {
                                    setState(() {
                                      selectedDateFromPicker = newDate;
                                    });
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
                            initialDate: selectedDateFromPicker!,
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  dialogTheme: DialogTheme(backgroundColor: kWhite, surfaceTintColor: kWhite, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                  colorScheme: const ColorScheme.light(primary: kPrimary, onPrimary: kWhite, surface: kWhite, onSurface: kBlack),
                                  dialogBackgroundColor: kWhite,
                                ),
                                child: child!,
                              );
                            },
                          ).then((value) {
                            if (value != null) {
                              setState(() {
                                selectedDateFromPicker = value;
                              });
                            }
                            printOnDebug(selectedDateFromPicker.toString());
                          });
                        }
                      },
                      child: const Icon(Icons.calendar_month_outlined, color: kBlack, size: 24),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Time selector
              Container(
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
                          printOnDebug(selectedDateFromPicker.toString());
                        });
                      },
                      child: const Icon(Icons.access_time_rounded, color: kBlack, size: 24),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const Text('Lieu', style: TextStyle(fontSize: 18, color: kBlack, fontWeight: FontWeight.w500)),

              // Place name
              TextFormField(
                textCapitalization: TextCapitalization.sentences,
                focusNode: moduleNameFocusNode,
                style: const TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w400),
                controller: placeNameController,
                textInputAction: TextInputAction.done,
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
                  hintText: placeNameController.text.isEmpty ? 'Nom du lieu' : placeNameController.text,
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
                  showModalBottomSheet(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)), showDragHandle: true, context: context, builder: (context) => PlacePicker(module: module, moduleId: module.id, placeAdress: module.placeAddress ?? '')).then((value) {
                    if (value != null) {
                      setState(() {
                        module.placeAddress = value;
                      });
                    }
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: (const BoxDecoration(border: Border(bottom: BorderSide(color: kBlack, width: 1)))),
                  child: Text(
                    module.placeAddress == null || module.placeAddress == '' ? 'Adresse du lieu' : module.placeAddress!,
                    style: TextStyle(color: module.placeAddress == null || module.placeAddress == '' || module.placeAddress == 'Adresse du lieu' ? kLightGrey : kBlack, fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text('Informations supplémentaires', style: TextStyle(fontSize: 18, color: kBlack, fontWeight: FontWeight.w500)),

              //TODO: Bouton Valider
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

              const SizedBox(height: 92),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> updateAllFields(DateTime selectedDateFromPicker) async {
    if (placeNameController.text != '') {
      await context
          .read<ModulesController>()
          .updatePlaceName(moduleId: widget.module.id, placeName: placeNameController.text)
          .then((value) {
            const SnackBar(content: Text('Nom du lieu mis à jour'));
          })
          .onError((error, stackTrace) {
            const SnackBar(content: Text('Erreur lors de la mise à jour du nom du lieu'), backgroundColor: kDanger);
          });
    }

    if (!mounted) return;
    await context.read<ModulesController>().updateDate(newDateTime: selectedDateFromPicker, moduleId: widget.module.id);

    if (!mounted) return;
    await context.read<ModulesController>().updateMoreInfos(moreInfos: moreInfosController.text, moduleId: widget.module.id);

    if (!mounted) return;
    if (widget.module.type == "wedding") {
      await context.read<ModulesController>().updateInvitationCardDateTime(placeNameController.text, selectedDateFromPicker);
    }

    if (!mounted) return;
    context.read<EventsController>().updateModules(await context.read<ModulesController>().getModules(Event.instance.id));
  }
}
