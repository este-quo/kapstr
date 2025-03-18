import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/widgets/layout/spacing.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/organizer/guest_manager/import_contacts/button.dart';

class ImportContactRow extends StatefulWidget {
  final List<Contact> phoneContacts;

  const ImportContactRow({super.key, required this.phoneContacts});

  @override
  State<ImportContactRow> createState() => _ImportContactRowState();
}

class _ImportContactRowState extends State<ImportContactRow> {
  @override
  Widget build(BuildContext context) {
    List<Contact> selectedContacts = widget.phoneContacts;

    return Container(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: kGrey.withOpacity(0.2)))),
      padding: const EdgeInsets.only(top: 12, bottom: 24, right: 16, left: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 5, child: ImportContactButton(selectedContacts: selectedContacts)),
          smallSpacerW(),
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: kYellow), borderRadius: BorderRadius.circular(8)),
              height: 46,
              width: 46,
              child: Center(child: Text(textAlign: TextAlign.center, selectedContacts.length.toString(), style: const TextStyle(color: kYellow, fontSize: 16, fontWeight: FontWeight.w400))),
            ),
          ),
        ],
      ),
    );
  }
}
