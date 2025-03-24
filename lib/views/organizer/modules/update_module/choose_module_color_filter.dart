import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/modules/modules.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/views/global/theme_custom/favorite_colors.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:kapstr/widgets/layout/spacing.dart';
import 'package:kapstr/helpers/format_colors.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/views/organizer/home/configuration.dart';
import 'package:provider/provider.dart';

class ChooseModuleColorFilter extends StatefulWidget {
  final Module module;
  final String moduleId;
  const ChooseModuleColorFilter({super.key, required this.module, required this.moduleId});

  @override
  State<StatefulWidget> createState() => _ChooseModuleColorFilterState();
}

class _ChooseModuleColorFilterState extends State<ChooseModuleColorFilter> {
  String? newColor;
  late Color myColor = widget.module.colorFilter == '' ? kModuleFilterTransparent : fromHex(widget.module.colorFilter);

  List<Color> defaultColors = [kModuleFilterTransparent, kModuleFilterOrange, kModuleFilterPurple, kModuleFilterDarkGreen, kModuleFilterRed, kModuleFilterCyan, kModuleFilterDarkPurple, kModuleFilterYellow, kModuleFilterGold];

  List<Color> colors = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initColors();
    });
  }

  Future<void> initColors() async {
    final eventColors = context.read<EventsController>().event.themeColors;
    if (eventColors.isEmpty) {
      colors = defaultColors;
    } else {
      colors =
          eventColors.map((colorString) {
            return Color(_hexToColor(colorString));
          }).toList();
    }
    setState(() {}); // Ensure the widget rebuilds with the new colors.
  }

  // Helper function to convert a hex string to an integer value
  int _hexToColor(String hexString) {
    // Ensure the hex string starts with '#'
    if (!hexString.startsWith('#')) {
      hexString = '#$hexString';
    }

    // Remove the leading '#' if present
    hexString = hexString.replaceFirst('#', '');

    // If the hex string is in the format RRGGBB, add 'FF' for the alpha value
    if (hexString.length == 6) {
      hexString = 'FF$hexString';
    }

    // Parse the hex string to an integer
    return int.parse(hexString, radix: 16);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      ),
      floatingActionButton: MainButton(
        onPressed: () async {
          triggerShortVibration();

          String colorValue = myColor == kModuleFilterTransparent ? '00000000' : myColor.toARGB32().toRadixString(16).padLeft(8, '0');

          if (!Event.instance.favoriteColors.contains(colorValue)) {
            Event.instance.favoriteColors.insert(0, colorValue);
          } else {
            Event.instance.favoriteColors.remove(colorValue);
            Event.instance.favoriteColors.insert(0, colorValue);
          }

          await context.read<EventsController>().updateFavoriteColors(color: colorValue);

          if (!mounted) return;

          await context.read<ModulesController>().updateColorFilter(color: myColor == kModuleFilterTransparent ? '' : colorValue, moduleId: widget.moduleId);
          if (!mounted) return;
          Navigator.pop(context, colorValue);
        },
        child: const Text('Valider', style: TextStyle(color: kWhite, fontWeight: FontWeight.w500, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Choisir une couleur', textAlign: TextAlign.left, style: TextStyle(fontSize: 24, color: kBlack, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              const Text('Découvrez nos suggestions de couleurs harmonieuses, adaptées pour le thème que vous avez sélectionné.', textAlign: TextAlign.start, style: TextStyle(fontSize: 14, color: kBlack, fontWeight: FontWeight.w300)),
              const SizedBox(height: 16),

              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8.0, mainAxisSpacing: 8.0),
                  itemCount: colors.length + 1, // Add 1 for the palette button
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return GestureDetector(
                        onTap: (() {
                          triggerShortVibration();

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                surfaceTintColor: kWhite,
                                backgroundColor: kWhite,
                                title: const Text('Choisissez une couleur'),
                                content: SingleChildScrollView(
                                  child: ColorPicker(
                                    // Use FlexColorPicker's API
                                    pickersEnabled: const <ColorPickerType, bool>{ColorPickerType.wheel: true, ColorPickerType.primary: false, ColorPickerType.accent: false},
                                    color: myColor, // Initial color
                                    onColorChanged: (Color color) {
                                      setState(() {
                                        myColor = color.withValues(alpha: 0.6);
                                      });
                                    },
                                    width: 44,
                                    height: 44,
                                    borderRadius: 22,
                                  ),
                                ),
                                actions: <Widget>[
                                  ElevatedButton(
                                    child: const Text('Je valide', style: TextStyle(color: kYellow)),
                                    onPressed: () {
                                      Navigator.of(context).pop(); //dismiss the color picker
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }),
                        child: Container(
                          decoration: BoxDecoration(
                            color: myColor, // Set the initial color or the selected color
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: kBorderColor, width: 1, strokeAlign: BorderSide.strokeAlignOutside),
                          ),
                          child: Padding(padding: const EdgeInsets.all(12.0), child: Image.asset('assets/chromatic_wheel.png')),
                        ),
                      );
                    } else {
                      // Display the colors from the list
                      return GestureDetector(
                        onTap: () {
                          triggerShortVibration();
                          setState(() {
                            myColor = colors[index - 1].withValues(alpha: 0.6);
                          });
                        },
                        child: Stack(
                          children: [
                            Container(decoration: BoxDecoration(color: colors[index - 1].withValues(alpha: 1.0), borderRadius: BorderRadius.circular(8.0), border: Border.all(color: kBorderColor, width: 1, strokeAlign: BorderSide.strokeAlignOutside))),

                            // Display a checkmark if the color is selected
                            if (myColor == colors[index - 1].withValues(alpha: 0.6))
                              Positioned(right: 4, bottom: 4, child: Container(padding: EdgeInsets.all(2), decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(100.0)), child: const Icon(Icons.check, color: kBlack, size: 12))),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Couleur séléctionnée :', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: kBlack)),
                  xSmallSpacerW(context),
                  Container(width: 25, height: 25, decoration: BoxDecoration(color: myColor, borderRadius: BorderRadius.circular(100.0), border: Border.all(color: kBorderColor, width: 1, strokeAlign: BorderSide.strokeAlignOutside))),
                ],
              ),

              const SizedBox(height: 16),
              // Favorite colors
              const Text('Récentes', style: TextStyle(color: kBlack, fontSize: 18, fontWeight: FontWeight.w500)),

              const SizedBox(height: 12),

              SizedBox(
                child: FavoriteColors(
                  initialColor: myColor,
                  onColorSelected: (Color color) {
                    setState(() {
                      triggerShortVibration();

                      myColor = color.withValues(alpha: 0.6);
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),

              TextButton(
                onPressed: () async {
                  triggerShortVibration();

                  await context.read<ModulesController>().updateFieldForAllModules(key: "color_filter", value: myColor.toARGB32().toRadixString(16).padLeft(8, '0'));

                  for (var module in Event.instance.modules) {
                    module.colorFilter = myColor.toARGB32().toRadixString(16).padLeft(8, '0');
                  }

                  if (!mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const OrgaHomepageConfiguration()), (Route<dynamic> route) => route.isFirst);
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Text('Appliquer cette couleur sur tous les modules', textAlign: TextAlign.center, style: TextStyle(color: kBlack, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize, fontWeight: FontWeight.w400, decoration: TextDecoration.underline)),
                ),
              ),
              kNavBarSpacer(context),
            ],
          ),
        ),
      ),
    );
  }
}
