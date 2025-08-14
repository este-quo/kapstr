import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kapstr/controllers/themes.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/views/organizer/theme/details.dart';
import 'package:provider/provider.dart';
import 'package:loading_skeleton_niu/loading_skeleton.dart';

class BrowseThemesFromType extends StatefulWidget {
  const BrowseThemesFromType({super.key, required this.name, required this.type, required this.isOnBoarding, this.callBack});

  final String name;
  final String type;
  final bool isOnBoarding;
  final Function? callBack;

  @override
  _BrowseThemesFromTypeState createState() => _BrowseThemesFromTypeState();
}

class _BrowseThemesFromTypeState extends State<BrowseThemesFromType> {
  final ScrollController _scrollController = ScrollController();
  List<String> images = [];
  int startIndex = 0;
  bool isLoading = false;
  final int batchSize = 6;
  final double scrollThreshold = 400.0;
  List<String> allImages = [];

  @override
  void initState() {
    super.initState();
    if (widget.type != 'custom') {
      // Récupération des images depuis ThemeController
      allImages = context.read<ThemeController>().themes[widget.type] ?? [];

      allImages.shuffle();

      loadMoreImages();

      _scrollController.addListener(_scrollListener);
    } else {
      images = Event.instance.customThemeUrls;
    }
  }

  void _scrollListener() {
    if (_scrollController.position.maxScrollExtent - _scrollController.position.pixels <= scrollThreshold) {
      loadMoreImages();
    }
  }

  Future<void> loadMoreImages() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      int endIndex = startIndex + batchSize;
      if (endIndex > allImages.length) {
        endIndex = allImages.length; // S'assurer de ne pas dépasser la taille totale
      }

      if (startIndex < endIndex) {
        setState(() {
          images.addAll(allImages.getRange(startIndex, endIndex).toList());
          startIndex = endIndex; // Mettre à jour startIndex pour la prochaine charge
        });
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == 'custom') {
      images = Event.instance.customThemeUrls;
    }
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.only(right: 16, left: 16.0, bottom: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLoading)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 174 / 266),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return SizedBox(width: 174, height: 266, child: ClipRRect(borderRadius: BorderRadius.circular(8), child: const Placeholder()));
                    },
                  ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 174 / 266),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ThemeDetails(type: widget.type, themeUrl: images[index], isOnBoarding: widget.isOnBoarding))).then((value) {
                          if (widget.callBack != null) {
                            widget.callBack!();
                          }
                        });
                      },
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            clipBehavior: Clip.hardEdge,
                            child: CachedNetworkImage(placeholder: (context, url) => const Placeholder(), errorWidget: (context, url, error) => const Icon(Icons.error), imageUrl: images[index], fit: BoxFit.cover, alignment: Alignment.center, width: 174, height: 266),
                          ),

                          // // Theme number in the middle
                          // Positioned(
                          //   top: 0,
                          //   right: 0,
                          //   child: Container(
                          //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          //     decoration: BoxDecoration(
                          //       color: kBlack.withValues(alpha: 0.6),
                          //       borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8)),
                          //     ),
                          //     child: Text(
                          //       context.read<EventsController>().getFileNameWithExtension(images[index]),
                          //       style: const TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w600),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
}

class Placeholder extends StatelessWidget {
  const Placeholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)), child: LoadingSkeleton(colors: const [Color.fromARGB(12, 0, 0, 0), Color.fromARGB(34, 0, 0, 0), Color.fromARGB(6, 0, 0, 0)], height: 266, width: 174));
  }
}
