import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:kapstr/controllers/modules/media.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/models/modules/media.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class MediaGuest extends StatefulWidget {
  final String moduleId;

  const MediaGuest({super.key, required this.moduleId, isPreview = false});

  @override
  State<MediaGuest> createState() => _MediaGuestState();
}

class _MediaGuestState extends State<MediaGuest> {
  MediaModule? _mediaModule;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchMediaModule();
  }

  Future<void> _fetchMediaModule() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _mediaModule = await context.read<MediaController>().getMediaById(widget.moduleId);
      if (_mediaModule != null) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      printOnDebug(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ? const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64)) : _showFullScreen(context, _buildFilePreview(_mediaModule!.url));
  }

  Widget _buildFilePreview(String fileUrl) {
    String fileExtension = fileUrl.split('?').first.split('.').last;

    if (fileExtension == "jpg" || fileExtension == "png") {
      return InteractiveViewer(
        panEnabled: true, // Enable panning.
        minScale: 1.0, // Minimum zoom scale.
        maxScale: 4.0, // Maximum zoom scale.
        child: CachedNetworkImage(imageUrl: fileUrl, width: double.infinity, fit: BoxFit.contain, placeholder: (context, url) => const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64)), errorWidget: (context, url, error) => const Icon(Icons.error)),
      );
    } else if (fileExtension == "mp4") {
      return FutureBuilder<ChewieController>(
        future: _initializeVideoPlayer(fileUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
            return Chewie(controller: snapshot.data!);
          } else {
            return const PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64);
          }
        },
      );
    } else if (fileExtension == "pdf") {
      return FutureBuilder<String>(
        future: _downloadFile(fileUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            return PDFView(filePath: snapshot.data!);
          } else {
            return const PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64);
          }
        },
      );
    } else {
      return const Text('Pas de fichier pour le moment.');
    }
  }

  Future<String> _downloadFile(String url) async {
    var response = await http.get(Uri.parse(url));
    var documentDirectory = await getApplicationDocumentsDirectory();
    var file = File("${documentDirectory.path}/temp.pdf");
    file.writeAsBytesSync(response.bodyBytes);
    return file.path;
  }

  Future<ChewieController> _initializeVideoPlayer(String videoUrl) async {
    Uri uri = Uri.parse(videoUrl);

    final videoPlayerController = VideoPlayerController.networkUrl(uri);
    await videoPlayerController.initialize();

    return ChewieController(videoPlayerController: videoPlayerController, autoPlay: false, looping: false, allowFullScreen: true, allowPlaybackSpeedChanging: false, showControls: true, showOptions: false, showControlsOnInitialize: false);
  }

  Widget _showFullScreen(BuildContext context, Widget content) {
    String fileExtension = _mediaModule!.url.split('?').first.split('.').last;

    return Scaffold(
      backgroundColor: fileExtension == "jpg" || fileExtension == "png" ? kBlack : kWhite,
      appBar: AppBar(
        backgroundColor: fileExtension == "jpg" || fileExtension == "png" ? kBlack : kWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 75,
        toolbarHeight: 40,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: fileExtension == "jpg" || fileExtension == "png" ? kWhite : kBlack), Text('Retour', style: TextStyle(color: fileExtension == "jpg" || fileExtension == "png" ? kWhite : kBlack, fontSize: 14, fontWeight: FontWeight.w500))]),
          ),
        ),
        actions: const [SizedBox(width: 91)],
      ),
      body: InteractiveViewer(
        panEnabled: true, // Enable panning.
        minScale: 1.0, // Minimum zoom scale.
        maxScale: 4.0,
        child: Center(child: content),
      ),
    );
  }
}
