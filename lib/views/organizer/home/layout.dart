// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kapstr/controllers/notification.dart';
import 'package:kapstr/controllers/themes.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/helpers/capitalize.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/models/app_organizer.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/models/notification.dart';
import 'package:kapstr/views/global/notifications/notifications.dart';
import 'package:kapstr/views/organizer/account/udpate_event.dart';
import 'package:kapstr/widgets/layout/feed_disposition/circle_disposition.dart';
import 'package:kapstr/widgets/layout/feed_disposition/column_disposition.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:provider/provider.dart';

import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/views/organizer/theme/browse_all.dart';
import 'package:kapstr/widgets/custom_svg_picture.dart';
import 'package:kapstr/widgets/layout/feed_disposition/slider_disposition.dart';
import 'package:kapstr/widgets/layout/feed_disposition/grid_disposition.dart';
import 'package:kapstr/widgets/layout/feed_disposition/linear_disposition.dart';
import 'package:kapstr/widgets/layout/spacing.dart';
import 'package:kapstr/widgets/popup_menu_button.dart';
import 'package:kapstr/helpers/users_letters.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/organizer/modules/paid_modules.dart';

class OrgaHomePage extends StatefulWidget {
  const OrgaHomePage({super.key});

  @override
  OrgaHomePageState createState() => OrgaHomePageState();
}

class OrgaHomePageState extends State<OrgaHomePage> {
  File? imageFile;
  DispositionType _currentDisposition = DispositionType.grid;
  double buttonScale = 1.0;

  void _updateScale(double scale) {
    setState(() {
      buttonScale = scale;
    });
  }

