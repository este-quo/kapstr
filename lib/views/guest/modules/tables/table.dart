import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/rsvps.dart';
import 'package:kapstr/controllers/themes.dart';
import 'package:kapstr/helpers/rsvp.dart';
import 'package:kapstr/models/added_guest.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/app_guest.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/models/modules/table.dart';
import 'package:kapstr/models/rsvp.dart';
import 'package:kapstr/models/table.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/logo_loader.dart';

import 'package:kapstr/widgets/theme/background_theme.dart';
import 'package:provider/provider.dart';

class TablesGuest extends StatefulWidget {
  const TablesGuest({super.key, required this.module, this.isPreview = false});

  final Module module;
  final bool isPreview;

  @override
  State<StatefulWidget> createState() => _TablesGuestState();
}

class _TablesGuestState extends State<TablesGuest> {
  List<Map<String, TableModel>> children = [];
  List<Map<String, TableModel>> adults = [];
  bool isLoading = true; // Indicateur pour afficher le loader

  UniqueTable? table;
  DateTime eventDate = DateTime.now();
  Module? menuModule;
  Module? eventModule;
  RSVP? fakeRsvp;

  @override
  void initState() {
    super.initState();

    if (Event.instance.modules.where((element) => element.type == 'menu').isNotEmpty) {
      menuModule = Event.instance.modules.where((element) => element.type == 'menu').first;
    }

    eventModule = Event.instance.modules.where((element) => element.type == 'wedding').first;
    eventDate = Event.instance.modules.where((element) => element.type == 'wedding').first.date!;

    if (context.read<EventsController>().isGuestPreview || widget.isPreview) {
      _loadFakeTable();
      _loadFakeRsvp();
      isLoading = false; // Désactiver le loader si en mode prévisualisation
    } else {
      loadTables();
    }
  }

  void _loadFakeTable() {
    table = UniqueTable(id: 'fake_table_id', name: 'Table d\'exemple', guestsId: ['guest1', 'guest2', 'guest3'], eventId: 'fake_event_id');
    setState(() {});
  }

  void _loadFakeRsvp() {
    fakeRsvp = RSVP(id: 'fake_rsvp_id', guestId: 'fake_guest_id', response: 'En attente', adults: [AddedGuest(id: generateRandomId(), name: "Jean")], children: [], moduleId: widget.module.id, isAllowed: true, createdAt: DateTime.now(), isAnswered: false);
    context.read<RSVPController>().setRsvps([fakeRsvp!]);
  }

  Future<void> loadTables() async {
    setState(() {
      isLoading = true; // Activer le loader avant de charger les tables
    });
    try {
      final List<Map<String, TableModel>> adultsRsvps = await context.read<RSVPController>().getAllAdultsForMainEvent(Event.instance.id, AppGuest.instance.id, context);
      final List<Map<String, TableModel>> childrenRsvps = await context.read<RSVPController>().getAllChildrenForMainEvent(Event.instance.id, AppGuest.instance.id, context);

      setState(() {
        adults = adultsRsvps;
        children = childrenRsvps;
      });
    } catch (e) {
      // Gestion des erreurs
    } finally {
      setState(() {
        isLoading = false; // Désactiver le loader une fois le chargement terminé
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundTheme(
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: context.watch<EventsController>().event.lowResThemeUrl == "" ? kWhite : Colors.transparent,
          backgroundColor: context.watch<EventsController>().event.lowResThemeUrl == "" ? kWhite : Colors.transparent,
          elevation: 0,
          leadingWidth: 75,
          centerTitle: true,
          toolbarHeight: 40,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: context.read<ThemeController>().getTextColor()), Text('Retour', style: TextStyle(color: context.read<ThemeController>().getTextColor(), fontSize: 14, fontWeight: FontWeight.w500))]),
            ),
          ),
        ),
        backgroundColor: context.watch<EventsController>().event.lowResThemeUrl == "" ? kWhite : Colors.transparent,
        body: SafeArea(
          child:
              isLoading
                  ? const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_dark.svg', size: 64))
                  : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), child: Text('Mes tables', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 32, color: context.read<ThemeController>().getTextColor()))),
                        const SizedBox(height: 16),
                        if (!context.read<EventsController>().event.showTablesEarly)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32.0),
                            margin: const EdgeInsets.symmetric(horizontal: 32),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 3))]),
                            child: const Text("Votre table s’affichera ici le jour J", style: TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w400), textAlign: TextAlign.center),
                          ),
                        if (adults.isEmpty && children.isEmpty && context.read<EventsController>().event.showTablesEarly)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32.0),
                            margin: const EdgeInsets.symmetric(horizontal: 32),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 3))]),
                            child: const Text("Aucune table n'a été renseignée par l'organisateur pour l'instant.", style: TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w400), textAlign: TextAlign.center),
                          ),
                        // Display cards for each table
                        if (context.read<EventsController>().event.showTablesEarly)
                          ...adults.map((tableMap) {
                            final table = tableMap.values.first;
                            final guest = tableMap.keys.first;
                            return _buildTableCard(guest, table, "Adulte");
                          }),
                        ...children.map((tableMap) {
                          final table = tableMap.values.first;
                          final guest = tableMap.keys.first;
                          return _buildTableCard(guest, table, "Enfant");
                        }),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildTableCard(String guest, TableModel table, String guestType) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(color: const Color.fromARGB(200, 255, 255, 255), borderRadius: BorderRadius.circular(8), border: Border.all(), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.2), spreadRadius: 1, blurRadius: 8, offset: const Offset(0, 3))]),
        child: ListTile(
          title: Text(guest, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Vous êtes à la table :', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12)),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(table.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(guestType, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14))]),
            ],
          ),
        ),
      ),
    );
  }
}
