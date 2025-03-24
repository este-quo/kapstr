import 'package:flutter/material.dart';
import 'package:kapstr/controllers/authentication.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/models/rsvp.dart';
import 'package:kapstr/views/global/login/login.dart';
import 'package:kapstr/views/guest/modules/response_test.dart';
import 'package:kapstr/views/guest/modules/view_manager.dart';
import 'package:kapstr/widgets/buttons/ic_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RsvpModuleCard extends StatelessWidget {
  final Module module;
  final RSVP rsvp;
  final Function callBack;

  const RsvpModuleCard({super.key, required this.module, required this.rsvp, required this.callBack});

  @override
  Widget build(BuildContext context) {
    String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

    String formatAndCapitalizeDate(DateTime date) {
      var formatter = DateFormat('EEEE d MMMM y', 'fr');
      var dateParts = formatter.format(date).split(' ');
      var capitalizedDateParts = dateParts.map((part) => capitalize(part)).toList();

      // Join the parts back together
      return capitalizedDateParts.join(' ');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24, right: 16, left: 16, top: 20),
      width: MediaQuery.of(context).size.width - 40,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: kBlack.withValues(alpha: 0.1), blurRadius: 20)]),
      child: Column(
        children: [
          // Image
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8, left: 8, right: 8),
            height: 290,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), image: DecorationImage(image: module.image != '' ? NetworkImage(module.image) : const AssetImage('assets/rsvp_placeholder.png') as ImageProvider, fit: BoxFit.cover)),
            child: const Text(""),
          ),

          // Infos
          Container(
            margin: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 24),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(module.name, style: const TextStyle(overflow: TextOverflow.ellipsis, color: kBlack, fontSize: 28, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),

                // Date
                Text(module.date != null ? "${formatAndCapitalizeDate(module.date!)} à ${DateFormat('H\'h\'m', 'fr').format(module.date!)}" : 'Date non communiquée', style: const TextStyle(overflow: TextOverflow.ellipsis, color: kPrimary, fontSize: 17, fontWeight: FontWeight.w500)),
                const SizedBox(height: 24),

                Column(
                  children: [
                    // Accept
                    IcButton(
                      backgroundColor: getButtonColor(rsvp.response),
                      borderColor: const Color.fromARGB(30, 0, 0, 0),
                      borderWidth: 1,
                      height: 48,
                      radius: 8,
                      onPressed: () async {
                        context.read<AuthenticationController>().setPendingConnection(true);
                        if (context.read<UsersController>().user == null) {
                          await showModalBottomSheet(
                            isScrollControlled: true,
                            isDismissible: true,
                            enableDrag: true,
                            context: context,
                            barrierColor: Colors.black.withValues(alpha: 0.3),
                            useSafeArea: true,
                            builder: (context) {
                              return DraggableScrollableSheet(
                                initialChildSize: 1,
                                minChildSize: 0.8,
                                maxChildSize: 1,
                                expand: false,
                                builder: (context, scrollController) {
                                  return const LogIn();
                                },
                              );
                            },
                          );
                        } else {
                          showModalBottomSheet(
                            elevation: 0,
                            backgroundColor: kWhite,
                            showDragHandle: true,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
                            context: context,
                            builder: (context) => ResponseTest(module: module, rsvp: rsvp),
                            isScrollControlled: true,
                          ).then((value) {
                            callBack(value);
                          });
                        }
                      },
                      child: getButtonText(rsvp),
                    ),
                    const SizedBox(height: 12),

                    // Refuse
                    IcButton(
                      backgroundColor: Colors.white,
                      borderColor: const Color.fromARGB(30, 0, 0, 0),
                      borderWidth: 1,
                      height: 48,
                      radius: 8,
                      onPressed: () async {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => buildGuestModuleView(module: module, isPreview: context.watch<EventsController>().isGuestPreview))).then((value) {
                          callBack();
                        });
                      },
                      child: const Text('Voir l\'événement', style: TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Text getButtonText(RSVP rsvp) {
  String response = rsvp.response;

  switch (response) {
    case 'Accepté':
      return Text('Présent · ${rsvp.adults.length + rsvp.children.length} personnes', style: const TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w500));
    case 'Absent':
      return const Text('Absent', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w500));
    default:
      return const Text('Répondre à l\'invitation', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w500));
  }
}

Color getButtonColor(String response) {
  switch (response) {
    case 'Accepté':
      return const Color.fromARGB(255, 74, 230, 60);
    case 'Absent':
      return kDanger;
    default:
      return kBlack;
  }
}
