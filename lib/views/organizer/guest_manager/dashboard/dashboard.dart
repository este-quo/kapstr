import 'package:flutter/material.dart';
import 'package:kapstr/controllers/guests.dart';
import 'package:kapstr/controllers/rsvps.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/models/rsvp.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final List<String> modulesToFilterOut = ['budget', 'cagnotte', 'invitation', 'album_photo', 'tables', 'golden_book', 'media', 'menu'];
  Module? selectedModule;

  bool shouldFilterModule(Module module) {
    return modulesToFilterOut.contains(module.type);
  }

  Future<List<RSVP>> getRSVP(String moduleId) async {
    return await context.read<RSVPController>().getRSVPsByModuleId(moduleId);
  }

  @override
  Widget build(BuildContext context) {
    int guests = context.watch<GuestsController>().eventGuests.length;
    int guestsJoined = context.watch<GuestsController>().eventGuests.where((element) => element.hasJoined == true).toList().length;
    double joinPercentage = guests != 0 ? guestsJoined / guests : 0;
    List<Module> modules = Event.instance.modules.where((module) => !shouldFilterModule(module) && module.type != "text").toList();
    return Scaffold(
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
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Title
                const Text('Dashboard', textAlign: TextAlign.left, style: TextStyle(fontSize: 24, color: kBlack, fontWeight: FontWeight.w600)),

                const SizedBox(height: 12),

                Text('Mes invités : $guests', style: const TextStyle(color: kBlack, fontSize: 18, fontWeight: FontWeight.w500)),

                const SizedBox(height: 8),

                // Grand indicateur circulaire avec texte au centre
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(height: 125, width: 125, child: CircularProgressIndicator(value: joinPercentage, backgroundColor: kLightGrey, color: kSuccess, strokeWidth: 12)),
                        Text('${(joinPercentage * 100).toStringAsFixed(0)}%', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: kLightGrey)),
                      ],
                    ),
                  ),
                ),

                // Guests joined
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [Container(width: 12, height: 12, decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: kSuccess)), const SizedBox(width: 8), Text('Rejoins : $guestsJoined', style: const TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w500))],
                ),

                const SizedBox(height: 8),

                // Guests not joined
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(width: 12, height: 12, decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: kLightGrey)),
                    const SizedBox(width: 8),
                    Text('En attente : ${guests - guestsJoined}', style: const TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),

                // Icons buttons
                const SizedBox(height: 12),

                // Sélection du module
                DropdownButton<Module>(
                  style: const TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w400),
                  hint: const Text('Sélectionner un événement'),
                  value: selectedModule,
                  onChanged: (Module? newValue) {
                    setState(() {
                      selectedModule = newValue;
                    });
                  },
                  items:
                      modules.map<DropdownMenuItem<Module>>((Module module) {
                        return DropdownMenuItem<Module>(value: module, child: Text(module.name));
                      }).toList(),
                ),

                // Affichage des détails en fonction du module sélectionné
                if (selectedModule != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Détails de : ${selectedModule!.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                        FutureBuilder(
                          future: getRSVP(selectedModule!.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: SizedBox(height: 32, width: 32, child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 32)));
                            } else if (snapshot.hasError) {
                              return const Center(child: Text("Une erreur est survenue", style: TextStyle(color: Colors.white)));
                            } else if (snapshot.hasData) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Container(width: 12, height: 12, decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: kSuccess)),
                                      const SizedBox(width: 8),
                                      Text('Présent : ${snapshot.data?.where((element) => element.response == 'Accepté').toList().length}', style: const TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(width: 12, height: 12, decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: kSuccess)),
                                      const SizedBox(width: 8),
                                      Text('Présent (Enfants) : ${snapshot.data?.where((element) => element.response == 'Accepté').fold(0, (sum, element) => sum + (element.children.length))}', style: const TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(width: 12, height: 12, decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: kSuccess)),
                                      const SizedBox(width: 8),
                                      Text('Présent (Adultes) : ${snapshot.data?.where((element) => element.response == 'Accepté').fold(0, (sum, element) => sum + (element.adults.length))}', style: const TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(width: 12, height: 12, decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: kLightGrey)),
                                      const SizedBox(width: 8),
                                      Text('En attente : ${snapshot.data?.where((element) => element.response == 'En attente').toList().length}', style: const TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(width: 12, height: 12, decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: kDanger)),
                                      const SizedBox(width: 8),
                                      Text('Absent : ${snapshot.data?.where((element) => element.response == 'Absent').toList().length}', style: const TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ],
                              );
                            } else {
                              return const Center(child: Text("Aucune donnée trouvée", style: TextStyle(color: Colors.white)));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
