import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/themes.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/global/events/create/completed.dart';
import 'package:kapstr/views/organizer/home/configuration.dart';
import 'package:kapstr/views/organizer/theme/browse_type.dart';
import 'package:kapstr/views/organizer/theme/details.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class BrowseThemes extends StatefulWidget {
  const BrowseThemes({super.key, this.isOnBoarding = false});
  final bool isOnBoarding;

  @override
  _BrowseThemesState createState() => _BrowseThemesState();
}

class _BrowseThemesState extends State<BrowseThemes> {
  final PageController _pageController = PageController();
  List<String> _themeTypes = ['custom', 'popular', 'color', 'dark', 'floral', 'luxe', 'other'];
  final Map<String, String> _themeTypesMap = {'custom': 'Mes thèmes', 'popular': 'Populaires', 'color': 'Couleur', 'dark': 'Sombre', 'floral': 'Floral', 'luxe': 'Luxe', 'other': 'Autres'};
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    updateThemeTypes();
  }

  void updateThemeTypes() {
    if (Event.instance.customThemeUrls.isEmpty) {
      _themeTypes = _themeTypes.where((element) => element != 'custom').toList();
      _currentPage = _themeTypes.contains(_themeTypes[_currentPage]) ? _currentPage : 0;
    } else if (!_themeTypes.contains('custom')) {
      _themeTypes = ['custom', ..._themeTypes];
      _currentPage = 0;
    }

    // Utilisation de addPostFrameCallback pour différer l'appel à jumpToPage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentPage);
        setState(() {});
      }
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          widget.isOnBoarding
              ? MainButton(
                child: const Text('Thème aléatoire', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w400)),
                onPressed: () {
                  final String randomType = _themeTypes[Random().nextInt(_themeTypes.length)];
                  final List<String> allThemes = context.read<ThemeController>().themes[randomType]!;
                  final String randomTheme = allThemes[Random().nextInt(allThemes.length)];

                  Navigator.push(context, MaterialPageRoute(builder: (context) => ThemeDetails(type: randomType, themeUrl: randomTheme, isOnBoarding: widget.isOnBoarding)));
                },
              )
              : null,
      appBar:
          !widget.isOnBoarding
              ? AppBar(
                backgroundColor: kWhite,
                surfaceTintColor: kWhite,
                elevation: 0,
                leadingWidth: 75,
                toolbarHeight: 40,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Row(children: [Icon(size: 16, Icons.arrow_back_ios, color: Colors.black), Text('Retour', style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500))]),
                  ),
                ),
              )
              : null,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4.0, left: 16.0, bottom: 8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Thèmes', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600)),
                      if (widget.isOnBoarding)
                        TextButton(
                          onPressed: (() {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OnboardingComplete()));
                          }),
                          child: const Text('Passer', style: TextStyle(color: kPrimary, fontSize: 16, fontWeight: FontWeight.w400)),
                        ),
                      if (!widget.isOnBoarding)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () async {
                                final updateFields = {"low_res_theme_url": '', "full_res_theme_url": '', "theme_opacity": 100, "theme_type": '', "theme_name": '', "text_color": '', "button_color": '', "button_text_color": ''};

                                Event.instance.textColor = '';
                                Event.instance.buttonColor = '';
                                Event.instance.buttonTextColor = '';
                                Event.instance.lowResThemeUrl = '';
                                Event.instance.fullResThemeUrl = '';
                                Event.instance.themeOpacity = 100;
                                Event.instance.themeType = '';
                                Event.instance.themeName = '';

                                await context.read<EventsController>().updateEventFields(fieldsToUpdate: updateFields, eventId: Event.instance.id);

                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thème retiré avec succès !', style: TextStyle(color: kWhite, fontSize: 14, fontWeight: FontWeight.w400)), backgroundColor: kSuccess, duration: Duration(seconds: 2)));

                                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const OrgaHomepageConfiguration()), (Route<dynamic> route) => route.isFirst);
                              },
                              icon: const Icon(Icons.restart_alt_rounded, color: kDanger, size: 24),
                            ),
                            IconButton(
                              onPressed: () async {
                                final ImagePicker picker = ImagePicker();
                                final XFile? image = await picker.pickImage(source: ImageSource.gallery);

                                if (image != null) {
                                  // Affichez une Snackbar pour indiquer que l'image est en cours de chargement
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chargement de l\'image en cours...'), duration: Duration(seconds: 3)));

                                  try {
                                    File fullResImage = File(image.path);

                                    final Directory tempDir = await getTemporaryDirectory();
                                    String tempPath = tempDir.path;

                                    XFile? thumbnailImage = (await FlutterImageCompress.compressAndGetFile(fullResImage.absolute.path, '$tempPath/thumbnail_${DateTime.now().millisecondsSinceEpoch}.jpg', quality: 50));

                                    FirebaseStorage storage = FirebaseStorage.instance;

                                    String fullResPath = 'global_themes/full_res/all/custom/${Event.instance.id}/${image.name}';
                                    await storage.ref(fullResPath).putFile(fullResImage);

                                    String thumbnailPath = 'global_themes/thumbnails/all/custom/${Event.instance.id}/${image.name}';
                                    await storage.ref(thumbnailPath).putFile(File(thumbnailImage!.path));
                                    String thumbnailUrl = await storage.ref(thumbnailPath).getDownloadURL();

                                    if (!Event.instance.customThemeUrls.contains(thumbnailUrl)) {
                                      setState(() {
                                        Event.instance.customThemeUrls.add(thumbnailUrl);
                                        updateThemeTypes(); // Mettez à jour les types de thèmes après ajout
                                      });
                                    }

                                    context.read<EventsController>().updateEvent(Event.instance);

                                    context.read<EventsController>().updateEventFields(fieldsToUpdate: {'custom_theme_urls': Event.instance.customThemeUrls}, eventId: Event.instance.id);

                                    // Affichez une Snackbar pour indiquer que le téléchargement a réussi
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image téléchargée avec succès !')));
                                  } catch (e) {
                                    // Affichez une Snackbar pour indiquer qu'il y a eu une erreur
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors du téléchargement de l\'image.')));
                                  }
                                }
                              },
                              icon: const Icon(Icons.download, color: Colors.black, size: 24),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.builder(
                padding: const EdgeInsets.only(right: 16, left: 16.0),
                scrollDirection: Axis.horizontal,
                itemCount: _themeTypes.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        _themeTypesMap[_themeTypes[index]]!,
                        style: TextStyle(color: _currentPage == index ? kBlack : kGrey, fontWeight: FontWeight.w500, fontSize: 18, decoration: _currentPage == index ? TextDecoration.underline : TextDecoration.none, decorationStyle: TextDecorationStyle.solid, decorationThickness: 1),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _themeTypes.length,
                itemBuilder: (context, index) {
                  return BrowseThemesFromType(
                    name: _themeTypesMap[_themeTypes[index]]!,
                    type: _themeTypes[index],
                    isOnBoarding: widget.isOnBoarding,
                    callBack: () {
                      updateThemeTypes();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
