import 'package:flutter/material.dart';
import 'package:kapstr/controllers/places.dart';
import 'package:kapstr/models/place.dart';
import 'package:kapstr/models/table.dart';
import 'package:provider/provider.dart';
import 'package:kapstr/controllers/modules/tables.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';

class EditTable extends StatefulWidget {
  final TableModel table;

  const EditTable({super.key, required this.table});

  @override
  _EditTableState createState() => _EditTableState();
}

class _EditTableState extends State<EditTable> {
  final TextEditingController _tableNameController = TextEditingController();
  bool isInitialized = false;
  bool isSaving = false;
  List<Place> guests = [];
  List<Place> selectedGuests = [];

  @override
  void initState() {
    super.initState();
    _tableNameController.text = widget.table.name;
    if (!isInitialized) {
      _loadGuests();
    }
  }

  void _loadGuests() async {
    if (!isInitialized) {
      selectedGuests = [];
      List<Place> places = context.read<PlacesController>().places;
      List<Place> toFilter = [];
      for (Place place in places) {
        if (place.tableId == widget.table.id) {
          toFilter.add(place);
          selectedGuests.add(place);
        } else if (place.tableId == "") {
          toFilter.add(place);
        }
      }
      setState(() {
        isInitialized = true;
        guests = toFilter;
      });
    }
  }

  void _toggleGuestSelection(Place place) {
    setState(() {
      if (selectedGuests.any((selected) => selected.id == place.id)) {
        selectedGuests.removeWhere((selected) => selected.id == place.id);
        place.tableId = "";
      } else {
        selectedGuests.add(place);
        place.tableId = widget.table.id!;
      }
      context.read<PlacesController>().updatePlace(place);
    });
  }

  Future<void> _saveTable() async {
    setState(() {
      context.read<PlacesController>().setIsLoading(true);
    });

    final updatedTable = TableModel(id: widget.table.id, name: _tableNameController.text);

    if (_tableNameController.text != widget.table.name) {
      await context.read<TablesController>().updateTable(updatedTable);
    }

    await context.read<PlacesController>().updatePlaces();

    setState(() {
      context.read<PlacesController>().setIsLoading(false);
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
        elevation: 0,
        leadingWidth: 75,
        toolbarHeight: 40,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                isInitialized = false;
                guests = [];
                selectedGuests = [];
              });
              Navigator.pop(context);
            },
            child: const Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: kBlack), Text('Retour', style: TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w500))]),
          ),
        ),
        title: const Text('Modifier la table', style: TextStyle(color: kBlack, fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      floatingActionButton:
          context.watch<PlacesController>().isLoading
              ? FloatingActionButton(backgroundColor: kBlack, onPressed: null, child: const CircularProgressIndicator(color: kWhite))
              : MainButton(onPressed: _saveTable, child: const Text('Sauvegarder', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w500))),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text('Nom de la table', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kBlack)),
            const SizedBox(height: 8),
            TextField(controller: _tableNameController, decoration: InputDecoration(hintText: 'Entrez le nom de la table', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
            const SizedBox(height: 16),
            const Text('Invités disponibles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kBlack)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: guests.length,
                itemBuilder: (context, index) {
                  final guest = guests[index];
                  final isSelected = selectedGuests.any((selected) => selected.id == guest.id);
                  return ListTile(key: Key(index.toString()), leading: const Icon(Icons.account_circle), title: Text(guest.guestName), trailing: Checkbox(value: isSelected, onChanged: (_) => _toggleGuestSelection(guest)));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
