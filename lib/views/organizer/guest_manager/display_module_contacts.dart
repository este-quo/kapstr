import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/guest.dart';
import 'package:kapstr/controllers/guests.dart';
import 'package:kapstr/controllers/modules/modules.dart';
import 'package:kapstr/views/global/credits/credits.dart';
import 'package:kapstr/widgets/dialogs/confirmation_dialog.dart';
import 'package:kapstr/widgets/guests_manager/send_invitation.dart';
import 'package:kapstr/widgets/layout/spacing.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/guests_manager/dropdown.dart';
import 'package:kapstr/widgets/guests_manager/module_guest_list.dart';
import 'package:kapstr/widgets/guests_manager/search_bar.dart';
import 'package:kapstr/widgets/guests_manager/select_all.dart';
import 'package:provider/provider.dart';

class DisplayModuleContacts extends StatefulWidget {
  final String moduleId;
  final String moduleName;
  const DisplayModuleContacts({super.key, required this.moduleId, required this.moduleName});

  @override
  State<StatefulWidget> createState() => _DisplayModuleContactsState();
}

class _DisplayModuleContactsState extends State<DisplayModuleContacts> {
  TextEditingController searchController = TextEditingController();
  bool isFiltered = false;
  bool isAllSelected = false;
  String currentAvailability = 'Tous';

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        isFiltered = searchController.text.isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!Event.instance.isUnlocked) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text("Pour partager votre invitation, et obtenir votre code invité, veuillez activer votre événement.", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black))),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (context.read<UsersController>().user!.credits > 0) {
                    showDialog(
                      context: context,
                      builder:
                          (context) => ConfirmationDialog(
                            title: "Activer l'événement",
                            confirmationText: "Utiliser 1 crédit",
                            cancelText: "Annuler",
                            onPressed: () async {
                              await context.read<EventsController>().updateEventField(key: 'isUnlocked', value: true);
                              int credits = context.read<UsersController>().user!.credits - 1;
                              await context.read<UsersController>().updateUserFields({'credits': credits});

                              Navigator.pop(context);
                              setState(() {
                                Event.instance.isUnlocked = true;
                              });
                            },
                          ),
                    );
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CreditsPage(isCreditsEmpty: true)));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                child: const Text("Activer mon événement", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Consumer<GuestsController>(
        builder: (context, guestProvider, child) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            floatingActionButton:
                guestProvider.selectedGuests.isNotEmpty
                    ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (context.watch<EventsController>().event.visibility == 'public') SendInvitationButton(isPublic: true),
                        if (context.watch<EventsController>().event.visibility == 'private' && context.watch<GuestsController>().selectedGuests.isNotEmpty)
                          SendInvitationButton(recipients: context.watch<GuestsController>().selectedGuests.map((guest) => guest.phone).cast<String>().toList(), isPublic: false),
                        TextButton(
                          onPressed: (() async {
                            bool confirm = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: kWhite,
                                  surfaceTintColor: kWhite,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  title: const Text('Confirmation'),
                                  content: Text(
                                    guestProvider.selectedGuests.length > 1 ? 'Etes-vous sûr de vouloir retirer ${guestProvider.selectedGuests.length} invités de ${widget.moduleName} ?' : 'Etes-vous sûr de vouloir retirer ${guestProvider.selectedGuests.length} invité de ${widget.moduleName} ?',
                                  ),
                                  actions: <Widget>[TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')), TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Confirmer'))],
                                );
                              },
                            );

                            if (confirm) {
                              for (Guest guest in guestProvider.selectedGuests) {
                                Event.instance.guests.where((element) => element.phone == guest.phone).forEach((element) {
                                  element.allowedModules.remove(widget.moduleId);
                                });
                                context.read<GuestsController>().disallowModule(guest.id, widget.moduleId);
                              }
                              context.read<GuestsController>().unselectAllGuest();
                              setState(() {});
                            }
                          }),
                          child: Text(
                            guestProvider.selectedGuests.length > 1 ? 'Retirer ${guestProvider.selectedGuests.length} invités de ${widget.moduleName}' : 'Retirer ${guestProvider.selectedGuests.length} invité de ${widget.moduleName}',
                            style: const TextStyle(overflow: TextOverflow.ellipsis, color: kDanger, fontSize: 16.0, fontWeight: FontWeight.w400),
                          ),
                        ),
                        SizedBox(height: Platform.isAndroid ? 0 : 48),
                      ],
                    )
                    : const SizedBox(),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            body: Column(
              children: [
                largeSpacerH(),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [Expanded(child: SearchBarGuest(searchController: searchController))])),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: DropDownAvailability(
                    onAvailabilityChanged: (String newAvailability) {
                      setState(() {
                        currentAvailability = newAvailability;
                        // Trigger a refresh in ModuleGuestList if necessary
                      });
                    },
                  ),
                ),
                smallSpacerH(),
                Expanded(
                  child: Consumer<ModulesController>(
                    builder: (context, moduleProvider, child) {
                      List<Guest> moduleGuests = moduleProvider.getModuleGuests(widget.moduleId);
                      return Column(
                        children: [
                          moduleGuests.isNotEmpty ? SelectAllGuestsButton(guests: moduleGuests) : const SizedBox(),
                          ModuleGuestList(moduleGuests: moduleGuests, moduleName: widget.moduleName, moduleId: widget.moduleId, isFiltered: isFiltered, searchQuery: searchController.text, currentAvailability: currentAvailability),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
