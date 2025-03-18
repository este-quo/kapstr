import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/modules/modules.dart';
import 'package:kapstr/controllers/themes.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/helpers/rsvp.dart';
import 'package:kapstr/models/added_guest.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/app_guest.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/models/rsvp.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/guest/rsvp/card.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:kapstr/controllers/rsvps.dart';

class RsvpPage extends StatefulWidget {
  const RsvpPage({super.key});

  @override
  RsvpState createState() => RsvpState();
}

class RsvpState extends State<RsvpPage> {
  List<Module> _allModules = [];
  List<Module> _filteredModules = [];
  bool _dataLoaded = false;

  final PageController _controller = PageController();
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    _fetchData();
  }

  void _fetchData() async {
    final modules = await context.read<ModulesController>().getModules(Event.instance.id);
    modules.removeWhere((module) => module.type == 'text');
    final rsvpController = context.read<RSVPController>();

    if (!context.read<EventsController>().isGuestPreview && context.read<UsersController>().user != null) {
      await rsvpController.fetchRsvps(AppGuest.instance.id, AppGuest.instance.allowedModules);
      setState(() {
        _allModules = modules;
        final sortedRSVPs =
            rsvpController.rsvps.where((rsvp) => _allModules.any((module) => module.id == rsvp.moduleId)).toList()..sort((a, b) {
              if (a.isAnswered == b.isAnswered) {
                return a.moduleId.compareTo(b.moduleId);
              } else if (!a.isAnswered && b.isAnswered) {
                return -1;
              } else {
                return 1;
              }
            });
        _filteredModules = _allModules.where((module) => !kNonEventModules.contains(module.type)).toList()..sort((a, b) => a.id.compareTo(b.id));
        rsvpController.setRsvps(sortedRSVPs);
        _dataLoaded = true;
      });
    } else {
      setState(() {
        _allModules = modules;
        _filteredModules = _allModules.where((module) => !kNonEventModules.contains(module.type)).toList()..sort((a, b) => a.id.compareTo(b.id));
        final fakeRsvps = _filteredModules.map((module) => RSVP(guestId: 'fakeId', moduleId: module.id, isAllowed: true, response: 'En attente', adults: [AddedGuest(id: generateRandomId(), name: "Jean")], children: [], createdAt: DateTime.now(), isAnswered: false)).toList();
        rsvpController.setRsvps(fakeRsvps);
        _dataLoaded = true;
      });
    }
  }

  void callBack(RSVP updatedRsvp) {
    context.read<RSVPController>().updateRsvp(updatedRsvp);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Event.instance.fullResThemeUrl == '' ? kWhite : Colors.transparent,
          elevation: 0,
          toolbarHeight: 64,
          centerTitle: false,
          leading: const SizedBox.shrink(),
          title: Padding(padding: const EdgeInsets.only(top: 20.0), child: Text('Mes RSVPs', style: TextStyle(color: context.read<ThemeController>().getTextColor(), fontSize: 24, fontFamily: "Inter", fontWeight: FontWeight.w600))),
        ),
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child:
              _dataLoaded
                  ? SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              // RSVP Names List
                              Container(
                                padding: const EdgeInsets.only(top: 16),
                                height: 40,
                                child: Consumer<RSVPController>(
                                  builder: (context, rsvpController, _) {
                                    return ValueListenableBuilder<int>(
                                      valueListenable: _currentIndex,
                                      builder: (context, currentIndex, _) {
                                        return ListView.builder(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          scrollDirection: Axis.horizontal,
                                          itemCount: rsvpController.rsvps.length,
                                          itemBuilder: (context, index) {
                                            final rsvp = rsvpController.rsvps[index];
                                            Module? module = _allModules.firstWhereOrNull((module) => module.id == rsvp.moduleId);

                                            if (module == null) {
                                              return const SizedBox.shrink();
                                            }

                                            return GestureDetector(
                                              onTap: () {
                                                _controller.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                                                _currentIndex.value = index;
                                              },
                                              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: Text(module.name, style: TextStyle(color: context.read<ThemeController>().getTextColor(), fontWeight: currentIndex != index ? FontWeight.w500 : FontWeight.w800, fontSize: 18))),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),

                              // PageView
                              SizedBox(
                                height: 576,
                                child: Consumer<RSVPController>(
                                  builder: (context, rsvpController, _) {
                                    return PageView.builder(
                                      controller: _controller,
                                      onPageChanged: (index) {
                                        _currentIndex.value = index;
                                      },
                                      itemCount: rsvpController.rsvps.length,
                                      itemBuilder: (context, index) {
                                        final rsvp = rsvpController.rsvps[index];
                                        Module? module = _allModules.firstWhereOrNull((module) => module.id == rsvp.moduleId);
                                        if (module == null) {
                                          return const SizedBox.shrink();
                                        }
                                        return RsvpModuleCard(module: module, rsvp: rsvp, callBack: callBack);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  : const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64)),
        ),
      ),
    );
  }
}

extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
