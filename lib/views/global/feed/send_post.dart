import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/feed.dart';
import 'package:kapstr/controllers/notification.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/app_guest.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class SendPost extends StatefulWidget {
  const SendPost({super.key, required ScrollController scrollController});

  @override
  State<SendPost> createState() => _SendPostState();
}

class _SendPostState extends State<SendPost> {
  final TextEditingController _textFieldController = TextEditingController();
  bool isLoading = false;
  List<File> _images = []; // Declare the list at the class level

  @override
  void initState() {
    super.initState();
    _images = []; // Initialize the list in initState
  }

  void _pickPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
    }
  }

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
    }
  }

  Future<List<String>> _uploadImages(List<File> images) async {
    int index = 0; // Utilisé pour l'unicité du chemin
    return Future.wait(
      images.map((image) async {
        final directory = await getTemporaryDirectory();
        final targetPath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}_${index++}_compressed.jpg';

        final compressedImageFile = await FlutterImageCompress.compressAndGetFile(image.absolute.path, targetPath, quality: 70);

        if (compressedImageFile == null) {
          throw Exception("La compression de l'image a échoué");
        }

        final ref = FirebaseStorage.instance.ref('posts/${Event.instance.id}/${compressedImageFile.path.split('/').last}');

        File newCompressedImageFile = File(compressedImageFile.path);

        final taskSnapshot = await ref.putFile(newCompressedImageFile);

        return await taskSnapshot.ref.getDownloadURL();
      }),
    );
  }

  Map<String, dynamic> _createPostMap(List<String> imageUrls, String content) {
    return {'user_id': context.read<UsersController>().user!.id, 'images_url': imageUrls, 'content': content, 'posted_at': DateTime.now(), 'warns': <String>[]};
  }

  Future<void> _sendNotification(BuildContext context) async {
    if (context.read<FeedController>().isGuestView) {
      await context.read<NotificationController>().addOrganizerNotification(title: 'Feed', body: '${context.read<UsersController>().user!.name} a publié un nouveau message sur le feed.', image: AppGuest.instance.name != '' ? context.read<UsersController>().user!.imageUrl : null, type: 'feed');
    } else {
      await context.read<NotificationController>().addGuestNotification(title: 'Feed', body: 'Les mariés ont publiés un nouveau message sur le feed.', image: context.read<UsersController>().user!.name != '' ? context.read<UsersController>().user!.imageUrl : null, type: 'feed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(color: kBlack, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color.fromARGB(30, 0, 0, 0), width: 1, strokeAlign: BorderSide.strokeAlignOutside)),
            child: Center(child: IconButton(icon: const Icon(Icons.photo_camera_rounded), color: kWhite, onPressed: _pickPhoto)),
          ),
          const SizedBox(width: 8),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(color: kBlack, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color.fromARGB(30, 0, 0, 0), width: 1, strokeAlign: BorderSide.strokeAlignOutside)),
            child: Center(child: IconButton(icon: const Icon(Icons.image), color: kWhite, onPressed: _pickImage)),
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
        elevation: 0,
        leadingWidth: 75,
        toolbarHeight: 40,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(onTap: () => Navigator.of(context).pop(), child: const Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: Colors.black), Text('Retour', style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500))])),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Nouvelle publication', textAlign: TextAlign.left, style: TextStyle(fontSize: 20, color: kBlack, fontWeight: FontWeight.w600)),

                  // Send button
                  TextButton(
                    onPressed: () async {
                      triggerShortVibration();
                      // Check if it's already loading or if inputs are empty
                      if (isLoading || (_textFieldController.text.isEmpty && _images.isEmpty) || context.read<EventsController>().isGuestPreview) {
                        return;
                      }

                      setState(() => isLoading = true);

                      try {
                        // Upload images and get URLs
                        final imageUrls = await _uploadImages(_images);

                        // Create post map
                        final postMap = _createPostMap(imageUrls, _textFieldController.text);

                        // Send the post
                        await context.read<FeedController>().addPost(postMap, context);

                        // Send notification
                        await _sendNotification(context);
                      } catch (e) {
                        printOnDebug('Error posting: $e'); // Handle the error properly
                      } finally {
                        // Reset loading and navigate back regardless of success or failure
                        setState(() => isLoading = false);
                        Navigator.of(context).pop();
                      }
                    },
                    child: isLoading ? const Center(child: SizedBox(height: 14, width: 14, child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64))) : const Text('Publier', style: TextStyle(fontSize: 14, color: kPrimary, fontWeight: FontWeight.w400)),
                  ),
                ],
              ),
            ),

            // Text Input
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        autofocus: true,
                        controller: _textFieldController,
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 4,
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                        style: const TextStyle(fontSize: 16, color: kBlack, fontWeight: FontWeight.w400),
                        decoration: const InputDecoration(hintText: 'Exprimez-vous...', hintStyle: TextStyle(fontSize: 16, color: kGrey, fontWeight: FontWeight.w400)),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Images
                    SizedBox(
                      height: MediaQuery.of(context).size.width,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: _images.length == 1 || index == _images.length - 1 ? EdgeInsets.zero : const EdgeInsets.only(right: 16.0),
                            child: Image.file(_images[index], fit: BoxFit.cover, width: _images.length == 1 ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width * 0.85, height: MediaQuery.of(context).size.width),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
