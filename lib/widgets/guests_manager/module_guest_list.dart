import 'package:flutter/material.dart';
import 'package:kapstr/controllers/rsvps.dart';
import 'package:kapstr/helpers/sizer.dart';
import 'package:kapstr/models/guest.dart';
import 'package:kapstr/controllers/guests.dart';
import 'package:kapstr/models/rsvp.dart';
import 'package:kapstr/widgets/guests_manager/checkbox.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/organizer/guest_manager/guest_profile/guest_profile.dart';
import 'package:provider/provider.dart';

class ModuleGuestList extends StatefulWidget {
  final List<Guest> moduleGuests;
  final String moduleName;
  final String moduleId;
  final bool isFiltered;
  final String searchQuery;
  final String currentAvailability;

  const ModuleGuestList({super.key, required this.moduleGuests, required this.moduleName, required this.moduleId, required this.isFiltered, required this.searchQuery, required this.currentAvailability});

  @override
  State<ModuleGuestList> createState() => _ModuleGuestListState();
}

class _ModuleGuestListState extends State<ModuleGuestList> {
  List<Guest> filteredModuleGuests = [];

  @override
  void initState() {
    super.initState();
    filterGuests();
    context.read<RSVPController>().fetchAllRsvps();
  }

  void filterGuests() async {
    var filteredList = <Guest>[];

    // If not filtering, set all guests to filtered list.
    if (!widget.isFiltered) {
      filteredList = widget.moduleGuests;
    } else {
      // Apply search query filter.
      filteredList = widget.moduleGuests.where((guest) => guest.name.toLowerCase().contains(widget.searchQuery.toLowerCase())).toList();
    }

    // If the current availability is not 'Tous', further filter the guests.
    if (widget.currentAvailability != 'Tous') {
      List<Guest> tempFilteredList = [];
      for (var guest in filteredList) {
        RSVP? rsvp = context.read<RSVPController>().getRsvpByIds(guest.id, widget.moduleId);

        // Filter based on RSVP response, comparing to current availability.
        if (rsvp != null && rsvp.response == widget.currentAvailability) {
          tempFilteredList.add(guest);
        }
      }
      filteredList = tempFilteredList;
    }

    setState(() {
      filteredModuleGuests = filteredList..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  @override
  void didUpdateWidget(covariant ModuleGuestList oldWidget) {
    super.didUpdateWidget(oldWidget);
    filterGuests();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RSVPController>(
      builder: (context, rsvpController, child) {
        return Expanded(
          child: ListView.separated(
            padding: EdgeInsets.only(bottom: 92),
            separatorBuilder: (context, index) => Divider(color: kLightGrey.withValues(alpha: 0.2), thickness: 1),
            shrinkWrap: true,
            itemCount: filteredModuleGuests.length,
            itemBuilder: (context, index) {
              var moduleGuest = filteredModuleGuests[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => GuestProfile(guest: moduleGuest, moduleName: widget.moduleName, moduleId: widget.moduleId)));
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, left: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Checkbox du guest
                      MyCheckbox(
                        guest: moduleGuest,
                        onChanged: ((value) {
                          context.read<GuestsController>().toggleGuest(moduleGuest.id);
                        }),
                        isSelected: moduleGuest.isSelected,
                      ),
                      const SizedBox(width: 12),
                      // Nom du guest
                      Expanded(child: Text(moduleGuest.name, style: Sizer(context).scaleTextStyle(Theme.of(context).textTheme.bodyLarge!).copyWith(color: kBlack, fontWeight: FontWeight.w400))),
                      const SizedBox(width: 12),
                      // Status du guest
                      Container(width: Sizer(context).getIconButtonHeight() / 3, height: Sizer(context).getIconButtonHeight() / 3, decoration: BoxDecoration(color: getResponseColor(moduleGuest.id, widget.moduleId, context), borderRadius: BorderRadius.circular(20))),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Color getResponseColor(String id, String moduleId, BuildContext context) {
    RSVP? rsvp = context.read<RSVPController>().getRsvpByIds(id, moduleId);

    if (rsvp == null) {
      return kBlack;
    }

    if (rsvp.response == 'Accepté') {
      return kSuccess;
    } else if (rsvp.response == 'Absent') {
      return kDanger;
    } else if (rsvp.response == 'En attente') {
      return const Color.fromARGB(255, 224, 146, 28);
    }

    return kYellow;
  }
}
