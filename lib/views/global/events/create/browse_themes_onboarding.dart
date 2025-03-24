import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/themes.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/global/events/create/completed.dart';
import 'package:kapstr/views/organizer/theme/details.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:kapstr/widgets/custom_svg_picture.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:loading_skeleton_niu/loading_skeleton.dart';
import 'package:provider/provider.dart';

class BrowseThemesOnBoarding extends StatefulWidget {
  const BrowseThemesOnBoarding({super.key});

  @override
  State<BrowseThemesOnBoarding> createState() => _BrowseThemesOnBoardingState();
}

class _BrowseThemesOnBoardingState extends State<BrowseThemesOnBoarding> {
  final ScrollController _scrollController = ScrollController();
  List<String> images = [];
  bool isLoading = false;
  int startIndex = 0;
  final int batchSize = 6;

  List<String> types = ['popular', 'color', 'dark', 'floral', 'luxe', 'other'];

  @override
  void initState() {
    super.initState();
    loadMoreImages();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.maxScrollExtent - _scrollController.position.pixels <= 400.0) {
      loadMoreImages();
    }
  }

  Future<void> loadMoreImages() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      // Combine and shuffle images from all types
      List<String> allImages = types.expand((type) => context.read<ThemeController>().themes[type]?.cast<String>() ?? <String>[]).toList();

      // Shuffle the list only if loading the first batch
      if (startIndex == 0) {
        allImages.shuffle();
      }

      int endIndex = startIndex + batchSize;
      if (endIndex > allImages.length) {
        endIndex = allImages.length; // Ensure we don't exceed the total size
      }

      if (startIndex < endIndex) {
        setState(() {
          images.addAll(allImages.getRange(startIndex, endIndex).toList());
          startIndex = endIndex; // Update startIndex for the next load
        });
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: MainButton(
        backgroundColor: kPrimary,
        onPressed: () {
          // get random type

          final List<String> types = ['color', 'dark', 'floral', 'luxe', 'other'];
          final String randomType = types[Random().nextInt(types.length)];

          // get random theme from this type
          final List<String> allThemes = context.read<ThemeController>().themes[randomType]!;
          final String randomTheme = allThemes[Random().nextInt(allThemes.length)];

          Navigator.push(context, MaterialPageRoute(builder: (context) => ThemeDetails(type: randomType, themeUrl: randomTheme, isOnBoarding: true)));
        },
        child: const Center(
          child: Row(mainAxisSize: MainAxisSize.min, children: [CustomAssetSvgPicture('assets/icons/sparkle.svg', width: 16, height: 16, color: kWhite), SizedBox(width: 16), Text('Choisir un thème aléatoire', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w400))]),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                // Heading
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title
                    RichText(text: const TextSpan(text: 'Choisissez un ', style: TextStyle(fontSize: 22, color: kBlack, fontWeight: FontWeight.w600), children: <TextSpan>[TextSpan(text: 'thème', style: TextStyle(fontSize: 22, color: kBlack, fontWeight: FontWeight.w800))])),

                    TextButton(
                      onPressed: (() {
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const OnboardingComplete()), (Route<dynamic> route) => route.isFirst);
                      }),
                      child: const Text('Passer', style: TextStyle(color: kPrimary, fontSize: 14, fontWeight: FontWeight.w400)),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Bottom
                const Text("Vous pouvez changer le thème et customiser votre design à tout moment sur l’application.", style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w400)),

                const SizedBox(height: 16),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 174 / 266),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ThemeDetails(type: types.firstWhere((type) => context.read<ThemeController>().themes[type]?.contains(images[index]) ?? false), themeUrl: images[index], isOnBoarding: true)));
                      },
                      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: CachedNetworkImage(imageUrl: images[index], placeholder: (context, url) => const Placeholder(), errorWidget: (context, url, error) => const Icon(Icons.error), fit: BoxFit.cover, alignment: Alignment.center)),
                    );
                  },
                ),
                if (isLoading) ...[const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64))],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Placeholder extends StatelessWidget {
  const Placeholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)), child: LoadingSkeleton(colors: const [Color.fromARGB(12, 0, 0, 0), Color.fromARGB(34, 0, 0, 0), Color.fromARGB(6, 0, 0, 0)], height: 266, width: 174));
  }
}
