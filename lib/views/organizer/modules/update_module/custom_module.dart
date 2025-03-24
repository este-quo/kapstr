import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';

import 'package:kapstr/controllers/modules/modules.dart';
import 'package:kapstr/widgets/layout/spacing.dart';
import 'package:kapstr/helpers/format_colors.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/views/organizer/home/configuration.dart';
import 'package:kapstr/views/organizer/modules/update_module/choose_module_color_filter.dart';
import 'package:kapstr/views/organizer/modules/update_module/choose_text_module_color.dart';

class CustomModule extends StatefulWidget {
  const CustomModule({super.key, required this.moduleId, required this.module});

  final String moduleId;
  final Module module;

  @override
  State<StatefulWidget> createState() => _CustomModuleState();
}

class _CustomModuleState extends State<CustomModule> {
  late TextEditingController _nameController;
  late int textSize = widget.module.textSize;
  late String selectedFont = widget.module.fontType;

  Future<void> saveData() async {
    if (_nameController.text != '') {
      widget.module.name = _nameController.text;
      await context.read<ModulesController>().updateModuleField(moduleId: widget.module.id, key: "name", value: _nameController.text);

      if (context.mounted) {
        await context.read<EventsController>().updateModules(await context.read<ModulesController>().getModules(Event.instance.id));
      }
    }

    await context
        .read<ModulesController>()
        .updateTypoModule(moduleId: widget.moduleId, selectedFont: selectedFont)
        .then((value) {
          const SnackBar(content: Text('Typographie du module mise à jour'));
        })
        .onError((error, stackTrace) {
          const SnackBar(content: Text('Erreur lors de la mise à jour de la typographie du module'), backgroundColor: kDanger);
        });

    await context
        .read<ModulesController>()
        .updateFontSize(moduleId: widget.moduleId, textSize: textSize)
        .then((value) {
          const SnackBar(content: Text('Typographie du module mise à jour'));
        })
        .onError((error, stackTrace) {
          const SnackBar(content: Text('Erreur lors de la mise à jour de la typographie du module'), backgroundColor: kDanger);
        });

    await context.read<EventsController>().updateModules(await context.read<ModulesController>().getModules(Event.instance.id));
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.module.name);
    textSize = widget.module.textSize;
    selectedFont = widget.module.fontType;
  }

  @override
  Widget build(BuildContext context) {
    for (String font in Event.instance.favoriteFonts) {
      printOnDebug(font);
    }

    if (Event.instance.favoriteFonts.isEmpty) {
      printOnDebug('No favorite fonts');
    }
    return Consumer<ModulesController>(
      builder: (context, value, child) {
        return Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: MainButton(
            onPressed: () async {
              triggerShortVibration();

              await saveData();
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const OrgaHomepageConfiguration()), (Route<dynamic> route) => route.isFirst);
            },
            backgroundColor: kBlack,
            child: const Text('Sauvegarder', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w500)),
          ),
          appBar: AppBar(
            backgroundColor: kWhite,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 75,
            toolbarHeight: 40,
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: GestureDetector(onTap: () => Navigator.of(context).pop(_nameController.text), child: const Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: kBlack), Text('Retour', style: TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w500))])),
            ),
            actions: const [SizedBox(width: 91)],
          ),
          body: SafeArea(
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Personnaliser ${widget.module.name}', textAlign: TextAlign.left, style: const TextStyle(fontSize: 24, color: kBlack, fontWeight: FontWeight.w600)),

                      const SizedBox(height: 8),

                      // Subtitle
                      const Text('Personnalisez la couleur, la typographie et la taille du texte de votre module', textAlign: TextAlign.left, style: TextStyle(fontSize: 14, color: kBlack, fontWeight: FontWeight.w300)),

                      const SizedBox(height: 16),

                      const Text('Prévisualisation', style: TextStyle(fontSize: 18, color: kBlack, fontWeight: FontWeight.w500)),

                      const SizedBox(height: 8),

                      // Custom module image
                      Container(
                        width: MediaQuery.of(context).size.width - 40,
                        height: MediaQuery.of(context).size.width - 40,
                        decoration: BoxDecoration(
                          color: widget.module.image == '' ? kBlack.withValues(alpha: 0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(image: NetworkImage(widget.module.image), colorFilter: ColorFilter.mode(fromHex(widget.module.colorFilter), BlendMode.srcOver), fit: BoxFit.cover, alignment: Alignment.center),
                        ),
                        child: Center(child: TextField(controller: _nameController, textAlign: TextAlign.center, style: TextStyle(color: fromHex(widget.module.textColor), fontSize: textSize.toDouble(), fontWeight: FontWeight.w600, fontFamily: GoogleFonts.getFont(selectedFont).fontFamily))),
                      ),
                      const SizedBox(height: 24),

                      const Text('Couleur du filtre', style: TextStyle(fontSize: 18, color: kBlack, fontWeight: FontWeight.w500)),

                      const SizedBox(height: 8),

                      GestureDetector(
                        onTap: () async {
                          final selectedColor = await Navigator.push<String>(context, MaterialPageRoute(builder: (context) => ChooseModuleColorFilter(moduleId: widget.moduleId, module: widget.module)));

                          if (selectedColor != null) {
                            setState(() {
                              widget.module.colorFilter = selectedColor;
                            });
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width - 40,
                          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: kBlack, width: 1))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(widget.module.colorFilter, style: const TextStyle(color: kLightGrey, fontSize: 14, fontWeight: FontWeight.w400))), xSmallSpacerW(context)]),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(border: Border.all(color: kLighterGrey, strokeAlign: BorderSide.strokeAlignOutside), borderRadius: BorderRadius.circular(1000), color: widget.module.colorFilter == '' ? Colors.transparent : fromHex(widget.module.colorFilter)),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text('Couleur du texte', style: TextStyle(fontSize: 18, color: kBlack, fontWeight: FontWeight.w500)),

                      const SizedBox(height: 8),

                      GestureDetector(
                        onTap: () async {
                          final selectedColor = await Navigator.push<String>(context, MaterialPageRoute(builder: (context) => ChooseTextModuleColor(moduleId: widget.moduleId, module: widget.module)));

                          if (selectedColor != null) {
                            setState(() {
                              widget.module.textColor = selectedColor;
                            });
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width - 40,
                          decoration: (const BoxDecoration(border: Border(bottom: BorderSide(color: kBlack, width: 1)))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(widget.module.textColor, style: const TextStyle(color: kLightGrey, fontSize: 14, fontWeight: FontWeight.w400)))]),
                              Container(width: 20, height: 20, decoration: BoxDecoration(border: Border.all(color: kLighterGrey, strokeAlign: BorderSide.strokeAlignOutside), borderRadius: BorderRadius.circular(1000), color: fromHex(widget.module.textColor))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text('Typographie', style: TextStyle(fontSize: 18, color: kBlack, fontWeight: FontWeight.w500)),

                      const SizedBox(height: 8),

                      GestureDetector(
                        onTap: () async {
                          final favoriteFonts = List<String>.from(Event.instance.favoriteFonts)..sort();
                          final allFonts = List<String>.from(kGoogleFonts)..sort();

                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                backgroundColor: kWhite,
                                surfaceTintColor: kWhite,
                                title: const Text('Choisir une typographie', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kBlack)),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('Récentes :', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                                      ...favoriteFonts.map((font) {
                                        return ListTile(
                                          title: Text(font, style: GoogleFonts.getFont(font)),
                                          selected: font == selectedFont,
                                          onTap: () {
                                            Navigator.of(context).pop(font);
                                          },
                                        );
                                      }),
                                      const SizedBox(height: 16),
                                      const Text('Toutes :', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                                      ...allFonts.map((font) {
                                        return ListTile(
                                          title: Text(font, style: GoogleFonts.getFont(font)),
                                          selected: font == selectedFont,
                                          onTap: () {
                                            Navigator.of(context).pop(font); // Pop the dialog and return the selected font
                                          },
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                                actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')), TextButton(onPressed: () => Navigator.of(context).pop(selectedFont), child: const Text('Valider'))],
                              );
                            },
                          ).then((selectedFont) {
                            if (selectedFont != null) {
                              setState(() {
                                this.selectedFont = selectedFont;
                                widget.module.fontType = selectedFont;
                              });
                            }
                          });
                        },
                        child: Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width - 40,
                            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: kBlack, width: 1))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(padding: const EdgeInsets.symmetric(vertical: 8), child: const Text('Typographie', style: TextStyle(color: kLightGrey, fontSize: 14, fontWeight: FontWeight.w400))),
                                Text(selectedFont, style: TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w400, fontFamily: GoogleFonts.getFont(selectedFont).fontFamily)),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text('Taille du texte', style: TextStyle(fontSize: 18, color: kBlack, fontWeight: FontWeight.w500)),

                      const SizedBox(height: 8),

                      GestureDetector(
                        onTap: () {
                          showDialog<int>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                backgroundColor: kWhite,
                                surfaceTintColor: kWhite,
                                title: Center(child: Text('Taille du texte', style: TextStyle(color: kYellow, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize))),
                                content: StatefulBuilder(
                                  builder: (context, sBsetState) {
                                    return NumberPicker(
                                      haptics: true,
                                      selectedTextStyle: const TextStyle(color: kPrimary, fontSize: 20, fontWeight: FontWeight.w500),
                                      value: textSize,
                                      minValue: 8,
                                      maxValue: 92,
                                      onChanged: (value) {
                                        setState(() {
                                          textSize = value;
                                          widget.module.textSize = value;
                                        });

                                        sBsetState(() => textSize = value);
                                      },
                                    );
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text("Valider", style: TextStyle(color: kPrimary, fontSize: 16, fontWeight: FontWeight.w500)),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width - 40,
                          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: kBlack, width: 1))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(child: const Row(children: [Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Taille du texte', style: TextStyle(color: kLightGrey, fontSize: 14, fontWeight: FontWeight.w400)))])),
                              Text('$textSize', style: const TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w400)),
                            ],
                          ),
                        ),
                      ),
                      largeSpacerH(context),

                      const SizedBox(height: 12),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: TextButton(
                          onPressed: () async {
                            await context.read<ModulesController>().updateAllModulesWithChoosenCustom(colorFilter: widget.module.colorFilter, textColor: widget.module.textColor, textSize: textSize, font: selectedFont);

                            if (!mounted) return;
                            context.read<EventsController>().updateModules(await context.read<ModulesController>().getModules(Event.instance.id));

                            if (!mounted) return;
                            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const OrgaHomepageConfiguration()), (Route<dynamic> route) => route.isFirst);
                          },
                          child: const Text(textAlign: TextAlign.center, 'Appliquer cette personnalisation sur tous les modules', style: TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w400, decoration: TextDecoration.underline)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: TextButton(
                          onPressed: (() async {
                            //show confirmation dialog
                            showReinitAlertDialog(context);
                          }),
                          child: const Text('Réinitialiser la personnalisation du module', textAlign: TextAlign.center, style: TextStyle(color: kDanger, fontSize: 14, fontWeight: FontWeight.w400, decoration: TextDecoration.underline, decorationColor: kDanger)),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  showReinitAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("Oui", style: TextStyle(color: kYellow, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize)),
      onPressed: () async {
        await context.read<ModulesController>().clearDesign(moduleId: widget.moduleId);

        if (!mounted) return;
        context.read<EventsController>().updateModules(await context.read<ModulesController>().getModules(Event.instance.id));

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const OrgaHomepageConfiguration()), (Route<dynamic> route) => route.isFirst);
      },
    );

    Widget cancelButton = TextButton(
      child: Text("J'annule", style: TextStyle(color: kYellow, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize)),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      surfaceTintColor: kWhite,
      backgroundColor: kWhite,
      title: Text("Réinitialisation du module", style: TextStyle(color: kBlack, fontSize: Theme.of(context).textTheme.titleMedium!.fontSize)),
      content: Text("Êtes-vous sûr ?", style: TextStyle(color: kBlack, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize)),
      actions: [okButton, cancelButton],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
