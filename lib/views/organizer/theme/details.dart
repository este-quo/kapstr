import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/modules/modules.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/global/events/create/completed.dart';
import 'package:kapstr/views/organizer/home/configuration.dart';
import 'package:kapstr/widgets/buttons/ic_button.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:loading_skeleton_niu/loading_skeleton.dart';
import 'package:provider/provider.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ThemeDetails extends StatefulWidget {
  final String type;
  final String themeUrl;
  final bool isOnBoarding;

  const ThemeDetails({super.key, required this.type, required this.themeUrl, this.isOnBoarding = false});

  @override
  State<ThemeDetails> createState() => _ThemeDetailsState();
}

class _ThemeDetailsState extends State<ThemeDetails> {
  double _opacity = 100;
  bool _isLoading = false;
  late String highResThemeUrl;
  late String lowResThemeUrl;
  late String themeType;

  @override
  @override
  void initState() {
    super.initState();

    themeType = themeType;
    if (themeType == 'popular') {
      final themeName = context.read<EventsController>().getFileNameWithExtension(widget.themeUrl);
      themeType = extractCategory(themeName);
    }

    highResThemeUrl = widget.themeUrl.replaceAll('thumbnails', 'full_res');
    lowResThemeUrl = widget.themeUrl;
  }

  // Function to generate a palette from an image URL
  Future<PaletteGenerator> generatePalette(String imageUrl) async {
    final ImageProvider imageProvider = await loadImage(imageUrl);
    final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(imageProvider, size: const Size(200, 100), maximumColorCount: 7);
    return paletteGenerator;
  }

