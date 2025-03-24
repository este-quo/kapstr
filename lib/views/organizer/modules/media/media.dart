import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:vimeo_player_flutter/vimeo_player_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:kapstr/controllers/modules/media.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/media.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

enum MediaSource { imageGallery, videoGallery, camera, fileSystem, link }

class Media extends StatefulWidget {
  const Media({super.key, required this.moduleId});

  final String moduleId;

  @override
  State<Media> createState() => _MediaState();
}

class _MediaState extends State<Media> {
  MediaModule? _mediaModule;
  bool _isLoading = false;
  bool _isVideoFullscreen = false;
  double _videoWidth = 0;
  double _videoHeight = 200;
  YoutubePlayerController _youtubePlayerController = YoutubePlayerController(initialVideoId: "");

  late TextEditingController _linkController;

  @override
  void initState() {
    super.initState();
    _fetchMediaModule().then((_) {
      if (_mediaModule != null) {
        updateVideoId(_mediaModule!.videoId); // Assurez-vous que cette méthode est bien définie
      }
    });

    _linkController = TextEditingController();
  }

  void updateVideoId(String videoId) {
    // Vérifie si l'ID de vidéo est non vide et met à jour le YoutubePlayerController
    if (videoId.isNotEmpty) {
      setState(() {
        _youtubePlayerController = YoutubePlayerController(initialVideoId: videoId, flags: const YoutubePlayerFlags(autoPlay: false, mute: false));
      });

      _youtubePlayerController.addListener(() {
        final isFullscreen = _youtubePlayerController.value.isFullScreen;
        if (isFullscreen) {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
          SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
        } else {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
        }
        setState(() {
          _isVideoFullscreen = isFullscreen;
          _videoWidth = MediaQuery.of(context).size.width;
          _videoHeight = MediaQuery.of(context).size.height;
        });
      });
    }
  }

  @override
  void dispose() {
    _linkController.dispose();
    _youtubePlayerController.dispose();
    super.dispose();
  }

