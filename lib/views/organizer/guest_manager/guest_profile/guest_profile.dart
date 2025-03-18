import 'package:flutter/material.dart';
import 'package:kapstr/controllers/rsvps.dart';
import 'package:kapstr/helpers/rsvp.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/models/added_guest.dart';
import 'package:kapstr/models/guest.dart';
import 'package:kapstr/models/rsvp.dart';
import 'package:kapstr/widgets/buttons/ic_button.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:provider/provider.dart';

class GuestProfile extends StatefulWidget {
  final Guest guest;
  final String moduleName;
  final String moduleId;
  const GuestProfile({super.key, required this.guest, required this.moduleName, required this.moduleId});

  @override
  _GuestProfileState createState() => _GuestProfileState();
}

class _GuestProfileState extends State<GuestProfile> {
  List<AddedGuest> _adults = [];
  List<AddedGuest> _children = [];
  RSVP? rsvp;
  String selectedAnswer = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchRSVP();
  }

  Future<void> fetchRSVP() async {
    rsvp = context.read<RSVPController>().getRsvpByIds(widget.guest.id, widget.moduleId);
    if (rsvp != null) {
      setState(() {
        _adults = rsvp!.adults;
        _children = rsvp!.children;
        selectedAnswer = rsvp!.response;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _addGuest(bool isAdult) {
    setState(() {
      if (isAdult) {
        _adults.add(AddedGuest(id: generateRandomId(), name: ''));
      } else {
        _children.add(AddedGuest(id: generateRandomId(), name: ''));
      }
    });
  }

  void _removeGuest(int index, bool isAdult) {
    setState(() {
      if (isAdult) {
        _adults.removeAt(index);
      } else {
        _children.removeAt(index);
      }
    });
  }

  void _updateGuestName(int index, String newName, bool isAdult) {
    setState(() {
      if (isAdult) {
        _adults[index] = AddedGuest(id: generateRandomId(), name: newName);
      } else {
        _children[index] = AddedGuest(id: generateRandomId(), name: newName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      resizeToAvoidBottomInset: false,
      floatingActionButton: MainButton(backgroundColor: kPrimary, onPressed: _saveProfile, child: const Text('Sauvegarder', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w500))),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('RSVP de l\'invité', textAlign: TextAlign.left, style: TextStyle(fontSize: 24, color: kBlack, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              _buildGuestList('Adultes', _adults, true),
              const SizedBox(height: 16),
              _buildGuestList('Enfants', _children, false),
              const SizedBox(height: 16),
              IcButton(
                backgroundColor: kBlack,
                borderColor: const Color.fromARGB(30, 0, 0, 0),
                borderWidth: 1,
                width: MediaQuery.of(context).size.width - 40,
                height: 48,
                radius: 8,
                onPressed: () => _addGuest(true),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add, color: Colors.white), const Text('Ajouter un adulte', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w500))]),
              ),
              const SizedBox(height: 12),
              IcButton(
                backgroundColor: kBlack,
                borderColor: const Color.fromARGB(30, 0, 0, 0),
                borderWidth: 1,
                width: MediaQuery.of(context).size.width - 40,
                height: 48,
                radius: 8,
                onPressed: () => _addGuest(false),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add, color: Colors.white), Text('Ajouter un enfant', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w500))]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuestList(String title, List<AddedGuest> guests, bool isAdult) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, color: kBlack, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: guests.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: TextFormField(initialValue: guests[index].name, decoration: InputDecoration(labelText: 'Nom de l\'invité', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))), onChanged: (value) => _updateGuestName(index, value, isAdult))),
                    const SizedBox(width: 8),
                    IconButton(icon: const Icon(Icons.close, color: kDanger), onPressed: () => _removeGuest(index, isAdult)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
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
    );
  }

  Future<void> _saveProfile() async {
    triggerShortVibration();

    if (isLoading) return;

    // Vérification des champs vides
    final hasEmptyFields = _adults.any((guest) => guest.name.trim().isEmpty) || _children.any((guest) => guest.name.trim().isEmpty);

    if (hasEmptyFields) {
      // Afficher une alerte ou un SnackBar pour indiquer que tous les champs doivent être remplis
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Tous les champs doivent être remplis.'), backgroundColor: Colors.red));
      return;
    }

    setState(() => isLoading = true);

    // Mettre à jour RSVP
    if (rsvp != null) {
      rsvp!.adults = _adults;
      rsvp!.children = _children;
      rsvp!.response = selectedAnswer;
      await context.read<RSVPController>().updateRSVP(rsvp!.id, rsvp!);
    }

    setState(() => isLoading = false);
    Navigator.of(context).pop();
  }
}
