import 'package:flutter/material.dart';
import 'package:kapstr/controllers/places.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/models/place.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/controllers/modules/tables.dart';
import 'package:kapstr/views/organizer/modules/tables/table_card.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:kapstr/widgets/layout/spacing.dart';
import 'package:kapstr/views/organizer/modules/tables/create_table.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class Tables extends StatefulWidget {
  final Module module;

  const Tables({super.key, required this.module});

  @override
  State<StatefulWidget> createState() => _TablesState();
}

class _TablesState extends State<Tables> {
  bool isTablesEmpty = false;

  @override
  void initState() {
    refreshPlaces();
    super.initState();
  }

  void refreshPlaces() async {
    await context.read<PlacesController>().refreshPlaces(context);
    setState(() {});
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
              Navigator.pop(context);
            },
            child: const Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: kBlack), Text('Retour', style: TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w500))]),
          ),
        ),
        actions: const [SizedBox(width: 91)],
      ),
      floatingActionButton: MainButton(
        onPressed: () async {
          await showCreateTableDialog(context);
        },
        backgroundColor: kBlack,
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Symbols.add, color: kWhite), SizedBox(width: 8), Text('Ajouter une table', style: TextStyle(color: kWhite, fontSize: 16))]),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Title
              const Text('Mes tables', textAlign: TextAlign.left, style: TextStyle(fontSize: 24, color: kBlack, fontWeight: FontWeight.w600)),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(child: Text('Dévoilez les tables à vos convives avant le jour J ?', style: TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w400))),

                  // Switch
                  Switch(
                    value: Event.instance.showTablesEarly,
                    onChanged: (value) async {
                      triggerShortVibration();
                      await context.read<TablesController>().updateShowTablesEarly(value);
                    },
                    activeColor: kBlack,
                    activeTrackColor: kBlack.withOpacity(0.5),
                    inactiveThumbColor: kWhite,
                    inactiveTrackColor: kLightGrey.withOpacity(0.5),
                    trackOutlineColor: MaterialStateColor.resolveWith((states) => kLightGrey),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              context.watch<TablesController>().isLoading
                  ? Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64))
                  : context.watch<TablesController>().tables.isEmpty
                  ? Center(
                    child: GestureDetector(
                      onTap: () async {
                        await showCreateTableDialog(context);
                      },
                      child: Column(children: [xLargeSpacerH(), const Text('Vous n\'avez pas encore créé de table', style: TextStyle(color: kGrey, fontSize: 16))]),
                    ),
                  )
                  : !context.watch<PlacesController>().isLoading
                  ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: context.watch<TablesController>().tables.length,
                    itemBuilder: (context, index) {
                      final table = context.watch<TablesController>().tables[index];
                      int number = _loadPlacesNumber(context, table.id!);
                      return TableCard(tableModel: table, module: widget.module, guestsNumber: number);
                    },
                  )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}

int _loadPlacesNumber(BuildContext context, String tableId) {
  List<Place> places = context.read<PlacesController>().places;
  List<Place> toFilter = [];
  for (Place place in places) {
    if (place.tableId == tableId) {
      toFilter.add(place);
    }
  }
  return toFilter.length;
}

Future<void> showCreateTableDialog(BuildContext context) async {
  showDialog(context: context, builder: (context) => const CreateTableDialog());
}
