import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/contacts.dart';
import 'package:kapstr/widgets/layout/spacing.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:provider/provider.dart';

class PhoneContactsList extends StatefulWidget {
  final List<Contact> phoneContacts;
  final List<Contact> selectedContactsFromPhone;
  final bool isFiltered;
  final String searchQuery;

  const PhoneContactsList({super.key, required this.phoneContacts, required this.selectedContactsFromPhone, required this.isFiltered, required this.searchQuery});

  @override
  State<PhoneContactsList> createState() => _PhoneContactsListState();
}

class _PhoneContactsListState extends State<PhoneContactsList> {
  TextEditingController searchController = TextEditingController();
  bool isFiltered = false;
  @override
  Widget build(BuildContext context) {
    // Créez une copie de la liste de contacts pour la trier
    List<Contact> contactsToDisplay = List.from(widget.phoneContacts);

    // Triez la liste en fonction du nom des contacts
    contactsToDisplay.sort((a, b) => a.displayName?.toLowerCase().compareTo(b.displayName!.toLowerCase()) ?? 0);

    // Appliquez le filtre de recherche si nécessaire
    if (widget.isFiltered) {
      contactsToDisplay = contactsToDisplay.where((contact) => contact.displayName?.toLowerCase().contains(widget.searchQuery.toLowerCase()) ?? false).toList();
    }
    return ListView.builder(
      shrinkWrap: true,
      itemCount: contactsToDisplay.length,
      itemBuilder: (context, index) {
        Contact contact = contactsToDisplay[index];
        List<String> nameParts = contact.displayName?.split(' ') ?? [];

        return GestureDetector(
          onTap: () {
            toggleContacts(contact);
          },
          child: Row(
            children: [
              // Checkbox
              Checkbox(
                fillColor: WidgetStateProperty.resolveWith((states) => widget.selectedContactsFromPhone.contains(contact) ? kYellow : kLighterGrey),
                side: const BorderSide(color: kLighterGrey),
                checkColor: kWhite,
                activeColor: kYellow,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                value: widget.selectedContactsFromPhone.contains(contact),
                onChanged: (bool? value) {
                  toggleContacts(contact);
                },
              ),
              // Name
              Expanded(
                child: Row(
                  children: [
                    Text(nameParts.isNotEmpty ? nameParts[0] : '', style: TextStyle(color: kBlack, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize, fontWeight: FontWeight.w300)),
                    xSmallSpacerW(),
                    Text(nameParts.length > 1 ? nameParts[1].toUpperCase() : '', style: TextStyle(fontWeight: FontWeight.bold, color: kBlack, fontSize: Theme.of(context).textTheme.titleSmall!.fontSize)),
                  ],
                ),
              ),
              // Phone Number
              Container(margin: const EdgeInsets.only(right: 10), child: Text(contact.phones?.isNotEmpty ?? false ? '${contact.phones!.first.value}' : '', style: TextStyle(color: kBlack, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize, fontWeight: FontWeight.w300))),
            ],
          ),
        );
      },
    );
  }

  void toggleContacts(Contact contact) {
    context.read<ContactsController>().toggleContacts(contact);
  }
}
