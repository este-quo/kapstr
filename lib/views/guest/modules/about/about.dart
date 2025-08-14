import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/modules/about.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/about.dart';
import 'package:kapstr/models/modules/about_service.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/guest/modules/about/service.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutGuest extends StatefulWidget {
  const AboutGuest({super.key, required this.moduleId});

  final String moduleId;

  @override
  State<AboutGuest> createState() => _AboutGuestState();
}

class _AboutGuestState extends State<AboutGuest> {
  late Future<AboutModule?> _aboutModuleFuture;

  @override
  void initState() {
    super.initState();
    _aboutModuleFuture = _fetchAboutModule();
  }

  Future<AboutModule?> _fetchAboutModule() async {
    try {
      return await context.read<AboutController>().getAboutById(widget.moduleId);
    } catch (e) {
      printOnDebug("Error fetching cagnotte module: $e");
      return null;
    }
  }

  String extractCity(String address) {
    // Split the address string by commas and trim whitespace from each part
    List<String> parts = address.split(',').map((part) => part.trim()).toList();

    // Check if the address has at least two parts
    if (parts.length < 2) {
      return address; // or throw an exception if you prefer
    }

    // Return the second to last part as the city
    return parts[parts.length - 2];
  }

  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri(scheme: 'mailto', path: email);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  Future<void> _initiateCall(String phoneNumber) async {
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AboutModule?>(
      future: _aboutModuleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        if (snapshot.hasData) {
          return Scaffold(
            backgroundColor: kWhite,
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
              decoration: const BoxDecoration(color: kWhite, border: Border(top: BorderSide(color: Color.fromARGB(30, 0, 0, 0), width: 1))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  snapshot.data!.phone != ""
                      ? SizedBox(
                        width: 74,
                        child: MainButton(
                          backgroundColor: kWhite,
                          child: const Icon(Icons.phone_forwarded_rounded),
                          onPressed: () {
                            _initiateCall(snapshot.data!.phone);
                          },
                        ),
                      )
                      : SizedBox(),
                  const SizedBox(width: 8),
                  snapshot.data!.email != ""
                      ? SizedBox(
                        width: MediaQuery.of(context).size.width - 74 - 40 - 8,
                        child: MainButton(
                          child: const Text('Nous contacter', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w500)),
                          onPressed: () {
                            _launchEmail(snapshot.data!.email);
                          },
                        ),
                      )
                      : SizedBox(),
                ],
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 32,
                          height: MediaQuery.of(context).size.width - 16,
                          child: OverflowBox(
                            minHeight: MediaQuery.of(context).size.width - 32,
                            minWidth: MediaQuery.of(context).size.width - 32,
                            maxHeight: MediaQuery.of(context).size.width - 32 + (snapshot.data!.logoUrl != "" ? 96 : 0),
                            maxWidth: MediaQuery.of(context).size.width - 32,
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Center(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: CachedNetworkImage(fit: BoxFit.cover, width: MediaQuery.of(context).size.width - 32, height: MediaQuery.of(context).size.width - 32, imageUrl: snapshot.data!.image))),
                                ),
                                // Bouton pour voir les photos
                                snapshot.data!.logoUrl != ""
                                    ? Positioned(left: MediaQuery.of(context).size.width / 2 - 64, bottom: 0, child: CircleAvatar(backgroundColor: kWhite, radius: 48, foregroundImage: snapshot.data!.logoUrl == "" ? null : CachedNetworkImageProvider(snapshot.data!.logoUrl, scale: 1)))
                                    : const SizedBox(),
                              ],
                            ),
                          ),
                        ),
                        snapshot.data!.logoUrl != "" ? const SizedBox(height: 32) : const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [Flexible(child: Text(snapshot.data!.title == "" ? 'Titre à définir' : snapshot.data!.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: kBlack)))],
                              ),
                              snapshot.data!.website != "" ? const SizedBox(height: 4) : const SizedBox(),
                              snapshot.data!.website != "" ? Text(snapshot.data!.website, style: const TextStyle(fontSize: 16, color: kPrimary, fontWeight: FontWeight.w400)) : const SizedBox(),
                              const SizedBox(height: 8),
                              snapshot.data!.adress != "" ? Text(snapshot.data!.adress, style: const TextStyle(fontSize: 16, color: kBlack, fontWeight: FontWeight.w400)) : const SizedBox(),

                              const SizedBox(height: 8),
                              // Place address
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(Symbols.location_on, color: kGrey, size: 24, weight: 300, grade: 0, opticalSize: 20),
                                  const SizedBox(width: 8),
                                  Flexible(child: Text(snapshot.data!.adress == 'Adresse du lieu' || snapshot.data!.adress == '' ? 'Adresse non communiquée' : extractCity(snapshot.data!.adress), style: const TextStyle(color: kGrey, fontSize: 16, fontWeight: FontWeight.w400))),
                                ],
                              ),

                              const SizedBox(height: 16),
                              // Infos
                              snapshot.data!.description != "" ? const Text('Informations', style: TextStyle(color: kBlack, fontSize: 18, fontWeight: FontWeight.w500)) : const SizedBox(),

                              Text(snapshot.data!.description == "" ? 'Description' : snapshot.data!.description, style: const TextStyle(color: kGrey, letterSpacing: 0.0, height: 1.2, fontSize: 14, fontWeight: FontWeight.w400)),
                              const SizedBox(height: 16),
                              snapshot.data!.services.isNotEmpty ? Text("Nos ${getNameOfCategory()}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: kBlack)) : const SizedBox(),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),

                        // A l'intérieur de votre méthode build, où vous avez votre FutureBuilder
                        snapshot.data!.services.isEmpty
                            ? const SizedBox()
                            : SizedBox(
                              height: 280, // Définissez une hauteur fixe pour la liste déroulante
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                padding: const EdgeInsets.only(left: 16, right: 16),
                                itemCount: snapshot.data!.services.length, // Ajoutez 1 pour la carte spéciale
                                itemBuilder: (context, index) {
                                  // Cartes pour chaque service
                                  AboutService service = snapshot.data!.services[index];
                                  return Card(
                                    clipBehavior: Clip.antiAlias,
                                    child: InkWell(
                                      onTap: () {
                                        showModalBottomSheet(
                                          useSafeArea: true,
                                          context: context,
                                          elevation: 0,
                                          isScrollControlled: true, // Pour permettre au bottom sheet de prendre toute la hauteur
                                          builder: (context) {
                                            return DraggableScrollableSheet(
                                              initialChildSize: 1,
                                              minChildSize: 1,
                                              maxChildSize: 1,
                                              expand: false,
                                              builder: (_, scrollController) {
                                                return ServiceDetailsView(initialPage: index, module: snapshot.data!, services: snapshot.data!.services, scrollController: scrollController);
                                              },
                                            );
                                          },
                                        );
                                      },
                                      child: Stack(
                                        alignment: Alignment.bottomLeft,
                                        children: [
                                          CachedNetworkImage(imageUrl: service.imageUrl, fit: BoxFit.cover, width: 175, height: 280, colorBlendMode: BlendMode.darken, color: Colors.black.withValues(alpha: 0.5)),
                                          Positioned(
                                            left: 8,
                                            bottom: 8,
                                            child: Container(
                                              width: 159, // Match the width of the image to constrain the text within it
                                              padding: const EdgeInsets.all(8.0), // Optionally add padding inside the container
                                              child: Text(
                                                service.name,
                                                textAlign: TextAlign.left, // Center align text
                                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500),
                                                softWrap: true, // Enable text wrapping
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                        const SizedBox(height: 92),
                      ],
                    ),
                    Positioned(
                      top: 10,
                      right: 36,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 16),
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: kWhite, boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 20)]),
                          child: const Icon(Icons.close_rounded, color: kBlack, size: 24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const Center(child: Text('Erreur inconnue'));
      },
    );
  }
}

String getNameOfCategory() {
  switch (Event.instance.eventType) {
    case 'soirée':
      return 'offres';
    case 'gala':
      return 'actions';
    default:
      return 'services';
  }
}
