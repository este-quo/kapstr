import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/modules/golden_book.dart';
import 'package:kapstr/controllers/themes.dart';
import 'package:kapstr/models/modules/golden_book_message.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/organizer/modules/golden_book/card.dart';
import 'package:kapstr/views/organizer/modules/golden_book/evently_card.dart';
import 'package:kapstr/views/organizer/modules/golden_book/evently_message.dart';
import 'package:kapstr/views/organizer/modules/golden_book/guest_card.dart';
import 'package:kapstr/views/organizer/modules/golden_book/list.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:kapstr/widgets/theme/background_theme.dart';
import 'package:provider/provider.dart';

class GoldenBookOrganiser extends StatefulWidget {
  const GoldenBookOrganiser({super.key, required this.moduleId});

  final String moduleId;

  @override
  State<StatefulWidget> createState() => _GoldenBookOrganiserState();
}

class _GoldenBookOrganiserState extends State<GoldenBookOrganiser> {
  late PageController _pageController;

  Future<List<GoldenBookMessage>> _fetchMessages() async {
    try {
      return await context.read<GoldenBookController>().getMessages(widget.moduleId);
    } catch (e) {
      printOnDebug("Erreur lors de la récupération des messages: $e");
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 75,
        toolbarHeight: 40,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: context.read<ThemeController>().getTextColor()), Text('Retour', style: TextStyle(color: context.read<ThemeController>().getTextColor(), fontSize: 14, fontWeight: FontWeight.w500))]),
          ),
        ),
        actions: const [SizedBox(width: 91)],
      ),
      backgroundColor: context.watch<EventsController>().event.fullResThemeUrl == '' ? kWhite : Colors.transparent,
      resizeToAvoidBottomInset: false,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: BackgroundTheme(
        child: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<List<GoldenBookMessage>>(
                    future: _fetchMessages(),
                    builder: ((context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: SizedBox(height: 32, width: 32, child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 32)));
                      } else if (snapshot.hasError) {
                        return const Center(child: Text("Une erreur est survenue", style: TextStyle(color: Colors.white)));
                      } else if (snapshot.hasData) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Livre d\'or', textAlign: TextAlign.left, style: TextStyle(fontSize: 24, color: context.read<ThemeController>().getTextColor(), fontWeight: FontWeight.w600)),
                                  if (snapshot.data!.isNotEmpty)
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => GoldenBookOrganiserList(moduleId: widget.moduleId, messages: snapshot.data!)));
                                      },
                                      child: const Text("Voir la liste", style: TextStyle(color: kPrimary, fontSize: 14, fontWeight: FontWeight.w400)),
                                    ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Subtitle
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0), child: Text('Ils vous ont laissé un mot', textAlign: TextAlign.left, style: TextStyle(fontSize: 14, color: context.read<ThemeController>().getTextColor(), fontWeight: FontWeight.w400))),

                            const SizedBox(height: 16),
                            _buildMessages(snapshot.data!),
                            const SizedBox(height: 16),
                            _buildGuestsRow(snapshot.data!),

                            // Voir la liste complète
                          ],
                        );
                      } else {
                        return const Center(child: Text("Aucun message", style: TextStyle(color: Colors.white)));
                      }
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessages(List<GoldenBookMessage> list) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: PageView.builder(
        controller: _pageController,
        itemCount: list.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return EventlyMessageCard(index: index, length: list.length + 1);
          } else {
            var adjustedIndex = index - 1;
            var message = list[adjustedIndex];
            return MessageCard(moduleId: widget.moduleId, message: message, length: list.length + 1, index: adjustedIndex + 1);
          }
        },
      ),
    );
  }

  Widget _buildGuestsRow(List<GoldenBookMessage> list) {
    return SizedBox(
      height: 96,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: list.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Row(
              children: [
                const SizedBox(width: 16),
                InkWell(
                  onTap: () {
                    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(100), border: Border.all(color: kLighterGrey, width: 1, strokeAlign: BorderSide.strokeAlignOutside)),
                    child: ClipRRect(borderRadius: BorderRadius.circular(100), child: Image.asset('assets/logos/evently_logo.png', fit: BoxFit.cover)),
                  ),
                ),
              ],
            );
          } else {
            var adjustedIndex = index - 1;
            var message = list[adjustedIndex];
            return Row(
              children: [
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    printOnDebug("Index: $index, Adjusted index: $adjustedIndex");
                    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  },
                  child: GuestCard(moduleId: widget.moduleId, message: message),
                ),
                if (index == list.length - 1) const SizedBox(width: 16),
              ],
            );
          }
        },
      ),
    );
  }
}