  void onButtonPressed() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _currentDisposition = _dispositionFromString(Event.instance.blocDisposition);
  }

  void callback() {
    setState(() {});
  }

  DispositionType _dispositionFromString(String disposition) {
    switch (disposition) {
      case 'grid':
        return DispositionType.grid;
      case 'linear':
        return DispositionType.linear;
      case 'slider':
        return DispositionType.slider;
      case 'column':
        return DispositionType.column;
      case 'circle':
        return DispositionType.circle;
      case 'card':
        return DispositionType.card;
      default:
        return DispositionType.grid;
    }
  }

  String _iconPath(DispositionType disposition) {
    switch (disposition) {
      case DispositionType.grid:
        return 'assets/icons/grid.svg';
      case DispositionType.linear:
        return 'assets/icons/linear.svg';
      case DispositionType.slider:
        return 'assets/icons/slider.svg';
      case DispositionType.column:
        return 'assets/icons/column.svg';
      case DispositionType.circle:
        return 'assets/icons/circle.svg';
      case DispositionType.card:
        return 'assets/icons/card.svg';
      default:
        return 'assets/icons/grid.svg';
    }
  }

  void _updateDisposition(DispositionType type) async {
    setState(() {
      _currentDisposition = type;
    });
    Event.instance.blocDisposition = type.toString().split('.').last;
    context.read<EventsController>().updateEvent(Event.instance);

    if (!mounted) return;
    await context.read<EventsController>().updateEventField(key: 'bloc_disposition', value: type.toString().split('.').last);
  }

  @override
  Widget build(BuildContext context) {
    String getFirstName(String fullName) {
      int spaceIndex = fullName.indexOf(' ');
      if (spaceIndex != -1) {
        return capitalize(fullName.substring(0, spaceIndex));
      } else {
        return capitalize(fullName);
      }
    }

    bool isUserSeenAllNotifications() {
      String userId = AppOrganizer.instance.id;

      List<MyNotification> notifications = context.read<NotificationController>().organizerNotifications;

      for (MyNotification notification in notifications) {
        if (!notification.seenBy.contains(userId)) {
          return false;
        }
      }

      return true;
    }

    return Stack(
      children: [
        Scaffold(
          floatingActionButton: _buildFloatingActionButton(context),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          appBar: AppBar(
            backgroundColor: context.read<EventsController>().event.fullResThemeUrl == "" ? kWhite : Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 75,
            toolbarHeight: 48,
            centerTitle: true,
            title:
                Event.instance.eventType == 'mariage'
                    ? GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateEventPage())).then((value) {
                          setState(() {});
                        });
                      },
                      child: UserLetters(),
                    )
                    : Event.instance.eventType == 'entreprise' ||
                        Event.instance.eventType == 'gala' ||
                        Event.instance.eventType == 'salon' ||
                        Event.instance.eventType == 'autre' ||
                        Event.instance.eventType == 'soirée' ||
                        Event.instance.eventType == 'anniversaire' ||
                        Event.instance.eventType == 'bar mitsvah'
                    ? GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateEventPage())).then((value) {
                          setState(() {});
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 10),
                          Center(
                            child:
                                Event.instance.logoUrl.isEmpty
                                    ? Text(Event.instance.eventName != "" ? Event.instance.eventName : Event.instance.manFirstName, style: TextStyle(color: context.read<ThemeController>().getTextColor(), fontSize: 16, fontWeight: FontWeight.w500))
                                    : CachedNetworkImage(
                                      imageUrl: Event.instance.logoUrl,
                                      fit: BoxFit.fitWidth,
                                      imageBuilder: (context, imageProvider) => CircleAvatar(radius: 24, backgroundColor: kLightGrey, backgroundImage: imageProvider),
                                      errorWidget: (context, url, error) => const Icon(Icons.error, color: kWhite),
                                      progressIndicatorBuilder: (context, url, downloadProgress) => Center(child: CircleAvatar(radius: 24, backgroundColor: kLightGrey, child: PulsatingLogo(svgPath: 'assets/icons/app/svg_dark.svg', size: 24))),
                                    ),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    )
                    : const SizedBox(),
            leading: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      triggerShortVibration();
                      Navigator.of(context).pop();
                    },
                    child: CustomAssetSvgPicture('assets/icons/burger.svg', width: 24, color: context.read<ThemeController>().getTextColor()),
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0, left: 32),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      splashRadius: 1,
                      icon: Icon(Icons.notifications_rounded, color: context.read<ThemeController>().getTextColor(), size: 24),
                      onPressed: () {
                        triggerShortVibration();

                        Navigator.push(context, MaterialPageRoute(builder: (context) => const Notifications()));
                      },
                    ),

                    // Red dot
                    context.watch<NotificationController>().organizerNotifications.isEmpty || isUserSeenAllNotifications() ? const SizedBox() : Positioned(right: 14, top: 14, child: Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
                  ],
                ),
              ),
            ],
          ),
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: !context.read<EventsController>().isGuestPreview ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: !context.read<EventsController>().isGuestPreview ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),
                        // Title
                        Row(
                          mainAxisAlignment: !context.read<EventsController>().isGuestPreview ? MainAxisAlignment.start : MainAxisAlignment.center,
                          children: [
                            !context.read<EventsController>().isGuestPreview
                                ? Flexible(
                                  child: Text(
                                    'Bienvenue ${getFirstName(context.watch<UsersController>().user!.name)}',
                                    textAlign: !context.read<EventsController>().isGuestPreview ? TextAlign.left : TextAlign.center,
                                    style: TextStyle(fontSize: 24, color: context.read<ThemeController>().getTextColor(), fontWeight: FontWeight.w600),
                                  ),
                                )
                                : Flexible(child: getEventWelcomeMessage(Event.instance.eventType)),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Subtitle
                        !context.read<EventsController>().isGuestPreview
                            ? Text(
                              'Personnalisez votre application selon vos envies et compléter votre événement pour le rendre inoubliable.',
                              textAlign: !context.read<EventsController>().isGuestPreview ? TextAlign.left : TextAlign.center,
                              style: TextStyle(fontSize: 14, color: context.read<ThemeController>().getTextColor(), fontWeight: FontWeight.w400),
                            )
                            : RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(fontSize: 14, color: context.read<ThemeController>().getTextColor(), fontWeight: FontWeight.w400),
                                children: [
                                  TextSpan(text: 'Répondez à l’invitation, postez des photos sur le '),
                                  TextSpan(text: 'Feed', style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                                  TextSpan(text: ' et accédez facilement aux '),
                                  TextSpan(text: 'RSVP', style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                                  TextSpan(text: ' !'),
                                ],
                              ),
                            ),

                        // Icons buttons
                        const SizedBox(height: 28),
                        !context.read<EventsController>().isGuestPreview ? Text("Mes modules", style: TextStyle(fontSize: 20, color: context.read<ThemeController>().getTextColor(), fontWeight: FontWeight.w600)) : const SizedBox(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  _buildDisposition(),
                  largeSpacerH(),
                  kNavBarSpacer(context),
                ],
              ),
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child:
              context.watch<ThemeController>().isTransitioning
                  ? Container(
                    key: ValueKey('transitioning'),
                    color: Colors.white,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64),
                          const SizedBox(height: 16),
                          Text(context.read<EventsController>().isGuestPreview ? 'Chargement du mode invité' : 'Chargement du mode organisateur', textAlign: TextAlign.center, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  )
                  : Container(key: ValueKey('main')),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Container(
      margin: Platform.isIOS ? const EdgeInsets.only(bottom: 50) : const EdgeInsets.only(bottom: 64),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(999), border: Border.all(color: kBlack.withOpacity(0.1), width: 1, strokeAlign: BorderSide.strokeAlignOutside)),
              child: Row(
                mainAxisSize: context.read<EventsController>().isGuestPreview ? MainAxisSize.min : MainAxisSize.max,
                children: [
                  !context.read<EventsController>().isGuestPreview
                      ? Expanded(
                        child: GestureDetector(
                          onTap: () {
                            triggerShortVibration();

                            _navigateToPaidModules(context);

                            if (context.read<EventsController>().isGuestPreview) {
                              context.read<EventsController>().changeGuestPreview();

                              printOnDebug('Guest preview is now ${context.read<EventsController>().isGuestPreview}');
                            }
                          },
                          child: Container(
                            height: 40,
                            width: double.infinity,
                            decoration: BoxDecoration(color: kBlack, borderRadius: BorderRadius.circular(999), border: Border.all(color: kBlack.withOpacity(0.1), width: 1, strokeAlign: BorderSide.strokeAlignOutside)),
                            child: Center(child: Text("Ajouter un module", style: TextStyle(color: kWhite, fontSize: 14, fontWeight: FontWeight.w500))),
                          ),
                        ),
                      )
                      : const SizedBox(),
                  !context.read<EventsController>().isGuestPreview ? const SizedBox(width: 6) : const SizedBox(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        context.read<ThemeController>().setTransitioning(true);
                      });
                      triggerShortVibration();

                      Future.delayed(const Duration(milliseconds: 0), () {
                        context.read<EventsController>().changeGuestPreview();
                      });

                      printOnDebug('Guest preview is now ${context.read<EventsController>().isGuestPreview}');

                      // wait 1 second
                      Future.delayed(const Duration(seconds: 2), () {
                        setState(() {
                          context.read<ThemeController>().setTransitioning(false);
                        });
                      });
                    },
                    child: Container(
                      height: 40,
                      width: !context.read<EventsController>().isGuestPreview ? 40 : null,
                      padding: context.read<EventsController>().isGuestPreview ? EdgeInsets.symmetric(horizontal: 12.0) : null,
                      decoration: BoxDecoration(color: context.read<EventsController>().isGuestPreview ? kPrimary : kWhite, borderRadius: BorderRadius.circular(999), border: Border.all(color: kBlack.withOpacity(0.1), width: 1, strokeAlign: BorderSide.strokeAlignOutside)),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(context.read<EventsController>().isGuestPreview ? Icons.swap_calls : Icons.remove_red_eye, color: context.read<EventsController>().isGuestPreview ? kWhite : kBlack, size: 24),
                            context.read<EventsController>().isGuestPreview ? const SizedBox(width: 6) : const SizedBox(),
                            context.read<EventsController>().isGuestPreview ? Text('Sortir du mode invité', style: TextStyle(color: context.read<EventsController>().isGuestPreview ? kWhite : kBlack, fontSize: 14, fontWeight: FontWeight.w500)) : const SizedBox(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  !context.read<EventsController>().isGuestPreview ? const SizedBox(width: 6) : const SizedBox(),
                  !context.read<EventsController>().isGuestPreview
                      ? GestureDetector(
                        onTap: () {
                          triggerShortVibration();
                          if (context.read<EventsController>().isGuestPreview) {
                            context.read<EventsController>().changeGuestPreview();

                            printOnDebug('Guest preview is now ${context.read<EventsController>().isGuestPreview}');
                          }

                          Navigator.push(context, MaterialPageRoute(builder: (context) => const BrowseThemes())).then((value) => setState(() {}));
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(999), border: Border.all(color: kBlack.withOpacity(0.1), width: 1, strokeAlign: BorderSide.strokeAlignOutside)),
                          child: Center(child: CustomAssetSvgPicture('assets/icons/sparkle.svg', width: 16, height: 16, color: kBlack)),
                        ),
                      )
                      : const SizedBox(),
                  !context.read<EventsController>().isGuestPreview ? const SizedBox(width: 6) : const SizedBox(),
                  !context.read<EventsController>().isGuestPreview
                      ? PopupMenuButton(
                        color: Colors.white,
                        onOpened: () {
                          triggerShortVibration();
                        },
                        surfaceTintColor: Colors.white,
                        elevation: 10,
                        padding: const EdgeInsets.all(16.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        shadowColor: kBlack.withOpacity(0.2),
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(value: 'grid', child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [CustomAssetSvgPicture(_iconPath(DispositionType.grid), width: 16, height: 16, color: kBlack), Text('Grille', style: TextStyle(color: kBlack))])),
                            PopupMenuItem(
                              height: 1,
                              value: 'divider',
                              child: Container(
                                height: 1,
                                color: kBlack.withOpacity(0.1), // Couleur du Divider
                              ),
                            ),
                            PopupMenuItem(
                              value: 'linear',
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [CustomAssetSvgPicture(_iconPath(DispositionType.linear), width: 16, height: 16, color: kBlack), Text('Ligne', textAlign: TextAlign.right, style: TextStyle(color: kBlack))]),
                            ),
                            PopupMenuItem(
                              height: 1,
                              value: 'divider',
                              child: Container(
                                height: 1,
                                color: kBlack.withOpacity(0.1), // Couleur du Divider
                              ),
                            ),
                            PopupMenuItem(
                              value: 'column',
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [CustomAssetSvgPicture(_iconPath(DispositionType.column), width: 16, height: 16, color: kBlack), Text('Colonne', textAlign: TextAlign.right, style: TextStyle(color: kBlack))]),
                            ),
                            PopupMenuItem(
                              height: 1,
                              value: 'divider',
                              child: Container(
                                height: 1,
                                color: kBlack.withOpacity(0.1),
                                // Couleur du Divider
                              ),
                            ),
                            PopupMenuItem(value: 'slider', child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [CustomAssetSvgPicture(_iconPath(DispositionType.slider), width: 16, height: 16, color: kBlack), Text('Slider', style: TextStyle(color: kBlack))])),
                            PopupMenuItem(
                              height: 1,
                              value: 'divider',
                              child: Container(
                                height: 1,
                                color: kBlack.withOpacity(0.1),
                                // Couleur du Divider
                              ),
                            ),
                            PopupMenuItem(value: 'circle', child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [CustomAssetSvgPicture(_iconPath(DispositionType.circle), width: 16, height: 16, color: kBlack), Text('Cercle', style: TextStyle(color: kBlack))])),
                            // PopupMenuItem(
                            //   height: 1,
                            //   value: 'divider',
                            //   child: Container(
                            //     height: 1,
                            //     color: kBlack.withOpacity(0.1),
                            //     // Couleur du Divider
                            //   ),
                            // ),
                            // PopupMenuItem(
                            //   value: 'card',
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //     children: [
                            //       CustomAssetSvgPicture(
                            //         _iconPath(DispositionType.card),
                            //         width: 16,
                            //         height: 16,
                            //         color: kBlack,
                            //       ),
                            //       Text('Carte',
                            //           style: TextStyle(
                            //             color: kBlack,
                            //           )),
                            //     ],
                            //   ),
                            // ),
                          ];
                        },
                        onSelected: (value) {
                          triggerShortVibration();

                          if (value == 'divider') return;
                          _updateDisposition(_dispositionFromString(value));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(999), border: Border.all(color: kBlack.withOpacity(0.1), width: 1, strokeAlign: BorderSide.strokeAlignOutside)),
                          child: CustomAssetSvgPicture(_iconPath(_currentDisposition), width: 16, height: 16, color: kBlack),
                        ),
                      )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
          // MainButton(
          //     backgroundColor: context.read<ThemeController>().getButtonColor(),
          //     onPressed: () {
          //       setState(() {
          //         context.read<ThemeController>().setTransitioning(true);
          //       });
          //       triggerShortVibration();

          //       Future.delayed(const Duration(seconds: 1), () {
          //         context.read<EventsController>().changeGuestPreview();
          //       });

          //       printOnDebug('Guest preview is now ${context.read<EventsController>().isGuestPreview}');

          //       // wait 1 second
          //       Future.delayed(const Duration(seconds: 2), () {
          //         setState(() {
          //           context.read<ThemeController>().setTransitioning(false);
          //         });
          //       });
          //     },
          //     width: MediaQuery.of(context).size.width / 1.5,
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Icon(
          //           !context.read<EventsController>().isGuestPreview ? Icons.remove_red_eye_rounded : Icons.swap_calls,
          //           color: context.read<ThemeController>().getButtonTextColor(),
          //           size: 20,
          //         ),
          //         const SizedBox(width: 8),
          //         Text(!context.read<EventsController>().isGuestPreview ? 'Passer en mode invité' : 'Désactiver le mode invité',
          //             style: TextStyle(
          //               fontSize: 16,
          //               fontWeight: FontWeight.w500,
          //               color: context.read<ThemeController>().getButtonTextColor(),
          //             )),
          //       ],
          //     )),
        ],
      ),
    );
  }

  Widget getEventWelcomeMessage(String eventType) {
    String manFirstName = Event.instance.manFirstName;
    String womanFirstName = Event.instance.womanFirstName;
    String eventName = Event.instance.eventName;

    switch (eventType.toLowerCase()) {
      case 'mariage':
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'Bienvenue au mariage de ',
            style: TextStyle(fontSize: 22, color: context.read<ThemeController>().getTextColor(), fontWeight: FontWeight.w600), // Style pour le texte normal
            children: <TextSpan>[
              TextSpan(
                text: '$manFirstName & $womanFirstName',
                style: TextStyle(fontWeight: FontWeight.bold), // Style pour les noms en gras
              ),
            ],
          ),
        );

      case 'gala':
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(text: 'Bienvenue au Gala ', style: TextStyle(fontSize: 22, color: context.read<ThemeController>().getTextColor(), fontWeight: FontWeight.w600), children: <TextSpan>[TextSpan(text: eventName, style: TextStyle(fontWeight: FontWeight.bold))]),
        );

      case 'soirée':
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(text: 'Bienvenue à la soirée ', style: TextStyle(fontSize: 22, color: context.read<ThemeController>().getTextColor(), fontWeight: FontWeight.w600), children: <TextSpan>[TextSpan(text: manFirstName, style: TextStyle(fontWeight: FontWeight.bold))]),
        );

      case 'anniversaire':
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(text: 'Bienvenue à l\'anniversaire de ', style: TextStyle(fontSize: 22, color: context.read<ThemeController>().getTextColor(), fontWeight: FontWeight.w600), children: <TextSpan>[TextSpan(text: manFirstName, style: TextStyle(fontWeight: FontWeight.bold))]),
        );

      case 'bar mitsvah':
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(text: 'Bienvenue à la Bar Mitsvah de ', style: TextStyle(fontSize: 22, color: context.read<ThemeController>().getTextColor(), fontWeight: FontWeight.w600), children: <TextSpan>[TextSpan(text: manFirstName, style: TextStyle(fontWeight: FontWeight.bold))]),
        );

      case 'entreprise':
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(text: 'Bienvenue à l\'événement d\'entreprise ', style: TextStyle(fontSize: 22, color: context.read<ThemeController>().getTextColor(), fontWeight: FontWeight.w600), children: <TextSpan>[TextSpan(text: eventName, style: TextStyle(fontWeight: FontWeight.bold))]),
        );

      default:
        return Text(textAlign: TextAlign.center, 'Bienvenue à notre événement spécial', style: TextStyle(fontSize: 22, color: context.read<ThemeController>().getTextColor(), fontWeight: FontWeight.w600));
    }
  }

  Widget _buildDisposition() {
    String disposition = context.watch<EventsController>().event.blocDisposition;
    List<Module> modules = context.watch<EventsController>().event.modules;

    switch (disposition) {
      case 'linear':
        return LinearDisposition(modules: modules, callback: callback);
      case 'grid':
        return GridDisposition(modules: modules, callback: callback);
      case 'slider':
        return SliderDisposition(modules: modules, callback: callback);
      case 'column':
        return ColumnDisposition(modules: modules, callback: callback);
      case 'circle':
        return CircleDisposition(modules: modules, callback: callback);
      // case 'card':
      //   return CardDisposition(modules: modules, callback: callback);
      default:
        return GridDisposition(modules: modules, callback: callback);
    }
  }

  void _navigateToPaidModules(BuildContext context) async {
    final wasModuleAdded = await Navigator.push(context, MaterialPageRoute(builder: (context) => const PaidModules()));
    if (wasModuleAdded == true) {
      // Refresh the UI
      setState(() {});
    }
  }
}
