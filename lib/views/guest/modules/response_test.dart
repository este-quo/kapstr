import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/components/buttons/primary_button.dart';
import 'package:kapstr/components/buttons/secondary_button.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/rsvps.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/helpers/rsvp.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/models/added_guest.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/models/rsvp.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:provider/provider.dart';

class ResponseTest extends StatefulWidget {
  const ResponseTest({super.key, required this.rsvp, required this.module});

  final RSVP rsvp;
  final Module module;

  @override
  State<ResponseTest> createState() => _ResponseTestState();
}

class _ResponseTestState extends State<ResponseTest> {
  final List<AddedGuest> _guests = [];
  List<String> adultsIds = [];
  bool isLoading = false;
  bool isAnswered = false;
  late ConfettiController _confettiController;
  final ScrollController _scrollController = ScrollController();
  final Map<int, FocusNode> _focusNodes = {}; // Associer un FocusNode à chaque champ

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 500));
    for (AddedGuest guest in widget.rsvp.adults) {
      adultsIds.add(guest.id);
    }
    _guests.addAll(widget.rsvp.adults);
    _guests.addAll(widget.rsvp.children);

    // Créer un FocusNode pour chaque invité initial
    for (int i = 0; i < _guests.length; i++) {
      _focusNodes[i] = FocusNode();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scrollController.dispose();

    // Nettoyer les FocusNodes pour éviter les fuites mémoire
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }

    super.dispose();
  }

  Future<void> _confirmPresence(bool value) async {
    QuerySnapshot event = await context.read<EventsController>().checkIfEventExistWithCode(context.read<EventsController>().event.code);
    QuerySnapshot currentUser = await context.read<UsersController>().currentUser();

    var organizerToAddField = event.docs.first["organizer_added"];
    bool isOrganizer;

    String? phone;

    if (currentUser.docs.isNotEmpty) {
      phone = currentUser.docs.first["phone"];
    }

    if (organizerToAddField is String) {
      isOrganizer = organizerToAddField == phone;
    } else if (organizerToAddField is List) {
      isOrganizer = organizerToAddField.contains(phone);
    } else {
      isOrganizer = false;
    }

    if (!isOrganizer) {
      showDialog(context: context, builder: (context) => AlertDialog(title: const Text("Vous êtes l'organisateur"), content: const Text("Vous ne pouvez pas répondre en tant qu'organisateur"), actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Compris"))]));
      return;
    }

    if (value && _guests.isEmpty) {
      showDialog(context: context, builder: (context) => AlertDialog(title: const Text("Erreur"), content: const Text("Veuillez renseigner au moins une personne pour être présent"), actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Compris"))]));
      return;
    }

    bool hasEmptyName = _guests.any((guest) => guest.name.trim().isEmpty);

    if (hasEmptyName) {
      showDialog(context: context, builder: (context) => AlertDialog(title: const Text("Erreur"), content: const Text("Tous les noms doivent être renseignés avant de confirmer."), actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Compris"))]));
      return;
    }

    setState(() => isLoading = true);
    triggerShortVibration();
    _confettiController.play();

    widget.rsvp.response = value ? 'Accepté' : 'Absent';
    widget.rsvp.adults.clear();
    widget.rsvp.children.clear();

    for (AddedGuest guest in _guests) {
      if (isGuestAnAdult(guest)) {
        widget.rsvp.adults.add(guest);
      } else {
        widget.rsvp.children.add(guest);
      }
    }
    widget.rsvp.isAnswered = true;

    await context.read<RSVPController>().updateRSVP(widget.rsvp.id, widget.rsvp);

    Navigator.pop(context);

    context.read<RSVPController>().isAllAnswered = true;

    setState(() {
      isLoading = false;
      isAnswered = true;
      ConfettiController().play();
    });
  }

  void _addGuest() {
    setState(() {
      String id = generateRandomId();
      _guests.add(AddedGuest(id: id, name: ''));
      adultsIds.add(id);

      // Ajouter un FocusNode pour le nouvel invité
      _focusNodes[_guests.length - 1] = FocusNode();
    });

    // Attendre la fin de la mise à jour du widget avant de donner le focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[_guests.length - 1]?.requestFocus();
      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    });
  }

  void _removeGuest(int index, AddedGuest guest) {
    setState(() {
      _guests.removeAt(index);
      adultsIds.remove(guest.id);

      // Supprimer le FocusNode associé
      _focusNodes[index]?.dispose();
      _focusNodes.remove(index);
    });
  }

  void _updateGuest(int index, AddedGuest guest, String name) {
    setState(() {
      guest.name = name;
    });
  }

  void _toggleGuestType(AddedGuest guest) {
    setState(() {
      if (isGuestAnAdult(guest)) {
        adultsIds.remove(guest.id);
      } else {
        adultsIds.add(guest.id);
      }
    });
  }

  bool isGuestAnAdult(AddedGuest guest) {
    return adultsIds.contains(guest.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Répondre à l'invitation"), backgroundColor: kWhite),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 80, // Gérer l'espacement avec le bouton
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text('Invités', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kBlack)),
              const SizedBox(height: 16),
              ..._guests.asMap().entries.map((entry) {
                int index = entry.key;
                AddedGuest guest = entry.value;
                return _buildGuestEntry(index, guest, isGuestAnAdult(guest));
              }),
              const SizedBox(height: 16),
              Center(child: ElevatedButton(onPressed: _addGuest, style: ElevatedButton.styleFrom(backgroundColor: kBlack, shape: const CircleBorder(), padding: const EdgeInsets.all(8)), child: const Text('+', style: TextStyle(color: kWhite, fontSize: 24)))),
              SizedBox(height: 16),
              PrimaryButton(
                backgroundColor: kPrimary,
                onPressed: () {
                  _confirmPresence(true);
                },
                text: "Je suis présent",
              ),
              SizedBox(height: 8),
              SecondaryButton(
                onPressed: () {
                  _confirmPresence(false);
                },
                text: "Je ne pourrais pas être la ",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuestEntry(int index, AddedGuest guest, bool isAdult) {
    final FocusNode? focusNode = _focusNodes[index];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(8), border: Border.all(color: kLightGrey), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 8, offset: const Offset(0, 3))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(focusNode);
                _scrollController.animateTo(
                  index * 70.0, // Position estimée du champ
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextFormField(
                      textInputAction: TextInputAction.done,
                      focusNode: focusNode,
                      initialValue: guest.name,
                      decoration: InputDecoration(labelText: 'Nom', border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: kLightGrey))),
                      onChanged: (value) {
                        _updateGuest(index, guest, value);
                      },
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close, color: kDanger), onPressed: () => _removeGuest(index, guest)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Enfant'),
                Switch(
                  value: isAdult,
                  onChanged: (value) {
                    _toggleGuestType(guest);
                  },
                  activeColor: kPrimary,
                  inactiveTrackColor: kLightGrey,
                ),
                const Text('Adulte'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
