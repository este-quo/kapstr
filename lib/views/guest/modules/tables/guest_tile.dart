import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/guest.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:provider/provider.dart';

class GuestTile extends StatelessWidget {
  const GuestTile({super.key, required this.guestId, this.isPreview = false});

  final String guestId;
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    Guest guest;

    if (isPreview) {
      // Use fake guest data for preview
      guest = Guest(id: guestId, name: 'Invité', imageUrl: '', tableId: '', phone: '', postedPictures: [], hasJoined: false, userId: '', allowedModules: []);
    } else {
      // Use real guest data when not in preview
      guest = Event.instance.guests.firstWhere((guest) => guest.id == guestId);
    }

    String globalGuestInitial = guest.name.split(' ').map((word) => word.isNotEmpty ? word[0] : '').take(2).join().toUpperCase();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
      width: MediaQuery.of(context).size.width - 40,
      height: 64,
      decoration: BoxDecoration(color: context.watch<EventsController>().event.fullResThemeUrl == '' ? kWhite : kWhite.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8), border: Border.all(color: kBlack.withValues(alpha: 0.1), width: 1, strokeAlign: BorderSide.strokeAlignOutside)),
      child: Center(
        child: ListTile(
          textColor: kBlack,
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: (guest.imageUrl.isEmpty) ? kLightGrey : Colors.transparent,
            backgroundImage: (guest.imageUrl.isNotEmpty) ? NetworkImage(guest.imageUrl) : null,
            child: (guest.imageUrl.isEmpty) ? Text(globalGuestInitial, style: const TextStyle(color: kWhite, fontSize: 18)) : null,
          ),
          title: Text(guest.name, style: TextStyle(color: Event.instance.textColor == '' ? kBlack : Color(int.parse('0xFF${Event.instance.textColor}')), fontSize: 16, fontWeight: FontWeight.w400)),
        ),
      ),
    );
  }
}
