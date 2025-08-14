import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:provider/provider.dart';

class BackgroundTheme extends StatefulWidget {
  final Widget child;

  const BackgroundTheme({super.key, required this.child});

  @override
  State<BackgroundTheme> createState() => _BackgroundThemeState();
}

class _BackgroundThemeState extends State<BackgroundTheme> {
  late double maxHeight;
  late double maxWidth;
  late String highResTheme;
  late String lowResTheme;
  late double themeOpacity;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final eventsController = context.watch<EventsController>();
    maxHeight = MediaQuery.of(context).size.height * 1.8;
    maxWidth = MediaQuery.of(context).size.width * 1.8;
    highResTheme = eventsController.event.fullResThemeUrl;
    lowResTheme = eventsController.event.lowResThemeUrl;
    themeOpacity = eventsController.event.themeOpacity / 100;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        highResTheme.isNotEmpty
            ? Positioned.fill(
              child: Opacity(
                opacity: themeOpacity,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: CachedNetworkImage(
                    cacheKey: highResTheme,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    fadeInDuration: const Duration(milliseconds: 0),
                    fadeOutDuration: const Duration(milliseconds: 0),
                    imageUrl: highResTheme,
                    placeholder: (context, url) => Image.network(lowResTheme, fit: BoxFit.cover, width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
            : Container(width: maxWidth, height: maxHeight, color: Colors.transparent),
        widget.child,
      ],
    );
  }
}
