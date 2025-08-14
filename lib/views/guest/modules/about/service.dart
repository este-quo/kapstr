import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/about.dart';
import 'package:kapstr/models/modules/about_service.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceDetailsView extends StatelessWidget {
  final int initialPage;
  final AboutModule module;
  final List<AboutService> services;
  final ScrollController scrollController;

  const ServiceDetailsView({super.key, required this.initialPage, required this.module, required this.services, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    Future<void> initiateCall(String phoneNumber) async {
      // Construct the phone call URL with the phone number
      final url = 'tel:$phoneNumber';

      final Uri uri = Uri.parse(url);

      // Check if the URL can be launched
      if (await canLaunchUrl(uri)) {
        // Launch the URL
        await launchUrl(uri);
      } else {
        // Handle the case where the URL cannot be launched
        throw 'Could not launch $url';
      }
    }

    Future<void> launchEmail(String email) async {
      final Uri uri = Uri(scheme: 'mailto', path: email);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $uri';
      }
    }

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 74,
            child: MainButton(
              backgroundColor: kWhite,
              child: const Icon(Icons.phone_forwarded_rounded),
              onPressed: () {
                initiateCall(module.phone);
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: MediaQuery.of(context).size.width - 74 - 40 - 8,
            child: MainButton(
              child: const Text('Nous contacter', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w500)),
              onPressed: () {
                launchEmail(module.email);
              },
            ),
          ),
        ],
      ),
      extendBody: true,
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 75,
        toolbarHeight: 40,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(onTap: () => Navigator.of(context).pop(), child: const Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: kBlack), Text('Retour', style: TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w500))])),
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: PageView.builder(
          controller: PageController(initialPage: initialPage),
          itemCount: services.length,
          itemBuilder: (context, index) {
            AboutService service = services[index];
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 282,
                    child: OverflowBox(
                      alignment: Alignment.topCenter,
                      minHeight: 282,
                      minWidth: MediaQuery.of(context).size.width,
                      maxHeight: 282,
                      maxWidth: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: [
                          // Image
                          CachedNetworkImage(imageUrl: service.imageUrl, width: MediaQuery.of(context).size.width, height: 250, fit: BoxFit.cover),
                          // Texte centré sur l'image
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                service.name,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: kWhite),
                                textAlign: TextAlign.center, // Optionnel : pour centrer le texte horizontalement
                              ),
                            ),
                          ),

                          Positioned(
                            left: 16,
                            bottom: 0,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: Container(
                                decoration: BoxDecoration(boxShadow: [BoxShadow(color: kBlack.withValues(alpha: 0.5), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))]),
                                child: CircleAvatar(backgroundColor: kWhite, radius: 32, backgroundImage: module.logoUrl == "" ? CachedNetworkImageProvider(Event.instance.saveTheDateThumbnail, scale: 1) : CachedNetworkImageProvider(module.logoUrl, scale: 1)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(service.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: kBlack)),
                        const SizedBox(height: 12),
                        Text(service.description, style: const TextStyle(fontSize: 14, color: kBlack, fontWeight: FontWeight.w300)),
                        const SizedBox(height: 16),
                        if (service.imageUrls.isNotEmpty) Text("En image", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: kBlack)),
                        if (service.imageUrls.isNotEmpty) const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  if (service.imageUrls.isNotEmpty)
                    SizedBox(
                      height: 150,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        itemCount: service.imageUrls.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                handleImageTap(context, imageUrl: service.imageUrls[index]);
                              },
                              child: ClipRRect(borderRadius: BorderRadius.circular(8), child: CachedNetworkImage(imageUrl: service.imageUrls[index], width: 150, height: 150, fit: BoxFit.cover)),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 92),
                ],
              ),
            );
          },
        ),
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
