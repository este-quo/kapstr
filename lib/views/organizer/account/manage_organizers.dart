import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kapstr/components/dialogs/organizer_sms_dialog.dart';
import 'package:kapstr/controllers/contacts.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/guests.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/helpers/format_phone_number.dart';
import 'package:kapstr/helpers/share_app.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/guest.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/global/events/create/completed.dart';
import 'package:kapstr/views/organizer/guest_manager/share_button.dart';
import 'package:kapstr/widgets/buttons/ic_button.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:kapstr/widgets/guests_manager/add_button.dart';
import 'package:kapstr/widgets/guests_manager/search_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ManageOrganizers extends StatefulWidget {
  const ManageOrganizers({super.key, required this.isOnboarding});

  final bool isOnboarding;

  @override
  State<ManageOrganizers> createState() => _ManageOrganizersState();
}

class _ManageOrganizersState extends State<ManageOrganizers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          MainButton(child: const Center(child: Text('Ajouter un Organisateur', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w400))), onPressed: () => !widget.isOnboarding ? _showGuestsDialog(context) : _showGuestsDialogOnboarding(context)),
          const SizedBox(height: 8),
          widget.isOnboarding
              ? MainButton(
                backgroundColor: Colors.white,
                child: const Center(child: Text('Suivant', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400))),
                onPressed: () async {
                  triggerShortVibration();

                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const OnboardingComplete()), (Route<dynamic> route) => route.isFirst);
                },
              )
              : const SizedBox(),
        ],
      ),
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 75,
        toolbarHeight: 40,
        centerTitle: true,
        title: !widget.isOnboarding ? const SizedBox() : const Text('Organisateurs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: kBlack)),
        leading:
            !widget.isOnboarding
                ? Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: GestureDetector(onTap: () => Navigator.of(context).pop(), child: const Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: kBlack), Text('Retour', style: TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w500))])),
                )
                : const SizedBox(),
        actions: [
          !widget.isOnboarding
              ? const SizedBox(width: 91)
              : IconButton(
                icon: const Icon(Icons.close, color: kBlack),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
        ],
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: kWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            widget.isOnboarding ? const SizedBox() : const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('Mes co-organisateurs', textAlign: TextAlign.left, style: TextStyle(fontSize: 24, color: kBlack, fontWeight: FontWeight.w600))),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Les co-organisateurs peuvent modifier les détails de l\'événement et inviter d\'autres personnes.', style: TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w400)), SizedBox(height: 8)]),
                  ),
                  const SizedBox(height: 12),
                  _buildOrganizerSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGuestsDialog(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    showModalBottomSheet(
      elevation: 0,
      backgroundColor: kWhite,
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          builder: (_, scrollController) {
            return GuestListBottomSheet(searchController: searchController);
          },
        );
      },
    ).then((value) => setState(() {}));
  }

  Future _addOrganizer(String guestPhone, BuildContext context) async {
    Event.instance.addOrganizer(guestPhone);

    context.read<EventsController>().updateEventField(key: 'organizer_to_add', value: Event.instance.organizerToAdd);

    //Envoyer SMS
    await sendSMS([guestPhone], getCoOrganizerMessage(Event.instance.eventType));
    setState(() {});
  }

  void _removeOrganizerToAdd(String guestPhone) {
    Event.instance.removeOrganizerToAdd(guestPhone);

    context.read<EventsController>().updateEventField(key: 'organizer_to_add', value: Event.instance.organizerToAdd);

    setState(() {});
  }

  void _removeOrganizerAdded(String guestPhone) {
    setState(() {
      Event.instance.removeOrganizerAdded(guestPhone);
    });
    context.read<EventsController>().updateEventField(key: 'organizer_added', value: Event.instance.organizerAdded);
  }

  Widget _buildOrganizerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8), child: Text('Co-organisateurs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
        _buildOrganizersList(organizers: Event.instance.organizerAdded, onRemove: _removeOrganizerAdded),
        const SizedBox(height: 20),
        Padding(padding: const EdgeInsets.all(20.0), child: Text("Choisissez un de vos invités pour lui donner le rôle de co-organisateur,il recevra un sms lui indiquant son nouveau rôle", textAlign: TextAlign.center)),
      ],
    );
  }

  Widget _buildOrganizersList({required List<String> organizers, required Function(String) onRemove}) {
    if (organizers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: organizers.length,
          itemBuilder: (context, index) {
            String organizerPhone = organizers[index];
            String organizerName = Event.instance.getOrganizerNameByPhone(organizerPhone);

            String globalGuestInitial = organizerName[0].toUpperCase();
            String globalGuestImageUrl = Event.instance.getOrganizerImageUrlByPhone(organizerPhone);
            bool globalGuestHasJoined = Event.instance.getOrganizerHasJoinedByPhone(organizerPhone);

            return Column(
              children: [
                if (index != 0) Divider(indent: 16, endIndent: 16, height: 0, thickness: 1, color: kLightGrey.withOpacity(0.2)),
                Dismissible(
                  key: Key(organizerPhone), // Unique key for Dismissible
                  direction: DismissDirection.endToStart, // Swipe direction
                  onDismissed: (direction) {
                    onRemove(organizerPhone); // Call the remove function
                  },
                  background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20.0), child: const Icon(Icons.delete, color: Colors.white)),
                  child: ListTile(
                    title: Text(organizerName, style: const TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w400)),
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: (globalGuestImageUrl.isEmpty) ? kLightGrey : Colors.transparent,
                      backgroundImage: (globalGuestImageUrl.isNotEmpty) ? NetworkImage(globalGuestImageUrl) : null,
                      child: (globalGuestImageUrl.isEmpty) ? Text(globalGuestInitial, style: const TextStyle(color: kWhite)) : null,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _showGuestsDialogOnboarding(BuildContext context) async {
    String? displayName;
    String? phoneNumber;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Ajouter un invité'),
              surfaceTintColor: kWhite,
              backgroundColor: kWhite,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    decoration: const InputDecoration(labelText: 'Nom du co-organisateur', hintText: 'Entrez le nom du co-organisateur', hintStyle: TextStyle(color: kLightGrey, fontSize: 14, fontWeight: FontWeight.w400), floatingLabelBehavior: FloatingLabelBehavior.always),
                    onChanged: (value) {
                      setState(() {
                        displayName = value;
                      });
                    },
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Numéro de téléphone', hintText: 'Entrez le numéro de téléphone', floatingLabelBehavior: FloatingLabelBehavior.always, hintStyle: TextStyle(color: kLightGrey, fontSize: 14, fontWeight: FontWeight.w400)),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      setState(() {
                        phoneNumber = value;
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Annuler'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('OK'),
                  onPressed:
                      (displayName != null && phoneNumber != null && phoneNumber!.isNotEmpty)
                          ? () async {
                            Contact contact = Contact(displayName: displayName!, phones: [Item(label: 'mobile', value: await formatPhoneNumber(phoneNumber!))]);

                            List<Contact> selectedContacts = [contact];
                            List<String> allowedModules = [];

                            // Faites quelque chose avec le contact, par exemple, l'ajouter à une liste
                            await context.read<GuestsController>().createGuest(selectedContacts, allowedModules);

                            if (context.mounted) {
                              await context.read<GuestsController>().getGuests(Event.instance.id).then((guests) {
                                context.read<GuestsController>().addGuestsToEvent(guests, context);
                              });
                            }

                            Navigator.of(context).pop();
                            await _addOrganizer(phoneNumber!, context);
                          }
                          : null, // Désactiver le bouton si les champs ne sont pas remplis
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class GuestListBottomSheet extends StatefulWidget {
  final TextEditingController searchController;

  const GuestListBottomSheet({super.key, required this.searchController});

  @override
  _GuestListBottomSheetState createState() => _GuestListBottomSheetState();
}

class _GuestListBottomSheetState extends State<GuestListBottomSheet> {
  List<Guest> filteredGuests = [];

  @override
  void initState() {
    super.initState();
    filteredGuests = Event.instance.guests.where((guest) => !Event.instance.organizerAdded.contains(guest.phone)).toList();
    widget.searchController.addListener(_filterGuests);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_filterGuests);
    super.dispose();
  }

  void _filterGuests() {
    final query = widget.searchController.text;
    if (query.isNotEmpty) {
      filteredGuests = Event.instance.guests.where((guest) => guest.name.toLowerCase().contains(query.toLowerCase())).toList();

      setState(() {});
    } else {
      filteredGuests = Event.instance.guests;
      setState(() {});
    }
  }

  Future _addOrganizer(String guestPhone, BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return CoOrganizerSMSDialog(
          onSend: () async {
            await sendSMS([guestPhone], getCoOrganizerMessage(Event.instance.eventType));
            Navigator.of(context).pop();
          },
          onSkip: () {
            Navigator.of(context).pop();
          },
        );
      },
    );

    Event.instance.addOrganizer(guestPhone);

    context.read<EventsController>().updateEventField(key: 'organizer_added', value: Event.instance.organizerAdded);

    context.read<EventsController>().updateEventField(key: 'organizer_to_add', value: Event.instance.organizerAdded);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(child: SearchBarGuest(searchController: widget.searchController)),
                const SizedBox(width: 12),
                Event.instance.visibility == 'public'
                    ? const SizedBox()
                    : PhoneContacts(
                      onReturn: () {
                        setState(() {
                          filteredGuests = Event.instance.guests;
                        });

                        Navigator.of(context).pop();
                      },
                    ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child:
                filteredGuests.isEmpty
                    ? Center(
                      child:
                          Event.instance.visibility == 'private'
                              ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Il n\'y a pas d\'invités pour le moment.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                                  const SizedBox(height: 12),
                                  PhoneContacts(
                                    onReturn: (() {
                                      filteredGuests = Event.instance.guests;

                                      setState(() {});

                                      Navigator.of(context).pop();
                                    }),
                                  ),
                                ],
                              )
                              : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [Text('Vous n\'avez pas encore d\'invités, partagez le code d\'invitation pour en inviter !', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: kBlack))],
                              ),
                    )
                    : ListView.builder(
                      itemCount: filteredGuests.length,
                      itemBuilder: (context, index) {
                        var guest = filteredGuests[index];
                        return ListTile(
                          onTap: () async {
                            await _addOrganizer(guest.phone, context);
                            Navigator.of(context).pop();
                          },
                          title: Text(guest.name, style: const TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w400)),
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: (guest.imageUrl.isEmpty) ? kLightGrey : Colors.transparent,
                            backgroundImage: (guest.imageUrl.isNotEmpty) ? NetworkImage(guest.imageUrl) : null,
                            child: (guest.imageUrl.isEmpty) ? Text(guest.name[0].toUpperCase(), style: const TextStyle(color: kWhite)) : null,
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
