import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/themes.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/organizer/theme/browse_type.dart';
import 'package:kapstr/views/organizer/theme/details.dart';
import 'package:loading_skeleton_niu/loading_skeleton.dart';
import 'package:provider/provider.dart';

class ThemeSlider extends StatelessWidget {
  const ThemeSlider({super.key, required this.name, required this.type, this.isOnboarding = false});

  final String name;
  final String type;
  final bool isOnboarding;

  @override
  Widget build(BuildContext context) {
    final List<String> allThemes = context.watch<ThemeController>().themes[type]!;
    List<String> selectedThemes = [];

    // Check if there are fewer than 12 themes
    if (allThemes.length < 12) {
      selectedThemes = allThemes;
    } else {
      // Randomly select 12 themes
      final List<String> randomThemes = List.from(allThemes);
      randomThemes.shuffle(Random()); // Shuffle the list for randomness
      selectedThemes = randomThemes.sublist(0, 12); // Take the first 12 themes
    }
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(name, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500)),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => BrowseThemesFromType(name: name, type: type, isOnBoarding: isOnboarding)));
                },
                child: const Text('Voir tout', style: TextStyle(color: kPrimary, fontSize: 14, fontWeight: FontWeight.w400)),
              ),
            ],
          ),
        ),

        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: selectedThemes.length,
            padding: const EdgeInsets.only(right: 11.0, left: 11.0, top: 8.0, bottom: 20.0),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ThemeDetails(type: type, themeUrl: selectedThemes[index], isOnBoarding: isOnboarding)));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      placeholder: (context, url) => const Placeholder(),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                      imageUrl: selectedThemes[index],
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      width: 150,
                      height: 290,
                      filterQuality: FilterQuality.high,
                      fadeInDuration: const Duration(milliseconds: 300),
                      fadeOutDuration: const Duration(milliseconds: 300),
                    ),
                  ),
                ),
              );
            },
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
    return Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)), child: LoadingSkeleton(colors: const [Color.fromARGB(12, 0, 0, 0), Color.fromARGB(34, 0, 0, 0), Color.fromARGB(6, 0, 0, 0)], height: 250, width: 140));
  }
}
