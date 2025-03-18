import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/guests.dart';
import 'package:kapstr/controllers/contacts.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/views/global/in_app_purchase/purchase.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:provider/provider.dart';

class ImportContactButton extends StatefulWidget {
  final List<Contact> selectedContacts;

  const ImportContactButton({super.key, required this.selectedContacts});

  @override
  State<ImportContactButton> createState() => _ImportContactButtonState();
}

class _ImportContactButtonState extends State<ImportContactButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    List<Contact> selectedContacts = widget.selectedContacts;

    Color eventButtonColor = kBlack;

    return TextButton(
      onPressed: () async {
        triggerShortVibration();
        setState(() {
          _isLoading = true;
        });

        List<String> allowedModules = [];
        int totalGuests = Event.instance.guests.length + selectedContacts.length;

        // Define the guest limits for each plan
        int guestLimit;
        switch (Event.instance.plan) {
          case 'free_plan':
            guestLimit = 30;
            break;
          case 'kapstr_basic_plan':
            guestLimit = 100;
            break;
          case 'kapstr_premium_plan':
            guestLimit = 150;
            break;
          case 'kapstr_premium_plus_plan':
            guestLimit = 300;
            break;
          case 'kapstr_unlimited_plan':
            guestLimit = double.infinity.toInt(); // Unlimited guests
            break;
          default:
            guestLimit = 30; // Default guest limit if no plan matches
        }

        // Check if total guests exceed the limit
        if (totalGuests > guestLimit) {
          setState(() {
            _isLoading = false;
          });
          // Display a message or handle the exceeded guest limit case here
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le nombre total d\'invités dépasse la limite autorisée pour ce plan')));

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            elevation: 0,
            builder:
                (context) => DraggableScrollableSheet(
                  initialChildSize: 1,
                  minChildSize: 1,
                  maxChildSize: 1,
                  builder: (context, scrollController) {
                    return const PurchaseScreen();
                  },
                ),
          );

          return; // Stop the logic
        }

        await context.read<GuestsController>().createGuest(selectedContacts, allowedModules);

        if (context.mounted) {
          await context.read<GuestsController>().getGuests(Event.instance.id).then((guests) {
            context.read<GuestsController>().addGuestsToEvent(guests, context);
            context.read<ContactsController>().clear();
          });
        }

        if (!mounted) return;
        Navigator.pop(context);
      },
      style: ButtonStyle(padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12, horizontal: 20)), backgroundColor: WidgetStateProperty.all(eventButtonColor), shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))),
      child:
          _isLoading
              ? const SizedBox(height: 16, width: 16, child: Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_dark.svg', size: 64)))
              : Text(selectedContacts.length > 1 ? 'Importer contacts' : 'Importer contact', style: const TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w400)),
    );
  }
}
