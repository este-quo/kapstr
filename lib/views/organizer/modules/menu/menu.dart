import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/modules/menu.dart';
import 'package:kapstr/controllers/themes.dart';
import 'package:kapstr/models/modules/menu.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/organizer/modules/invitation_card/editable_text.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:kapstr/widgets/theme/background_theme.dart';

import 'package:provider/provider.dart';

GlobalKey<MyEditableTextState> menuEditableTextKey = GlobalKey<MyEditableTextState>();

class MenuPreview extends StatefulWidget {
  const MenuPreview({super.key});

  @override
  State<MenuPreview> createState() => _MenuPreviewState();
}

class _MenuPreviewState extends State<MenuPreview> {
  Key _uniqueKey = UniqueKey();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMenu();
  }

  Future<void> fetchMenu() async {
    await context.read<MenuModuleController>().getMenuById();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    MenuModule menu = context.watch<MenuModuleController>().currentMenu;

    return Scaffold(
      key: _uniqueKey,
      extendBody: true,
      extendBodyBehindAppBar: true,
      floatingActionButton: GestureDetector(
        onTap: () async {
          menuEditableTextKey.currentState!.toggleEditing();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(color: kBlack, borderRadius: BorderRadius.circular(999), border: Border.all(color: const Color.fromARGB(30, 0, 0, 0), width: 1, strokeAlign: BorderSide.strokeAlignOutside)),
          child: const Icon(Icons.brush_rounded, color: kWhite, size: 22),
        ),
      ),
      appBar: AppBar(
        backgroundColor: context.read<EventsController>().event.fullResThemeUrl == "" ? kWhite : Colors.transparent,
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
        actions: [
          TextButton(
            onPressed: () async {
              // Show confirmation dialog
              final bool? confirmed = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: kWhite,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    surfaceTintColor: kWhite,
                    title: const Text('Confirmation'),
                    content: const Text('Êtes-vous sûr de vouloir réinitialiser le menu ?', style: TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w400)),
                    actions: <Widget>[TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')), TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Réinitialiser'))],
                  );
                },
              );

              if (confirmed ?? false) {
                await context.read<MenuModuleController>().resetMenu();
                setState(() {
                  _uniqueKey = UniqueKey();
                });
              }
            },
            child: const Text('Réinitialiser', style: TextStyle(color: kPrimary, fontSize: 14, fontWeight: FontWeight.w400)),
          ),
        ],
      ),
      body: BackgroundTheme(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child:
                    !isLoading
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            MyEditableText(
                              key: menuEditableTextKey,
                              initialText: menu.title,
                              onConfirmation: (value, map) async {
                                menu.title = value;
                                await context.read<MenuModuleController>().updateStyleMap('titleStyle', map);
                              },
                              styleMap: menu.titleStyle,
                            ),
                            const SizedBox(height: 24),
                            MyEditableText(
                              initialText: menu.entry,
                              onConfirmation: (value, map) async {
                                menu.entry = value;
                                await context.read<MenuModuleController>().updateStyleMap('entryStyle', map);
                              },
                              styleMap: menu.entryStyle,
                            ),
                            const SizedBox(height: 8),
                            MyEditableText(
                              initialText: menu.entryContent,
                              onConfirmation: (value, map) async {
                                menu.entryContent = value;
                                await context.read<MenuModuleController>().updateStyleMap('entryContentStyle', map);
                              },
                              styleMap: menu.entryContentStyle,
                            ),
                            const SizedBox(height: 24),
                            MyEditableText(
                              initialText: menu.mainCourse,
                              onConfirmation: (value, map) async {
                                menu.mainCourse = value;
                                await context.read<MenuModuleController>().updateStyleMap('mainCourseStyle', map);
                              },
                              styleMap: menu.mainCourseStyle,
                            ),
                            const SizedBox(height: 8),
                            MyEditableText(
                              initialText: menu.mainCourseContent,
                              onConfirmation: (value, map) async {
                                menu.mainCourseContent = value;
                                await context.read<MenuModuleController>().updateStyleMap('mainCourseContentStyle', map);
                              },
                              styleMap: menu.mainCourseContentStyle,
                            ),
                            const SizedBox(height: 24),
                            MyEditableText(
                              initialText: menu.dessert,
                              onConfirmation: (value, map) async {
                                menu.dessert = value;
                                await context.read<MenuModuleController>().updateStyleMap('dessertStyle', map);
                              },
                              styleMap: menu.dessertStyle,
                            ),
                            const SizedBox(height: 8),
                            MyEditableText(
                              initialText: menu.dessertContent,
                              onConfirmation: (value, map) async {
                                menu.dessertContent = value;
                                await context.read<MenuModuleController>().updateStyleMap('dessertContentStyle', map);
                              },
                              styleMap: menu.dessertContentStyle,
                            ),
                            const SizedBox(height: 24),
                            MyEditableText(
                              initialText: menu.names,
                              onConfirmation: (value, map) async {
                                menu.names = value;
                                await context.read<MenuModuleController>().updateStyleMap('namesStyles', map);
                              },
                              styleMap: menu.namesStyles,
                            ),
                          ],
                        )
                        : const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
