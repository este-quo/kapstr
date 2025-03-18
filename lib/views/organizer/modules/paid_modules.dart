import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/modules/menu.dart';
import 'package:kapstr/controllers/modules/modules.dart';
import 'package:kapstr/controllers/notification.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/views/organizer/modules/add_module_buton.dart';
import 'package:kapstr/widgets/layout/spacing.dart';
import 'package:kapstr/helpers/format_colors.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:provider/provider.dart';

class PaidModules extends StatefulWidget {
  const PaidModules({super.key});

  @override
  State<StatefulWidget> createState() => _PaidModulesState();
}

class _PaidModulesState extends State<PaidModules> {
  late Future<QuerySnapshot<Map<String, dynamic>>> fetchPaidModules;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _fetchModules();
  }

  _fetchModules() {
    fetchPaidModules = context.read<EventsController>().getPaidModules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 75,
        toolbarHeight: 40,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(onTap: () => Navigator.of(context).pop(), child: const Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: kBlack), Text('Retour', style: TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w500))])),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Title
                const Text('Ajouter un module', textAlign: TextAlign.left, style: TextStyle(fontSize: 24, color: kBlack, fontWeight: FontWeight.w600)),

                const SizedBox(height: 8),

                // Subtitle
                const Text('Personnalisez votre application en ajoutant les widgets de votre choix à tout moment.', textAlign: TextAlign.left, style: TextStyle(fontSize: 14, color: kBlack, fontWeight: FontWeight.w400)),

                const SizedBox(height: 16),

                FutureBuilder(
                  future: fetchPaidModules,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var data = snapshot.data!.docs.map((e) => e.data()).toList();

                      // Define custom order of types
                      const typeOrder = ['event', 'album_photo', 'menu', 'tables', 'media', 'video', 'cagnotte', 'text'];

                      // Sort modules according to the custom order
                      data.sort((a, b) {
                        var typeA = a['type'];
                        var typeB = b['type'];

                        int indexA = typeOrder.indexOf(typeA);
                        int indexB = typeOrder.indexOf(typeB);

                        if (indexA == -1) indexA = typeOrder.length;
                        if (indexB == -1) indexB = typeOrder.length;

                        return indexA.compareTo(indexB);
                      });

                      return ListView.builder(
                        padding: const EdgeInsets.all(0),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          if (data[index]['type'] == 'about' && Event.instance.eventType == 'mariage' ||
                              data[index]['type'] == 'golden_book' && Event.instance.eventType == 'salon' ||
                              data[index]['type'] == 'menu' && Event.instance.eventType == 'salon' ||
                              data[index]['type'] == 'about' && Event.instance.eventType == 'bar mitsvah' ||
                              data[index]['type'] == 'about' && Event.instance.eventType == 'anniversaire' ||
                              data[index]['type'] == 'invitation' && Event.instance.modules.any((element) => element.type == 'invitation') ||
                              data[index]['type'] == 'menu' && Event.instance.modules.any((element) => element.type == 'menu') ||
                              data[index]['type'] == 'golden_book' && Event.instance.modules.any((element) => element.type == 'golden_book')) {
                            return const SizedBox.shrink();
                          }

                          return AddModuleButton(
                            isLoading: _isProcessing,
                            icon: getIconFromType(data[index]['type']),
                            imageUrl: data[index]['image'],
                            fontSize: int.parse(data[index]['text_size']),
                            textColor: fromHex(data[index]['text_color']),
                            typographie: '',
                            context: context,
                            colorFilter: kBlack,
                            title: data[index]['name'],
                            onTap:
                                _isProcessing
                                    ? null
                                    : () async {
                                      setState(() {
                                        _isProcessing = true;
                                      });

                                      if (data[index]['type'] == 'menu' && !Event.instance.modules.any((element) => element.type == 'menu')) {
                                        context.read<MenuModuleController>().getMenuById();
                                      }

                                      if (data[index]['type'] == 'menu' && Event.instance.modules.any((element) => element.type == 'menu')) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(const SnackBar(duration: Duration(seconds: 2), content: Text('Vous avez déjà ajouté un menu à votre évènement !', textAlign: TextAlign.center, style: TextStyle(color: kWhite, fontSize: 14)), backgroundColor: kWaiting));
                                        setState(() {
                                          _isProcessing = false;
                                        });
                                        return;
                                      }
                                      if (data[index]['type'] == 'text' && Event.instance.modules.any((element) => element.type == 'text')) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(const SnackBar(duration: Duration(seconds: 2), content: Text('Vous avez déjà ajouté un texte à votre évènement !', textAlign: TextAlign.center, style: TextStyle(color: kWhite, fontSize: 14)), backgroundColor: kWaiting));
                                        setState(() {
                                          _isProcessing = false;
                                        });
                                        return;
                                      }

                                      if (data[index]['type'] == 'tables' && Event.instance.modules.any((element) => element.type == 'tables')) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(const SnackBar(duration: Duration(seconds: 2), content: Text('Vous avez déjà ajouté un plan de table à votre évènement !', textAlign: TextAlign.center, style: TextStyle(color: kWhite, fontSize: 14)), backgroundColor: kWaiting));
                                        setState(() {
                                          _isProcessing = false;
                                        });
                                        return;
                                      }

                                      await context.read<ModulesController>().createModule(data[index]["type"], context, Event.instance.id);

                                      // Update the event
                                      if (context.mounted) {
                                        await context.read<EventsController>().updateModules(await context.read<ModulesController>().getModules(Event.instance.id));
                                      }

                                      await context.read<NotificationController>().addGuestNotification(title: 'Nouveau module : ${data[index]['name']}', body: 'Un nouveau module a été ajouté à l\'événement jettez-y un oeil !', type: 'module_added', image: data[index]['image']);

                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(duration: Duration(seconds: 2), content: Text('Module ajouté avec succès !', textAlign: TextAlign.center, style: TextStyle(color: kWhite, fontSize: 14)), backgroundColor: kSuccess));

                                      setState(() {
                                        _isProcessing = false;
                                      });

                                      Navigator.pop(context, true);
                                    },
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return const Text('Aucun évènement trouvé');
                    } else {
                      return const Padding(padding: EdgeInsets.only(top: 48.0), child: Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 40)));
                    }
                  },
                ),
                kNavBarSpacer(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget getIconFromType(String type) {
  switch (type) {
    case 'tables':
      return Image.asset('assets/icons/tables.png', width: 24, height: 24, color: kBlack);
    case 'cagnotte':
      return Image.asset('assets/icons/lien.png', width: 24, height: 24, color: kBlack);
    case 'event':
      return const Icon(Icons.celebration_outlined);
    case 'album_photo':
      return Image.asset('assets/icons/gallery.png', width: 24, height: 24);

    case 'invitation':
      return const Icon(Icons.card_giftcard_outlined, color: kBlack);
    case 'media':
      return const Icon(Icons.description_outlined, color: kBlack, size: 24);

    case 'menu':
      return Image.asset('assets/icons/menu.png', width: 24, height: 24);
    case 'golden_book':
      return Image.asset('assets/icons/golden_book.png', width: 24, height: 24);
    case 'text':
      return const Icon(Icons.edit_outlined);
    case 'about':
      return const Icon(Icons.info_outlined);
    default:
      return const Icon(Icons.linear_scale);
  }
}
