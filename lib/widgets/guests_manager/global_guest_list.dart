import 'package:flutter/material.dart';
import 'package:kapstr/components/dialogs/guest.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/guest.dart';
import 'package:kapstr/controllers/guests.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/organizer/guest_manager/guest_profile.dart';
import 'package:kapstr/widgets/guests_manager/checkbox.dart';
import 'package:provider/provider.dart';

class GlobalGuestsList extends StatefulWidget {
  final bool isFiltered;
  final String searchQuery;

  const GlobalGuestsList({super.key, required this.isFiltered, required this.searchQuery});

  @override
  State<GlobalGuestsList> createState() => _GlobalGuestsListState();
}

class _GlobalGuestsListState extends State<GlobalGuestsList> {
  @override
  Widget build(BuildContext context) {
    ScrollController controller = ScrollController();

    return Consumer<GuestsController>(
      builder: (context, guestProvider, child) {
        List<Guest> guests = guestProvider.eventGuests;

        // Filtrer les invités en fonction de la requête de recherche si nécessaire
        if (widget.isFiltered) {
          guests =
              guests.where((guest) {
                final guestName = guest.name.toLowerCase();
                final query = widget.searchQuery.toLowerCase();
                return guestName.contains(query);
              }).toList();
        }

        return Expanded(
          child:
              guests.isNotEmpty
                  ? ListView.separated(
                    padding: const EdgeInsets.only(bottom: 92),
                    shrinkWrap: true,
                    controller: controller,
                    separatorBuilder: (context, index) => Divider(color: kLightGrey.withValues(alpha: 0.2), thickness: 1),
                    itemCount: guests.length,
                    itemBuilder: (context, index) {
                      Guest guest = guests[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => GlobalGuestProfile(guest: guest)));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // Checkbox du guest
                              MyCheckbox(
                                guest: guest,
                                onChanged: (bool? value) {
                                  context.read<GuestsController>().toggleGuest(guest.id);
                                },
                                isSelected: guest.isSelected,
                              ),

                              const SizedBox(width: 12),

                              // Nom du guest
                              Text(guest.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: kBlack)),

                              SizedBox(width: 12),

                              Container(width: 10, height: 10, decoration: BoxDecoration(color: guest.hasJoined ? kPresent : kWaiting, borderRadius: BorderRadius.circular(200))),

                              Expanded(child: SizedBox()),

                              Event.instance.organizerAdded.contains(guest.phone) ? Icon(Icons.admin_panel_settings_outlined) : SizedBox(),

                              IconButton(
                                onPressed: () async {
                                  await showGuestDialog(context, guest);
                                  setState(() {});
                                },
                                icon: Icon(Icons.more_vert_rounded),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                  : Center(
                    child:
                        context.watch<EventsController>().event.visibility == 'private'
                            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('Vous n\'avez pas encore d\'invités', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: kBlack)), const SizedBox(height: 16)])
                            : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Vous n\'avez pas encore d\'invités, partagez le code d\'invitation pour en inviter !', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: kBlack))]),
                  ),
        );
      },
    );
  }
}
