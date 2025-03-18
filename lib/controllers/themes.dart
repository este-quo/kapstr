import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ThemeController extends ChangeNotifier {
  String textColor = '';
  String buttonColor = '';
  String buttonTextColor = '';
  bool _isTransitioning = false;

  bool get isTransitioning => _isTransitioning;

  void setTransitioning(bool value) {
    _isTransitioning = value;
    notifyListeners();
  }

  void initTheme({String? textColor, String? buttonColor, String? buttonTextColor}) {
    this.textColor = textColor ?? '';
    this.buttonColor = buttonColor ?? '';
    this.buttonTextColor = buttonTextColor ?? '';
  }

  void updateTextColor(String color) {
    textColor = color;
    notifyListeners();
  }

  void updateButtonColor(String color) {
    buttonColor = color;
    notifyListeners();
  }

  void updateButtonTextColor(String color) {
    buttonTextColor = color;
    notifyListeners();
  }

  Color getTextColor({Color? color}) {
    print(Event.instance.themeType);
    if (textColor == '' && Event.instance.themeType != "dark") {
      return color ?? kBlack;
    } else if (textColor == '' && Event.instance.themeType == "dark") {
      return color ?? kWhite;
    }

    return Color(int.parse('0xFF$textColor'));
  }

  Color getButtonColor({Color? color}) {
    if (buttonColor == '' && Event.instance.themeType != "dark") {
      return color ?? kBlack;
    } else if (buttonColor == '' && Event.instance.themeType == "dark") {
      return color ?? kWhite;
    }

    return Color(int.parse('0xFF$buttonColor'));
  }

  Color getButtonTextColor({Color? color}) {
    if (buttonTextColor == '' && Event.instance.themeType != "dark") {
      return color ?? kWhite;
    } else if (buttonTextColor == '' && Event.instance.themeType == "dark") {
      return color ?? kBlack;
    }

    return Color(int.parse('0xFF$buttonTextColor'));
  }

  Map<String, List<String>> themes = {'popular': [], 'color': [], 'dark': [], 'floral': [], 'luxe': [], 'other': []};

  // Specific theme indexes designated as 'popular'
  final Map<String, List<int>> popularThemeIndexes = {
    'color': [21, 1, 18, 26, 28, 29, 30, 36, 37, 39, 40, 41, 42, 43, 47, 49, 51, 53, 60, 62, 66, 87],
    'dark': [24, 15, 26, 32, 38, 39, 55],
    'floral': [106, 107, 109, 117, 111, 10, 100, 55, 63, 98, 80, 81, 63, 58, 69],
    'luxe': [1, 13, 34, 37, 43, 50, 52, 51, 54, 58, 59, 67, 73, 85, 88, 57, 32, 4],
    'other': [8, 57, 43],
  };

  Future<void> clearThemesCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('themes'); // Supprime l'entrée 'themes' du cache
  }

  Future<void> fetchAllThemes() async {
    // printOnDebug('Clearing themes');
    // await clearThemesCache();
    // printOnDebug('Themes cleared');

    try {
      // Try loading from cache first
      if (await loadThemesFromCache()) {
        printOnDebug('Themes loaded from cache');
      } else {
        printOnDebug('Fetching themes from Firebase');
        await Future.wait([_fetchThemes('color'), _fetchThemes('dark'), _fetchThemes('floral'), _fetchThemes('luxe'), _fetchThemes('other')]);
        await populatePopularThemes();
        // After fetching, save themes to cache
        saveThemesToCache();
      }
    } catch (e) {
      printOnDebug('Error fetching themes: $e');
    }
  }

  Future<void> saveThemesToCache() async {
    final prefs = await SharedPreferences.getInstance();
    final String themesJson = json.encode({'data': themes, 'timestamp': DateTime.now().millisecondsSinceEpoch});
    await prefs.setString('themes', themesJson);
  }

  Future<bool> loadThemesFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final String? themesJson = prefs.getString('themes');
    if (themesJson != null) {
      final Map<String, dynamic> cacheData = json.decode(themesJson);
      final DateTime cacheTime = DateTime.fromMillisecondsSinceEpoch(cacheData['timestamp']);
      final DateTime currentTime = DateTime.now();

      if (currentTime.difference(cacheTime).inHours > 168) {
        // Cache expires after 1 week hours
        return false;
      }

      themes = (cacheData['data'] as Map<String, dynamic>).map((category, themeList) {
        return MapEntry(category, List<String>.from(themeList));
      });

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> populatePopularThemes() async {
    themes['popular'] = [];

    popularThemeIndexes.forEach((category, indexes) {
      // Ensure the category exists in the fetched themes map
      if (themes.containsKey(category)) {
        // Filter themes that match the popular indexes
        List<String> categoryThemes = themes[category]!;
        List<String> selectedPopularThemes = [];

        for (int index in indexes) {
          String searchString = '${category}_$index';
          for (String themeUrl in categoryThemes) {
            if (themeUrl.contains(searchString)) {
              selectedPopularThemes.add(themeUrl);
              break;
            }
          }
        }
        // Add the selected popular themes to the 'popular' category
        themes['popular']!.addAll(selectedPopularThemes);
      }
    });

    notifyListeners();
  }

  Future<void> _fetchThemes(String category) async {
    try {
      ListResult result = await FirebaseStorage.instance.ref('global_themes/thumbnails/all/$category').listAll();

      List<String> fetchedThemes = [];
      for (var ref in result.items) {
        String imageUrl = await ref.getDownloadURL();
        fetchedThemes.add(imageUrl);
      }

      themes[category] = fetchedThemes;
      notifyListeners();
    } catch (e) {
      // Handle errors specific to this category
      printOnDebug('Une erreur est survenue: $e');
    }
  }
}
