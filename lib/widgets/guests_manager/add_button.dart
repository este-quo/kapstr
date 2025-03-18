import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/models/guest.dart';
import 'package:kapstr/controllers/contacts.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/helpers/delete_emoji.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../views/organizer/guest_manager/import_contacts/import_contacts.dart';

class PhoneContacts extends StatelessWidget {
  final VoidCallback onReturn;

  const PhoneContacts({super.key, required this.onReturn});

  @override
  Widget build(BuildContext context) {
    Color eventButtonColor = kBlack;

    return GestureDetector(
      onTap: () async {
        triggerShortVibration();
        await importContacts().then((value) {
          context.read<ContactsController>().addContacts(value);
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ImportContact())).then((value) => onReturn());
        });
      },
      child: Container(width: 36, height: 36, decoration: BoxDecoration(color: eventButtonColor, borderRadius: BorderRadius.circular(100)), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add, color: kWhite, size: 24)])),
    );
  }

  Future<List<Contact>> importContacts() async {
    List<Contact> verifiedContacts = [];
    List<Contact> formattedContacts = [];

    if (await Permission.contacts.request().isGranted) {
      List<Contact> contactsFromPhone = await ContactsService.getContacts(withThumbnails: false, photoHighResolution: false);
      List<Guest> guests = Event.instance.guests;
      List<Contact> contactsFromPhoneNonImported = [];

      for (var contact in contactsFromPhone) {
        if (contact.phones!.isNotEmpty) {
          bool isImported = false;
          for (var guest in guests) {
            if (guest.phone == contact.phones!.first.value) {
              isImported = true;
            }
          }
          if (!isImported) {
            contactsFromPhoneNonImported.add(contact);
          }
        }
      }

      verifiedContacts = contactsFromPhoneNonImported.where((e) => e.phones!.isNotEmpty && e.displayName != null).toList();

      formattedContacts =
          verifiedContacts.map((e) {
            e.displayName = deleteEmoji(e.displayName!);
            return e;
          }).toList();
    }
    return formattedContacts;
  }
}