  Future<void> _fetchMediaModule() async {
    try {
      _mediaModule = await context.read<MediaController>().getMediaById(widget.moduleId);
      if (_mediaModule != null && _mediaModule!.mediaType == "youtube" && _mediaModule!.videoId.isNotEmpty) {
        // Extrait l'ID de la vidéo depuis l'URL et met à jour le player
        String videoId = _mediaModule!.videoId;
        updateVideoId(videoId);
      }
      setState(() {});
    } catch (e) {
      printOnDebug("Error fetching media module: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      floatingActionButton:
          !_isVideoFullscreen
              ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _mediaModule != null && _mediaModule!.url.isNotEmpty
                      ? MainButton(
                        onPressed: () async {
                          triggerShortVibration();

                          Navigator.of(context).pop();
                        },
                        backgroundColor: kPrimary,
                        child: const Text('Sauvegarder le média', style: TextStyle(fontSize: 14, color: kWhite, fontWeight: FontWeight.w500)),
                      )
                      : const SizedBox(),
                  const SizedBox(height: 8),

                  MainButton(onPressed: _uploadFile, child: Text(_mediaModule != null && _mediaModule!.url.isNotEmpty ? 'Modifier le média' : 'Ajouter un média', style: const TextStyle(fontSize: 14, color: kWhite, fontWeight: FontWeight.w500))),

                  // Add a button to delete the media
                  _mediaModule != null && _mediaModule!.url.isNotEmpty
                      ? TextButton(
                        onPressed: () async {
                          // Show confirmation dialog before proceeding with deletion
                          final shouldDelete =
                              await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      backgroundColor: kWhite,
                                      surfaceTintColor: kWhite,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      title: const Text('Confirmer la suppression', style: TextStyle(color: kBlack, fontSize: 18, fontWeight: FontWeight.w700)),
                                      content: const Text('Êtes-vous sûr de vouloir supprimer ce média ?'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Annuler', style: TextStyle(color: kBlack, fontSize: 16)),
                                          onPressed: () => Navigator.of(context).pop(false), // Dismiss dialog and return false
                                        ),
                                        TextButton(
                                          child: const Text('Supprimer', style: TextStyle(color: kDanger, fontSize: 16)),
                                          onPressed: () => Navigator.of(context).pop(true), // Dismiss dialog and return true
                                        ),
                                      ],
                                    ),
                              ) ??
                              false;

                          if (shouldDelete) {
                            triggerShortVibration();
                            _mediaModule?.url = "";
                            _mediaModule?.mediaType = "";
                            _mediaModule?.videoId = "";
                            await context.read<MediaController>().updateMediaModule(_mediaModule!);
                            setState(() {});
                          }
                        },
                        child: const Text('Supprimer le média', style: TextStyle(fontSize: 14, color: kDanger, fontWeight: FontWeight.w500)),
                      )
                      : const SizedBox(),
                ],
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar:
          !_isVideoFullscreen
              ? AppBar(
                backgroundColor: kWhite,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                leadingWidth: 75,
                toolbarHeight: 40,
                centerTitle: true,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
                      Navigator.of(context).pop();
                    },
                    child: const Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: kBlack), Text('Retour', style: TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w500))]),
                  ),
                ),
                actions: const [SizedBox(width: 91)],
              )
              : null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: !_isVideoFullscreen ? const EdgeInsets.symmetric(horizontal: 20) : const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                !_isVideoFullscreen
                    ? const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Média', textAlign: TextAlign.left, style: TextStyle(fontSize: 24, color: kBlack, fontWeight: FontWeight.w600)),
                        SizedBox(height: 8),
                        // Subtitle
                        Text('Ajoutez un média que vous souhaitez partager avec les participants comme une image ou un PDF.', textAlign: TextAlign.left, style: TextStyle(fontSize: 14, color: kBlack, fontWeight: FontWeight.w400)),
                        SizedBox(height: 12),
                      ],
                    )
                    : const SizedBox(),
                _isLoading
                    ? const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64))
                    : _mediaModule != null && _mediaModule!.url.isNotEmpty
                    ? _buildFilePreview(_mediaModule!.url)
                    : const SizedBox(),
                const SizedBox(height: 96),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _uploadFile() async {
    printOnDebug("Uploading file");
    final MediaSource? source = await _showUploadOptions();

    if (source == null) {
      // User dismissed the dialog, just return without doing anything
      return;
    }

    late FilePickerResult? result;

    String mediaType = "";
    String videoId = "";

    switch (source) {
      case MediaSource.imageGallery:
        final ImagePicker picker = ImagePicker();
        final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery, preferredCameraDevice: CameraDevice.rear);
        if (pickedFile != null) {
          if (!['png', 'jpg', 'jpeg'].contains(pickedFile.path.split('.').last.toLowerCase())) {
            // Show alert if file type is not supported
            showFileTypeNotSupportedAlert();
            return;
          }
          File file = File(pickedFile.path);
          String fileName = pickedFile.path.split('/').last;
          result = FilePickerResult([PlatformFile(path: pickedFile.path, name: fileName, size: await file.length())]);
          mediaType = "image";
        }
        break;
      case MediaSource.videoGallery:
        final ImagePicker picker = ImagePicker();
        final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery, preferredCameraDevice: CameraDevice.rear);
        if (pickedFile != null) {
          File file = File(pickedFile.path);
          String fileName = pickedFile.path.split('/').last;
          result = FilePickerResult([PlatformFile(path: pickedFile.path, name: fileName, size: await file.length())]);
          mediaType = "video";
        }
        break;
      case MediaSource.camera:
        final ImagePicker picker = ImagePicker();
        final XFile? photo = await picker.pickImage(source: ImageSource.camera);
        if (photo != null) {
          File file = File(photo.path);
          String fileName = photo.path.split('/').last;
          result = FilePickerResult([PlatformFile(path: photo.path, name: fileName, size: await file.length())]);
          mediaType = "image";
        }
        break;
      case MediaSource.fileSystem:
        try {
          result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'png']);
        } catch (e) {
          printOnDebug("Error picking file: $e");
        }
        mediaType = "file";

        break;

      case MediaSource.link:
        if (_linkController.text.isNotEmpty) {
          String url = _linkController.text.trim();
          Uri uri = Uri.parse(url);
          if (uri.host.contains('youtube.com') || uri.host.contains('youtu.be')) {
            mediaType = "youtube";
            if (uri.host.contains('youtu.be')) {
              videoId = uri.pathSegments.first;
            } else {
              videoId = uri.queryParameters['v'] ?? '';
            }
          } else if (uri.host.contains('vimeo.com')) {
            mediaType = "vimeo";
            videoId = uri.pathSegments.last;
          }

          if (mediaType == "youtube" || mediaType == "vimeo") {
            setState(() => _isLoading = true);
            _mediaModule?.url = url;
            _mediaModule?.mediaType = mediaType;
            _mediaModule?.videoId = videoId;

            try {
              await context.read<MediaController>().updateMediaModule(_mediaModule!);
              printOnDebug("Link updated successfully.");
            } catch (e) {
              printOnDebug("Error updating media module with link: $e");
            } finally {
              setState(() => _isLoading = false);
            }
            return;
          }
        }
        break;
    }

    if (result != null && result.files.single.path != null) {
      setState(() => _isLoading = true);
      File file = File(result.files.single.path!);
      printOnDebug("Picked file size: ${await file.length()} bytes");

      // Check if the file is not empty
      if (file.lengthSync() == 0) {
        printOnDebug("File is empty");
        setState(() => _isLoading = false);
        return;
      }

      String fileName = result.files.single.name;
      String filePath = 'events/${Event.instance.id}/medias/$fileName';

      try {
        // Upload the file
        await FirebaseStorage.instance.ref(filePath).putFile(file, SettableMetadata(contentType: 'application/pdf'));

        String fileUrl = await FirebaseStorage.instance.ref(filePath).getDownloadURL();
        _mediaModule?.url = fileUrl;
        _mediaModule?.mediaType = mediaType;
        _mediaModule?.videoId = videoId;

        updateVideoId(_mediaModule!.videoId);

        await context.read<MediaController>().updateMediaModule(_mediaModule!);
      } catch (e) {
        printOnDebug("Error uploading file: $e");
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void showFileTypeNotSupportedAlert() {
    showDialog(
      context: context,
      builder:
          (context) =>
              AlertDialog(surfaceTintColor: kWhite, backgroundColor: kWhite, title: Text('Type de fichier non supporté'), content: Text('Veuillez choisir un fichier de type PNG, JPG, JPEG, MP4, MOV ou AVI.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))]),
    );
  }

  Widget _buildFilePreview(String fileUrl) {
    bool isYouTubeLink = _mediaModule?.mediaType == "youtube";
    bool isVimeoLink = _mediaModule?.mediaType == "vimeo";

    if (isVimeoLink) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown, DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      return SizedBox(width: double.infinity, height: 200, child: VimeoPlayer(videoId: _mediaModule?.videoId ?? ''));
    }

    if (isYouTubeLink) {
      // YouTube video preview
      return Container(
        color: kBlack,
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            height: _isVideoFullscreen ? _videoHeight : 200,
            child: AspectRatio(
              aspectRatio: _isVideoFullscreen ? _videoWidth / _videoHeight : 16 / 9,
              child: YoutubePlayer(
                key: UniqueKey(),
                aspectRatio: 16 / 9,
                controller: _youtubePlayerController,
                showVideoProgressIndicator: true,
                onReady: () {
                  setState(() {});
                  printOnDebug("YouTube Player is ready.");
                },
                bottomActions: [CurrentPosition(), ProgressBar(isExpanded: true, colors: const ProgressBarColors(playedColor: kPrimary, handleColor: kPrimary, bufferedColor: kGrey)), FullScreenButton()],
              ),
            ),
          ),
        ),
      );
    }
    // Extract the file extension before any query parameters
    String fileExtension = fileUrl.split('?').first.split('.').last;

    // Check the file type
    if (fileExtension == "jpg" || fileExtension == "png") {
      // Image preview
      return GestureDetector(
        onTap: () => _showFullScreen(context, Image.network(fileUrl)),
        child: CachedNetworkImage(
          imageUrl: fileUrl,
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.65,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64)),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      );
    } else if (fileExtension == "mp4") {
      return FutureBuilder<ChewieController>(
        future: _initializeVideoPlayer(fileUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
            return AspectRatio(aspectRatio: snapshot.data!.videoPlayerController.value.aspectRatio, child: Chewie(controller: snapshot.data!));
          } else {
            return const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64));
          }
        },
      );
    } else if (fileExtension == "pdf") {
      // PDF preview
      return FutureBuilder<String>(
        future: _downloadFile(fileUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return GestureDetector(
                onTap:
                    () => _showFullScreen(
                      context,
                      PDFView(
                        filePath: snapshot.data!,
                        enableSwipe: true,
                        swipeHorizontal: false,
                        pageSnap: true,
                        fitPolicy: FitPolicy.BOTH,
                        preventLinkNavigation: false,
                        onRender: (pages) {
                          printOnDebug("Rendered $pages pages");
                        },
                        onError: (error) {
                          printOnDebug("Error rendering PDF: $error");
                        },
                        onPageError: (page, error) {
                          printOnDebug("Error on page $page: $error");
                        },
                      ),
                    ),
                child: Container(width: double.infinity, height: 200, color: Colors.grey[300], child: const Center(child: Text("Ouvrir PDF"))),
              );
            } else if (snapshot.hasError) {
              // Handle the case where the Future completes with an error
              printOnDebug("Error downloading PDF: ${snapshot.error}");
              return const Center(child: Text("Erreur lors du téléchargement du PDF"));
            }
          }
          // Loading state
          return const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64));
        },
      );
    } else {
      return const SizedBox(width: double.infinity, height: 200, child: Center(child: Text("Fichier non supporté")));
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

  void _showFullScreen(BuildContext context, Widget content) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
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
              body: InteractiveViewer(
                panEnabled: true, // Enable panning.
                minScale: 1.0, // Minimum zoom scale.
                maxScale: 4.0,
                child: Center(child: content),
              ),
            ),
      ),
    );
  }

  Future<MediaSource?> _showUploadOptions() async {
    return await showDialog<MediaSource>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: kWhite,
            surfaceTintColor: kWhite,
            elevation: 10,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            iconPadding: const EdgeInsets.all(0),
            buttonPadding: const EdgeInsets.all(0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: null,
            titlePadding: const EdgeInsets.all(0),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                InkWell(
                  onTap: () => Navigator.of(context).pop(MediaSource.camera),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Prendre une photo', style: TextStyle(color: kBlack, fontWeight: FontWeight.w500, fontSize: 14)), Icon(Icons.camera_alt_outlined, color: kBlack, size: 20)]),
                  ),
                ),
                Divider(color: kBlack.withValues(alpha: 0.1), height: 1, thickness: 1),
                InkWell(
                  onTap: () => Navigator.of(context).pop(MediaSource.imageGallery),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Voir ma galerie', style: TextStyle(color: kBlack, fontWeight: FontWeight.w500, fontSize: 14)), Icon(Icons.photo_library_outlined, color: kBlack, size: 20)]),
                  ),
                ),
                Divider(color: kBlack.withValues(alpha: 0.1), height: 1, thickness: 1),
                InkWell(
                  onTap: () => Navigator.of(context).pop(MediaSource.fileSystem),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Voir mes fichiers', style: TextStyle(color: kBlack, fontWeight: FontWeight.w500, fontSize: 14)), Icon(Icons.insert_drive_file_outlined, color: kBlack, size: 20)]),
                  ),
                ),
                // Divider(
                //   color: kBlack.withValues(alpha: 0.1),
                //   height: 1,
                //   thickness: 1,
                // ),
                // InkWell(
                //   onTap: () async {
                //     Completer<void> completer = Completer();
                //     showLinkDialog(completer);

                //     await completer.future;

                //     Navigator.of(context).pop(MediaSource.link);
                //   },
                //   child: Padding(
                //     padding: const EdgeInsets.symmetric(vertical: 16.0),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         RichText(
                //           text: const TextSpan(
                //             text: 'Ajouter un lien',
                //             style: TextStyle(color: kBlack, fontWeight: FontWeight.w500, fontSize: 14),
                //             children: [
                //               TextSpan(
                //                 text: ' (youtube, vimeo)',
                //                 style: TextStyle(color: kGrey, fontWeight: FontWeight.w400, fontSize: 14),
                //               ),
                //             ],
                //           ),
                //         ),
                //         const Icon(Icons.play_arrow_outlined, color: kBlack, size: 20),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
    );
  }

  void showLinkDialog(Completer<void> completer) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kWhite,
          surfaceTintColor: kWhite,
          elevation: 10,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          iconPadding: const EdgeInsets.all(0),
          buttonPadding: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: null,
          titlePadding: const EdgeInsets.all(0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Ajouter un lien', textAlign: TextAlign.left, style: TextStyle(fontSize: 24, color: kBlack, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('Ajoutez un lien vers une vidéo YouTube ou Vimeo.', textAlign: TextAlign.left, style: TextStyle(fontSize: 14, color: kBlack, fontWeight: FontWeight.w400)),
              const SizedBox(height: 12),
              TextField(controller: _linkController, decoration: const InputDecoration(hintText: 'https://www.youtube.com/watch?v=...', hintStyle: TextStyle(color: kGrey, fontWeight: FontWeight.w400, fontSize: 14), border: UnderlineInputBorder(borderSide: BorderSide(color: kBlack)))),
              const SizedBox(height: 12),
              MainButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  completer.complete();
                },
                child: const Text('Ajouter le lien', style: TextStyle(fontSize: 14, color: kWhite, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        );
      },
    );
  }
}
