import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/components/copy_code.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/guests.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/global/credits/credits.dart';
import 'package:kapstr/views/organizer/guest_manager/delete_guests.dart';

import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:kapstr/widgets/guests_manager/search_bar.dart';
import 'package:kapstr/widgets/layout/spacing.dart';
import 'package:kapstr/widgets/guests_manager/global_guest_list.dart';
import 'package:kapstr/widgets/guests_manager/add_button.dart';
import 'package:kapstr/widgets/guests_manager/select_all.dart';
import 'package:kapstr/widgets/guests_manager/send_invitation.dart';
import 'package:provider/provider.dart';

class DisplayAllContacts extends StatefulWidget {
  const DisplayAllContacts({super.key});

  @override
  State<StatefulWidget> createState() => _DisplayAllContactsState();
}

class _DisplayAllContactsState extends State<DisplayAllContacts> {
  TextEditingController searchController = TextEditingController();
  bool isFiltered = false;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        isFiltered = searchController.text.isNotEmpty;
      });
    });
  }

  void _showUseCreditDialog(BuildContext context, int availableCredits) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Utiliser 1 crédit", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(availableCredits > 1 ? "Vous avez $availableCredits crédits. Un crédit sera utilisé pour activer cet évènement." : "Vous avez $availableCredits crédit. Il sera utilisé pour activer cet évènement.", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              MainButton(
                backgroundColor: kPrimary,
                onPressed: () async {
                  await context.read<EventsController>().updateEventField(key: 'isUnlocked', value: true);
                  int credits = context.read<UsersController>().user!.credits - 1;
                  await context.read<UsersController>().updateUserFields({'credits': credits});

                  Navigator.pop(context);
                  setState(() {
                    Event.instance.isUnlocked = true;
                  });
                },
                child: const Text("Confirmer", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = context.watch<EventsController>().event;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        floatingActionButton:
            event.isUnlocked
                ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CopyCodeButton(code: event.code),
                    const SizedBox(height: 15),
                    if (event.visibility == 'public') const SendInvitationButton(isPublic: true),
                    if (event.visibility == 'private' && context.watch<GuestsController>().selectedGuests.isNotEmpty) SendInvitationButton(recipients: context.watch<GuestsController>().selectedGuests.map((guest) => guest.phone).cast<String>().toList(), isPublic: false),
                    const DeleteGuestsButton(),
                    SizedBox(height: Platform.isAndroid ? 0 : 48),
                  ],
                )
                : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        body:
            event.isUnlocked
                ? Column(
                  children: [
                    largeSpacerH(),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [Expanded(child: SearchBarGuest(searchController: searchController)), const SizedBox(width: 12), event.visibility == 'public' ? const SizedBox() : PhoneContacts(onReturn: () {})])),
                    smallSpacerH(),
                    Expanded(
                      child: Column(
                        children: [
                          smallSpacerH(),
                          Consumer<GuestsController>(
                            builder: (context, guestProvider, child) {
                              return guestProvider.eventGuests.isNotEmpty ? SelectAllGuestsButton(guests: guestProvider.eventGuests) : const SizedBox();
                            },
                          ),
                          GlobalGuestsList(isFiltered: isFiltered, searchQuery: searchController.text),
                        ],
                      ),
                    ),
                  ],
                )
                : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Pour partager votre invitation, et obtenir votre code invité, veuillez activer votre évènement", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black)),
                      const SizedBox(height: 20),
                      MainButton(
                        backgroundColor: kPrimary,
                        onPressed: () {
                          final credits = context.read<UsersController>().user!.credits;
                          if (credits > 0) {
                            _showUseCreditDialog(context, credits);
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const CreditsPage(isCreditsEmpty: true)));
                          }
                        },
                        child: const Text("Activer mon évènement", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
