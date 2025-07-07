import 'package:flutter/material.dart';
import 'package:kapstr/controllers/contacts.dart';
import 'package:kapstr/views/organizer/guest_manager/import_contacts/contact_row.dart';
import 'package:kapstr/views/organizer/guest_manager/import_contacts/contacts_list.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/guests_manager/search_bar.dart';
import 'package:provider/provider.dart';

class ImportContact extends StatefulWidget {
  const ImportContact({super.key});

  @override
  State<StatefulWidget> createState() => _ImportContactState();
}

class _ImportContactState extends State<ImportContact> {
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactsController>(
      builder: (context, phoneContactsProvider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: kWhite,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 75,
            toolbarHeight: 40,
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: GestureDetector(onTap: () => Navigator.of(context).pop(), child: const Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: kBlack), Text('Retour', style: TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w500))])),
            ),
            actions: const [SizedBox(width: 91)],
          ),
          resizeToAvoidBottomInset: true,
          bottomNavigationBar: ImportContactRow(phoneContacts: phoneContactsProvider.selectedContacts),
          backgroundColor: kWhite,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('Importer des contacts', textAlign: TextAlign.left, style: TextStyle(fontSize: 24, color: kBlack, fontWeight: FontWeight.w600))),
              const SizedBox(height: 12.0),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: SearchBarGuest(searchController: searchController)),
              const SizedBox(height: 12.0),
            ],
          ),
        );
      },
    );
  }
}