  Color darkenColor(Color color, [double amount = 0.45]) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Future<ImageProvider> loadImage(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl)).timeout(const Duration(seconds: 20)); // Augmenter le délai d'attente ici
    if (response.statusCode == 200) {
      // En cas de succès, utiliser MemoryImage
      return MemoryImage(response.bodyBytes);
    } else {
      throw Exception('Failed to load image');
    }
  }

  // Function to extract up to 7 colors from the palette
  List<Color> getPaletteColors(PaletteGenerator palette) {
    List<Color> colors = [];
    if (palette.colors.isNotEmpty) {
      colors.addAll(palette.colors.take(7));
    }
    return colors;
  }

  String extractCategory(String themeName) {
    final regex = RegExp(r'(.+)_(\d+)\..+');
    return regex.firstMatch(themeName)?.group(1) ?? '';
  }

  String generateFirestoreURL(String themeType, String themeName) {
    if (themeType != 'custom') {
      return 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/global_themes%2Ffull_res%2Fall%2F$themeType%2F$themeName?alt=media';
    } else {
      return 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/global_themes%2Ffull_res%2Fall%2Fcustom%2F${Event.instance.id}%2F$themeName?alt=media';
    }
  }

  // Méthode pour calculer la luminosité d'une couleur
  double _calculateBrightness(Color color) {
    return color.computeLuminance();
  }

  Future<void> updateEventTheme(String formattedTheme, String themeType, String themeName, List<Color> colors) async {
    List<Color> newColors = [];

    for (Color color in colors) {
      Color darkenedColor = darkenColor(color);
      printOnDebug('Original color: ${colorToHexString(color)}, Darkened color: ${colorToHexString(darkenedColor)}');
      newColors.add(darkenedColor);
    }

    final updateFields = {
      "low_res_theme_url": widget.themeUrl,
      "full_res_theme_url": formattedTheme,
      "theme_opacity": _opacity,
      "theme_type": themeType,
      "theme_name": themeName,
      "theme_colors": newColors.map((color) => colorToHexString(color)).toList(), // Convert Color to hex string
    };

    final eventsController = context.read<EventsController>();
    await eventsController.updateEventFields(fieldsToUpdate: updateFields, eventId: Event.instance.id);
    await eventsController.updateEventTheme(widget.themeUrl, formattedTheme, _opacity, themeType, themeName, newColors.map((color) => colorToHexString(color)).toList());
  }

  Future<bool> isImageBright(String imageUrl) async {
    // Step 1: Generate the palette from the image URL
    final palette = await generatePalette(imageUrl);

    // Step 2: Extract colors from the palette
    List<Color> colors = getPaletteColors(palette);

    // Step 3: Calculate the average brightness
    double totalBrightness = 0;
    for (Color color in colors) {
      totalBrightness += _calculateBrightness(color);
    }

    // Avoid division by zero
    double averageBrightness = colors.isNotEmpty ? totalBrightness / colors.length : 0;

    // Step 4: Determine if the image is bright or dark
    // Threshold can be adjusted, here we use 0.5
    return averageBrightness > 0.5; // Returns true if the image is bright, false if it's dark
  }

  // Helper function to convert a Color to a hex string
  String colorToHexString(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      floatingActionButton: IcButton(
        onPressed: () async {
          final bool bright = await isImageBright(widget.themeUrl);
          if (!bright) {}
          triggerShortVibration();
          if (_isLoading) return;

          setState(() {
            _isLoading = true;
          });

          try {
            final themeName = context.read<EventsController>().getFileNameWithExtension(widget.themeUrl);
            String themeType = widget.type == 'popular' ? extractCategory(themeName) : widget.type;

            final firestoreURL = generateFirestoreURL(themeType, themeName);
            final bool bright = await isImageBright(widget.themeUrl);
            if (themeType == "custom" && !bright) {
              themeType = "dark";
            }
            // Supposons que generatePalette et precacheImage sont déjà optimisés pour utiliser le cache
            final palette = await generatePalette(widget.themeUrl);
            List<Color> colors = getPaletteColors(palette);

            colors.sort((a, b) => _calculateBrightness(a).compareTo(_calculateBrightness(b)));

            // Sélectionner les deux couleurs les plus sombres
            Color darkColor1 = colors.isNotEmpty ? colors.first : Colors.black;
            Color darkColor2 = colors.length > 1 ? colors[1] : Colors.black;

            // Enregistrer les couleurs dans le cache de l'application
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('${Event.instance.id}_darkColor1', darkColor1.toARGB32());
            await prefs.setInt('${Event.instance.id}_darkColor2', darkColor2.toARGB32());

            // Appliquer les couleurs alternées sur les filtres des modules
            bool alternate = false;
            int count = 1;
            for (Module module in Event.instance.modules) {
              if (alternate) {
                module.colorFilter = darkColor2.withValues(alpha: 0.6).toARGB32().toRadixString(16).padLeft(8, '0');
              } else {
                module.colorFilter = darkColor1.withValues(alpha: 0.6).toARGB32().toRadixString(16).padLeft(8, '0');
              }
              await context.read<ModulesController>().updateModuleField(key: 'color_filter', value: module.colorFilter, moduleId: module.id);

              count += 1;

              if (count == 2) {
                count = 0;
                alternate = !alternate;
              }
            }
            await updateEventTheme(firestoreURL, themeType, themeName, colors);

            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => widget.isOnBoarding ? const OnboardingComplete() : const OrgaHomepageConfiguration()), (Route<dynamic> route) => route.isFirst);
          } catch (e) {
            printOnDebug('Error: $e');
          } finally {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          }
        },
        borderColor: const Color.fromARGB(30, 0, 0, 0),
        borderWidth: 1,
        width: MediaQuery.of(context).size.width - 40,
        height: 48,
        radius: 8,
        backgroundColor:
            Event.instance.buttonColor == ''
                ? themeType == 'dark'
                    ? kWhite
                    : kBlack
                : Color(int.parse('0xFF${Event.instance.buttonColor}')),
        child:
            _isLoading
                ? SizedBox(
                  height: 20,
                  width: 20,
                  child:
                      Event.instance.buttonTextColor == ''
                          ? themeType == 'dark'
                              ? const PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64)
                              : const PulsatingLogo(svgPath: 'assets/icons/app/svg_dark.svg', size: 64)
                          : const PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64),
                )
                : Text(
                  'Séléctionner ce thème',
                  style: TextStyle(
                    color:
                        Event.instance.buttonTextColor == ''
                            ? themeType == 'dark'
                                ? kBlack
                                : kWhite
                            : Color(int.parse('0xFF${Event.instance.buttonTextColor}')),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
      ),
      backgroundColor: themeType == 'dark' ? kBlack : kWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: MediaQuery.of(context).size.width - 40,
        toolbarHeight: 40,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: themeType == 'dark' ? kWhite : kBlack), Text('Retour', style: TextStyle(color: themeType == 'dark' ? kWhite : kBlack, fontSize: 14, fontWeight: FontWeight.w500))]),
              ),
              if (themeType == 'custom')
                IconButton(
                  icon: Icon(Icons.delete, size: 16, color: themeType == 'dark' ? kWhite : kBlack),
                  onPressed: () async {
                    bool confirmed = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Confirmer la suppression"),
                          content: const Text("Voulez-vous vraiment supprimer ce thème?"),
                          actions: [TextButton(child: const Text("Annuler"), onPressed: () => Navigator.of(context).pop(false)), TextButton(child: const Text("Supprimer"), onPressed: () => Navigator.of(context).pop(true))],
                        );
                      },
                    );

                    if (confirmed) {
                      await context.read<EventsController>().removeCustomTheme(widget.themeUrl);
                      Navigator.of(context).pop(); // Close the page after deletion
                    }
                  },
                ),
            ],
          ),
        ),
      ),
      body: buildImageContainer(context),
    );
  }

  Widget buildImageContainer(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Opacity(
            opacity: _opacity / 100,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: CachedNetworkImage(
                cacheKey: highResThemeUrl,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fadeInDuration: const Duration(milliseconds: 0),
                fadeOutDuration: const Duration(milliseconds: 0),
                imageUrl: highResThemeUrl,
                placeholder: (context, url) => Image.network(lowResThemeUrl, fit: BoxFit.cover, width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        // Content
        Positioned(
          top: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text('Options du thème', style: TextStyle(color: themeType == 'dark' ? kWhite : kBlack, fontSize: 24, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Opacité', style: TextStyle(color: themeType == 'dark' ? kWhite : kBlack, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize)),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                          thumbColor: themeType == 'dark' ? kWhite : kBlack,
                          overlayColor: themeType == 'dark' ? kWhite : kBlack.withValues(alpha: 0.2),
                          trackShape: const RoundedRectSliderTrackShape(),
                        ),
                        child: Slider(
                          activeColor: themeType == 'dark' ? kWhite : kBlack,
                          inactiveColor: kMediumGrey,
                          value: _opacity,
                          min: 0,
                          max: 100,
                          onChanged: (value) {
                            setState(() {
                              _opacity = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class Placeholder extends StatelessWidget {
  const Placeholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)), child: LoadingSkeleton(colors: const [Color.fromARGB(12, 0, 0, 0), Color.fromARGB(34, 0, 0, 0), Color.fromARGB(6, 0, 0, 0)], height: MediaQuery.of(context).size.height, width: MediaQuery.of(context).size.width));
  }
}
