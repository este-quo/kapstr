import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/album_photo.dart';
import 'package:kapstr/widgets/layout/spacing.dart';
import 'package:kapstr/views/guest/modules/layout.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class AlbumPhotoGuest extends StatefulWidget {
  final String moduleId;
  final bool isPreview;
  const AlbumPhotoGuest({super.key, required this.moduleId, this.isPreview = false});

  @override
  State<StatefulWidget> createState() => _AlbumPhotoGuestState();
}

class _AlbumPhotoGuestState extends State<AlbumPhotoGuest> {
  late AlbumPhotoModule albumPhotoModule;

  @override
  void initState() {
    albumPhotoModule = Event.instance.modules.firstWhere((element) => element.id == widget.moduleId) as AlbumPhotoModule;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GuestModuleLayout(
      title: 'Album photo',
      isThemeApplied: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child:
                albumPhotoModule.photosUrl.isEmpty
                    ? const Center(child: Text('Pas encore de photo dans l\'album', style: TextStyle(color: kBlack, fontSize: 16.0, fontWeight: FontWeight.w400)))
                    : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, mainAxisSpacing: 4.0, crossAxisSpacing: 4.0),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: albumPhotoModule.photosUrl.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Stack(
                            children: [
                              InkWell(
                                onTap: () {
                                  handleImageTap(context, imageUrl: albumPhotoModule.photosUrl[index]);
                                },
                                child: CachedNetworkImage(
                                  imageUrl: albumPhotoModule.photosUrl[index],
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64)),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: InkWell(
                                  onTap: () {
                                    showPhotoOptions(context, albumPhotoModule.photosUrl[index]);
                                  },
                                  child: const Icon(Icons.more_vert, color: Colors.white),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
          ),
          kNavBarSpacer(context),
        ],
      ),
    );
  }
}

void handleImageTap(BuildContext context, {required String imageUrl}) {
  showDialog(
    context: context,
    barrierColor: kBlack,
    barrierDismissible: true,
    builder: (context) {
      var size = MediaQuery.of(context).size;
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
        insetPadding: EdgeInsets.zero,
        backgroundColor: kBlack,
        surfaceTintColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            TapRegion(
              onTapOutside: (event) {
                Navigator.of(context).pop();
              },
              child: SizedBox(
                width: size.width,
                // height: size.height,
                child: CachedNetworkImage(imageUrl: imageUrl, placeholder: (context, url) => const Placeholder(), errorWidget: (context, url, error) => const Icon(Icons.error), fit: BoxFit.contain),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

void showPhotoOptions(BuildContext context, String imageUrl) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12.0))),
    builder: (BuildContext context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Télécharger'),
              onTap: () async {
                await downloadImage(imageUrl);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Partager'),
              onTap: () async {
                try {
                  final uri = Uri.parse(imageUrl);
                  final response = await NetworkAssetBundle(uri).load(uri.path);
                  final bytes = response.buffer.asUint8List();
                  final tempDir = await getTemporaryDirectory();
                  final file = await File('${tempDir.path}/shared_image.jpg').writeAsBytes(bytes);
                  await Share.shareXFiles([XFile(file.path)], text: 'Voici une photo de l\'événement !');
                } catch (e) {
                  debugPrint('Erreur partage : $e');
                }
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<void> downloadImage(String url) async {
  try {
    var status = await Permission.storage.request();
    if (status.isGranted) {}
  } catch (e) {
    debugPrint('Erreur téléchargement : $e');
  }
}
