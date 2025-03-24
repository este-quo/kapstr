import 'package:flutter/material.dart';
import 'package:kapstr/models/guest.dart';
import 'package:kapstr/controllers/guests.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:provider/provider.dart';

class SelectAllGuestsButton<T extends ChangeNotifier> extends StatefulWidget {
  final List<dynamic> guests;

  const SelectAllGuestsButton({super.key, required this.guests});

  @override
  State<SelectAllGuestsButton> createState() => _SelectAllGuestsButtonState();
}

class _SelectAllGuestsButtonState extends State<SelectAllGuestsButton> {
  @override
  Widget build(BuildContext context) {
    bool areAllSelected = context.read<GuestsController>().areAllSelected(widget.guests as List<Guest>);

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (!areAllSelected) {
              unselectAllGuests();
            }
            for (Guest guest in widget.guests) {
              toggleGuests(guest.id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              children: [
                Checkbox(
                  fillColor: WidgetStateProperty.resolveWith((states) => areAllSelected ? kYellow : kLighterGrey),
                  side: const BorderSide(color: kLighterGrey),
                  checkColor: kWhite,
                  activeColor: kYellow,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.comfortable,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                  value: areAllSelected,
                  onChanged: null,
                ),
                const SizedBox(width: 12),
                widget.guests.isNotEmpty ? const Text('Tout sélectionner', style: TextStyle(fontSize: 16, color: kBlack, fontWeight: FontWeight.w400)) : const SizedBox(),
              ],
            ),
          ),
        ),
        Divider(color: kLightGrey.withValues(alpha: 0.2), thickness: 1),
      ],
    );
  }

  void toggleGuests(String guestID) {
    context.read<GuestsController>().toggleGuest(guestID);
  }

  void unselectAllGuests() {
    context.read<GuestsController>().unselectAllGuest();
  }
}
