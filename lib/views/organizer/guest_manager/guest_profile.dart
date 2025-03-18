import 'package:flutter/material.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/guest.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/controllers/guests.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:kapstr/widgets/layout/spacing.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/organizer/guest_manager/guest_profile/input_guest_profile.dart';
import 'package:provider/provider.dart';

class GlobalGuestProfile extends StatefulWidget {
  final Guest guest;

  const GlobalGuestProfile({super.key, required this.guest});

  @override
  State<StatefulWidget> createState() => _GlobalGuestProfileState();
}

class _GlobalGuestProfileState extends State<GlobalGuestProfile> {
  TextEditingController guestNameController = TextEditingController();
  TextEditingController guestPhoneController = TextEditingController();
  Map<String, bool> moduleSelections = {};

  List<Module> modulesAllowingGuests = Event.instance.modulesAllowingGuest.where((element) => !kNonEventModules.contains(element.type)).toList();

  late Map<String, dynamic> selectedModules;

  late String radioButtonValue = '';

  @override
  void dispose() {
    guestNameController.dispose();
    guestPhoneController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    guestNameController.text = widget.guest.name;
    guestPhoneController.text = widget.guest.phone;

    // Initialize module selections based on the guest's allowed modules
    for (var module in Event.instance.modulesAllowingGuest) {
      moduleSelections[module.id] = widget.guest.allowedModules.contains(module.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    Guest guest = widget.guest;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Validation button
          MainButton(
            onPressed: () async {
              triggerShortVibration();

              var selectedModuleIds = moduleSelections.entries.where((entry) => entry.value).map((entry) => entry.key).toList();

              await context.read<GuestsController>().updateGlobalGuestInfos(newGuestPhone: guestPhoneController.text, guestId: guest.id, guestName: guestNameController.text, guestPhone: widget.guest.phone, allowedModules: selectedModuleIds);

              if (!mounted) return;
              context.read<GuestsController>().updateGuest({'name': guestNameController.text, 'phone': guestPhoneController.text, 'allowed_modules': selectedModuleIds}, guest.id);

              Navigator.pop(context);
            },
            child: const Text('Sauvegarder', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kWhite)),
          ),
          const SizedBox(height: 12),
          Center(
            child: GestureDetector(
              onTap: () async {
                // Show a confirmation dialog before deleting
                bool? confirmDelete = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: kWhite,
                      surfaceTintColor: kWhite,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      title: const Text('Confirmer la suppression', style: TextStyle(color: kBlack, fontSize: 18, fontWeight: FontWeight.w700)),
                      content: const Text('Êtes-vous sûr de vouloir supprimer cet invité ?'),
                      actions: <Widget>[
                        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler', style: TextStyle(color: kBlack, fontSize: 16))),
                        TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Supprimer', style: TextStyle(color: Colors.red, fontSize: 16))),
                      ],
                    );
                  },
                );

                // Proceed with delete if confirmed
                if (confirmDelete ?? false) {
                  await context.read<GuestsController>().deleteGuest(guest.id);
                  Event.instance.guests.removeWhere((element) => element.id == widget.guest.id);
                  if (!mounted) return;
                  Navigator.pop(context);
                }
              },
              child: const Text('Supprimer l\'invité', style: TextStyle(color: kDanger, fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Profil de l\'invité', textAlign: TextAlign.left, style: TextStyle(fontSize: 24, color: kBlack, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),

              // Subtitle
              const Text('Les informations de l’invité seront mises à jour avec les informations de son compte lorsqu\'il aura rejoint.', textAlign: TextAlign.left, style: TextStyle(fontSize: 14, color: kBlack, fontWeight: FontWeight.w400)),

              const SizedBox(height: 16),
              InputGuestProfile(controller: guestNameController, hintText: 'Nom de l\'invité'),
              const SizedBox(height: 12),

              InputGuestProfile(controller: guestPhoneController, hintText: 'Téléphone de l\'invité'),

              const SizedBox(height: 24),

              const Text('Invité à :', textAlign: TextAlign.left, style: TextStyle(fontSize: 18, color: kBlack, fontWeight: FontWeight.w500)),

              ListView.builder(
                shrinkWrap: true,
                itemCount: modulesAllowingGuests.length,
                itemBuilder: (BuildContext context, int index) {
                  var module = modulesAllowingGuests[index];
                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    checkColor: kWhite,
                    activeColor: kPrimary,
                    title: Text(module.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: kBlack)),
                    value: moduleSelections[module.id] ?? false,
                    onChanged: (bool? newValue) {
                      setState(() {
                        moduleSelections[module.id] = newValue ?? false;
                      });
                    },
                  );
                },
              ),

              kNavBarSpacer(context),
            ],
          ),
        ),
      ),
    );
  }
}
