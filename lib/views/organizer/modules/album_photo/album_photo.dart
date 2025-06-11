import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/controllers/modules/modules.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AlbumPhoto extends StatefulWidget {
  const AlbumPhoto({super.key, required this.moduleId, required this.isGuestView});

  final String moduleId;
  final bool isGuestView;

  @override
  State<StatefulWidget> createState() => _AlbumPhotoState();
}

class _AlbumPhotoState extends State<AlbumPhoto> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> getAlbum = context.read<ModulesController>().getAlbum(widget.moduleId, Event.instance.id);
  File? imageFile;
  int? startingIndex;
  List<dynamic> pictures = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          !widget.isGuestView
              ? GestureDetector(
                onTap: () {
                  _showImageDialog();
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: kBlack, borderRadius: BorderRadius.circular(100), border: Border.all(color: const Color.fromARGB(30, 0, 0, 0), width: 1, strokeAlign: BorderSide.strokeAlignOutside)),
                  child: const Center(child: Icon(Icons.add, color: kWhite, size: 24)),
                ),
              )
              : null,
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Album photo', textAlign: TextAlign.left, style: TextStyle(fontSize: 24, color: kBlack, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              !widget.isGuestView ? const Center(child: Text(textAlign: TextAlign.start, 'Ajoutez des photos en les important depuis votre bibliothèque.', style: TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w400))) : const SizedBox(),
              const SizedBox(height: 16),
              StreamBuilder(
                stream: getAlbum,
                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.data() != null) {
                      if (snapshot.data!.data()!['pictures'] == null) {
                        return const Center(child: Text('Il n\'y a pas encore de photo dans votre album', style: TextStyle(color: kDanger)));
                      }
                      startingIndex = snapshot.data!.data()!['pictures'].length + 1;
                      pictures = snapshot.data!.data()!['pictures'];
                      return pictures.isEmpty
                          ? const SizedBox()
                          : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.6, mainAxisSpacing: 4.0, crossAxisSpacing: 4.0),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemCount: snapshot.data!.data()!['pictures'].length,
                            itemBuilder: (BuildContext context, int index) {
                              return Stack(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      handleImageTap(context, imageUrl: snapshot.data!.data()!['pictures'][index]);
                                    },
                                    child: CachedNetworkImage(
                                      imageUrl: snapshot.data!.data()!['pictures'][index],
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64)),
                                      errorWidget: (context, url, error) => const Icon(Icons.error),
                                      width: double.infinity,
                                      height: double.infinity * 0.6,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child:
                                        widget.isGuestView
                                            ? InkWell(
                                              onTap: () {
                                                showPhotoOptions(context, snapshot.data!.data()!['pictures'][index]);
                                              },
                                              child: const Icon(Icons.more_vert, color: Colors.white),
                                            )
                                            : GestureDetector(
                                              onTap: () async {
                                                try {
                                                  final storageRef = FirebaseStorage.instance.refFromURL(pictures[index]);
                                                  await context.read<ModulesController>().deletePictureInsideAlbumModule(pictures[index]);
                                                  await storageRef.delete();
                                                } catch (e) {
                                                  throw Exception(e);
                                                }
                                                setState(() {});
                                              },
                                              child: CircleAvatar(radius: 12, backgroundColor: kWhite.withValues(alpha: 0.8), child: const Icon(Icons.close_rounded, color: kBlack, size: 16)),
                                            ),
                                  ),
                                ],
                              );
                            },
                          );
                    } else {
                      return Container();
                    }
                  } else {
                    return Container();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showImageDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kWhite,
          surfaceTintColor: kWhite,
          elevation: 10,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          iconPadding: const EdgeInsets.all(0),
          buttonPadding: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: null,
          titlePadding: const EdgeInsets.all(8),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () async {
                  XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 1800, maxHeight: 1800);
                  if (pickedFile != null) {
                    setState(() {
                      imageFile = File(pickedFile.path);
                    });
                  } else {
                    return;
                  }
                  try {
                    final storageRef = FirebaseStorage.instance.ref().child("events/${Event.instance.id}/album_photo/$startingIndex.jpg");
                    await storageRef.putFile(imageFile!);
                    var downloadUrl = await storageRef.getDownloadURL();

                    if (!mounted) return;
                    await context.read<ModulesController>().addPicturesInsideAlbumModule(downloadUrl);

                    if (!mounted) return;
                    Navigator.pop(context);
                  } catch (e) {
                    throw Exception(e);
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Prendre une photo', style: TextStyle(color: kBlack, fontWeight: FontWeight.w500, fontSize: 14)), Icon(Icons.camera_alt_outlined, color: kBlack, size: 20)]),
                ),
              ),
              Divider(color: kBlack.withValues(alpha: 0.1), height: 1, thickness: 1),
              InkWell(
                onTap: () async {
                  XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1800, maxHeight: 1800);
                  if (pickedFile != null) {
                    setState(() {
                      imageFile = File(pickedFile.path);
                    });
                  } else {
                    return;
                  }
                  try {
                    final storageRef = FirebaseStorage.instance.ref().child("events/${Event.instance.id}/album_photo/$startingIndex.jpg");
                    await storageRef.putFile(imageFile!);
                    var downloadUrl = await storageRef.getDownloadURL();

                    if (!mounted) return;
                    await context.read<ModulesController>().addPicturesInsideAlbumModule(downloadUrl);

                    if (!mounted) return;
                    Navigator.pop(context);
                  } catch (e) {
                    throw Exception(e);
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Voir ma galerie', style: TextStyle(color: kBlack, fontWeight: FontWeight.w500, fontSize: 14)), Icon(Icons.photo_library_outlined, color: kBlack, size: 20)]),
                ),
              ),
            ],
          ),
        );
      },
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
                Navigator.pop(context);
                await downloadImage(imageUrl);
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<void> downloadImage(String url) async {
  try {} catch (e) {
    debugPrint('Erreur téléchargement : $e');
  }
}
