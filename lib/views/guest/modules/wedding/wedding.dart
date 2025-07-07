import 'package:google_fonts/google_fonts.dart';
import 'package:add_2_calendar/add_2_calendar.dart' as calendar;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/authentication.dart';
import 'package:kapstr/controllers/rsvps.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/helpers/format_colors.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/app_guest.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/models/rsvp.dart';
import 'package:kapstr/views/global/login/login.dart';
import 'package:kapstr/views/guest/modules/launch_uber.dart';
import 'package:kapstr/views/guest/modules/launch_waze.dart';
import 'package:kapstr/views/guest/modules/response_test.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:kapstr/widgets/custom_svg_picture.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WeddingGuest extends StatefulWidget {
  final Module module;
  final bool isPreview;
  const WeddingGuest({super.key, required this.module, this.isPreview = false});

  @override
  State<StatefulWidget> createState() => _WeddingGuestState();
}

class _WeddingGuestState extends State<WeddingGuest> {
  RSVP? rsvp;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    _loadRSVP();
  }

  Future<void> _loadRSVP() async {
    try {
      RSVP? currentRsvp = await context.read<RSVPController>().getRsvpByIds(AppGuest.instance.id, widget.module.id);

      if (currentRsvp != null) {
        setState(() {
          rsvp = currentRsvp;
        });
      }
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  void addToCalendar() {
    // Map des messages basés sur les types d'événements
    const Map<String, String> eventMessages = {'mariage': "Mariage", 'anniversaire': "Anniversaire", 'gala': "Gala", 'entreprise': "Entreprise", 'bar mitsvah': "Bar Mitsvah", 'salon': "Salon", 'soirée': "Soirée"};

    // Récupérer le type d'événement actuel
    String eventType = Event.instance.eventType;

    // Récupérer le message correspondant ou un message par défaut
    String eventTitle = eventMessages[eventType] ?? "Evenement";

    String formatDate(DateTime date) {
      // Format the date but only get the month part
      String month = DateFormat('MMMM', 'fr_FR').format(date); // 'MMMM' will give the full month name

      // Capitalize the first letter of the month
      String capitalizedMonth = month.replaceRange(0, 1, month[0].toUpperCase());

      // Now build the full date string
      String formattedDate = '${date.day.toString().padLeft(2, '0')} $capitalizedMonth ${date.year}';

      return formattedDate;
    }

    triggerShortVibration();
    final calendar.Event event = calendar.Event(title: eventTitle, description: 'Evenement le ${formatDate(widget.module.date!)}', location: '${widget.module.placeName} ${widget.module.placeAddress}', startDate: widget.module.date!, endDate: widget.module.date!.add(const Duration(hours: 8)));

    calendar.Add2Calendar.addEvent2Cal(event);
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

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  String formatAndCapitalizeDate(DateTime date) {
    var formatter = DateFormat('EEEE d MMMM y', 'fr');
    var dateParts = formatter.format(date).split(' ');
    var capitalizedDateParts = dateParts.map((part) => capitalize(part)).toList();

    // Join the parts back together
    return capitalizedDateParts.join(' ');
  }

  void callBack(RSVP rsvp) {
    context.read<RSVPController>().updateRsvp(rsvp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          !widget.isPreview
              ? Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                decoration: const BoxDecoration(color: kWhite, border: Border(top: BorderSide(color: Color.fromARGB(30, 0, 0, 0), width: 1))),
                child:
                    rsvp != null
                        ? MainButton(
                          width: MediaQuery.of(context).size.width - 40,
                          backgroundColor: getButtonColor(rsvp!.response),
                          onPressed: () {
                            triggerShortVibration();
                            if (context.read<UsersController>().user != null) {
                              showModalBottomSheet(
                                elevation: 0,
                                backgroundColor: kWhite,
                                showDragHandle: true,
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
                                context: context,
                                builder: (context) => ResponseTest(module: widget.module, rsvp: rsvp!),
                                isScrollControlled: true,
                              ).then((value) {
                                setState(() {});
                              });
                            } else {
                              context.read<AuthenticationController>().setPendingConnection(true);
                              showModalBottomSheet(
                                elevation: 0,
                                backgroundColor: kWhite,
                                showDragHandle: true,
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
                                context: context,
                                builder: (context) => const LogIn(),
                                isScrollControlled: true,
                              ).then((value) {
                                setState(() {});
                              });
                            }
                          },
                          child: getButtonText(rsvp!),
                        )
                        : SizedBox(),
              )
              : const SizedBox(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    widget.module.image == ''
                        ? Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(width: MediaQuery.of(context).size.width, height: 300, decoration: BoxDecoration(color: fromHex(widget.module.colorFilter))),
                            Container(
                              width: double.infinity, // Match the width of the image to constrain the text within it
                              padding: const EdgeInsets.all(8.0), // Optionally add padding inside the container
                              child: Text(
                                widget.module.name,
                                textAlign: TextAlign.center, // Center align text
                                style: TextStyle(color: fromHex(widget.module.textColor), fontSize: 32, fontWeight: FontWeight.bold, fontFamily: GoogleFonts.getFont(widget.module.fontType).fontFamily),
                                softWrap: true, // Enable text wrapping
                                overflow: TextOverflow.fade, // Handle overflowing text gracefully
                              ),
                            ),
                          ],
                        )
                        : Center(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.55,
                            width: MediaQuery.of(context).size.width,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                // Background image
                                CachedNetworkImage(fit: BoxFit.cover, width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.55, imageUrl: widget.module.image),

                                // Positioned Container with gradient effect
                                Positioned(
                                  bottom: 0,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height * 0.55,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          fromHex(widget.module.colorFilter).withOpacity(0.7), // Darker at the bottom
                                          fromHex(widget.module.colorFilter).withOpacity(0.5), // Darker at the bottom
                                          fromHex(widget.module.colorFilter).withOpacity(0.2), // Darker at the bottom

                                          Colors.transparent, // Transparent at the top
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Positioned Container with buttons and text
                                Positioned(
                                  bottom: 0,
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(widget.module.name, textAlign: TextAlign.left, style: const TextStyle(color: kWhite, fontSize: 26, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              MainButton(
                                                width: MediaQuery.of(context).size.width / 2 - 24,
                                                height: 40,
                                                backgroundColor: const Color(0xFF34CCFD),
                                                onPressed: () {
                                                  launchWazeWithAddress(widget.module.placeAddress!);
                                                },
                                                child: const Text('Waze', style: TextStyle(color: kWhite, fontSize: 20, fontWeight: FontWeight.w400)),
                                              ),
                                              MainButton(
                                                width: MediaQuery.of(context).size.width / 2 - 24,
                                                height: 40,
                                                child: const Text('Uber', style: TextStyle(color: kWhite, fontSize: 20, fontWeight: FontWeight.w400)),
                                                onPressed: () {
                                                  launchUberWithAddress(widget.module.placeAddress!);
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 32.0, right: 16, left: 16, bottom: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Place address
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: const Color.fromARGB(26, 136, 136, 136), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 20)]),
                                child: const CustomAssetSvgPicture('assets/icons/calendar.svg', width: 24, height: 24),
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.module.date == null ? 'Date non communiquée' : formatAndCapitalizeDate(widget.module.date!), style: const TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text("Début - ${widget.module.date == null ? 'Heure non communiquée' : DateFormat('HH:mm').format(widget.module.date!)}", style: const TextStyle(color: kGrey, fontSize: 12, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Place address
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: const Color.fromARGB(26, 136, 136, 136), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 20)]),
                                child: const CustomAssetSvgPicture('assets/icons/location.svg', width: 26, height: 26),
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.module.placeName == 'Nom du lieu' || widget.module.placeName == '' ? 'Lieu non communiqué' : widget.module.placeName!, style: const TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.module.placeAddress == 'Adresse du lieu' || widget.module.placeAddress == '' || widget.module.placeAddress == null ? 'Adresse non communiquée' : widget.module.placeAddress!,
                                      style: const TextStyle(color: kGrey, fontSize: 12, fontWeight: FontWeight.w500, decoration: TextDecoration.underline, decorationColor: kGrey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 48),
                          // Infos
                          widget.module.moreInfos != "" ? const Text('Informations sur l\'événement', style: const TextStyle(color: kBlack, fontSize: 20, fontWeight: FontWeight.w500)) : const SizedBox(),
                          const SizedBox(height: 12),
                          widget.module.moreInfos != "" ? Text(widget.module.moreInfos == "" ? 'Pas d’information pour le moment.' : widget.module.moreInfos, style: const TextStyle(color: kGrey, letterSpacing: 0.0, height: 1.2, fontSize: 16, fontWeight: FontWeight.w400)) : const SizedBox(),

                          const SizedBox(height: 48),

                          Center(
                            child: InkWell(
                              onTap: () async {
                                addToCalendar();
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [Text('Ajouter au calendrier', style: TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w400)), SizedBox(width: 8), CustomAssetSvgPicture('assets/icons/calendar-redirect.svg', width: 18, height: 18)],
                              ),
                            ),
                          ),
                          const SizedBox(height: 96),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 32,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 16),
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: kWhite, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 20)]),
                  child: const Icon(Icons.close_rounded, color: kBlack, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Text getButtonText(RSVP rsvp) {
  String response = rsvp.response;

  int personsNb = rsvp.adults.length + rsvp.children.length;

  switch (response) {
    case 'Accepté':
      return Text('Présent · ${personsNb} personnes', style: const TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w500));
    case 'Absent':
      return const Text('Absent', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w500));
    default:
      return const Text('Répondre à l\'invitation', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w500));
  }
}

Color getButtonColor(String response) {
  switch (response) {
    case 'Accepté':
      return kPresent;
    case 'Absent':
      return kDanger;
    default:
      return kBlack;
  }
}

String getNames(String eventType, String moduleName) {
  String manFirstName = Event.instance.manFirstName;
  String womanFirstName = Event.instance.womanFirstName;
  String eventName = Event.instance.eventName;

  switch (eventType.toLowerCase()) {
    case 'mariage':
      return '$manFirstName & $womanFirstName';

    case 'gala':
      return '$eventName';

    case 'soirée':
      return '$manFirstName';

    case 'anniversaire':
      return '$manFirstName';

    case 'bar mitsvah':
      return '$manFirstName';

    case 'entreprise':
      return '$eventName';

    default:
      return moduleName;
  }
}
