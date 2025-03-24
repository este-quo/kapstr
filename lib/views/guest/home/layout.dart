import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/notification.dart';
import 'package:kapstr/controllers/themes.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/models/app_guest.dart';
import 'package:kapstr/views/global/notifications/notifications.dart';
import 'package:kapstr/widgets/custom_svg_picture.dart';
import 'package:kapstr/widgets/layout/feed_disposition/module_card.dart';
import 'package:kapstr/widgets/layout/spacing.dart';
import 'package:kapstr/helpers/format_colors.dart';
import 'package:kapstr/helpers/users_letters.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/views/guest/modules/view_manager.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:provider/provider.dart';

class GuestHomePage extends StatefulWidget {
  const GuestHomePage({super.key});

  @override
  State<GuestHomePage> createState() => _GuestHomePageState();
}

class _GuestHomePageState extends State<GuestHomePage> {
  List<Module> allowedModules = [];
  // print allowedModules;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.watch<UsersController>().user != null) {
      allowedModules = Event.instance.modules.where((module) => AppGuest.instance.allowedModules.contains(module.id)).toList();
    } else {
      allowedModules = Event.instance.modules;
    }
  }

  @override
  Widget build(BuildContext context) {
    printOnDebug('allowedModules: ${allowedModules.map((module) => module.name).toList()}');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.read<EventsController>().event.fullResThemeUrl == "" ? kWhite : Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 75,
        toolbarHeight: 48,
        centerTitle: true,
        title:
            Event.instance.eventType == 'mariage'
                ? const UserLetters()
                : Event.instance.eventType == 'entreprise' ||
                    Event.instance.eventType == 'gala' ||
                    Event.instance.eventType == 'salon' ||
                    Event.instance.eventType == 'autre' ||
                    Event.instance.eventType == 'soirée' ||
                    Event.instance.eventType == 'anniversaire' ||
                    Event.instance.eventType == 'bar mitsvah'
                ? Center(
                  child:
                      Event.instance.logoUrl.isEmpty
                          ? Text(Event.instance.eventName != "" ? Event.instance.eventName : Event.instance.manFirstName, style: TextStyle(color: context.read<ThemeController>().getTextColor(), fontSize: 16, fontWeight: FontWeight.w500))
                          : CachedNetworkImage(
                            imageUrl: Event.instance.logoUrl,
                            fit: BoxFit.fitWidth,
                            imageBuilder: (context, imageProvider) => CircleAvatar(radius: 24, backgroundColor: kLightGrey, backgroundImage: imageProvider),
                            errorWidget: (context, url, error) => const Icon(Icons.error, color: kWhite),
                            progressIndicatorBuilder: (context, url, downloadProgress) => const Center(child: CircleAvatar(radius: 24, backgroundColor: kLightGrey, child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 24))),
                          ),
                )
                : const SizedBox(),
        leading: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
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
                context.watch<NotificationController>().guestNotifications.isEmpty ? const SizedBox() : Positioned(right: 14, top: 14, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
              ],
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: Event.instance.fullResThemeUrl == '' ? kWhite : Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),

                    getEventWelcomeMessage(Event.instance.eventType),

                    const SizedBox(height: 12),

                    // Subtitle
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(fontSize: 14, color: context.read<ThemeController>().getTextColor(), fontWeight: FontWeight.w400),
                        children: const [
                          TextSpan(text: 'Répondez à l’invitation, postez des photos sur le '),
                          TextSpan(text: 'Feed', style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                          TextSpan(text: ' et accédez facilement aux '),
                          TextSpan(text: 'RSVP', style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                          TextSpan(text: ' !'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.all(0),
                child:
                    (() {
                      switch (Event.instance.blocDisposition) {
                        case 'linear':
                          return linearLayout(context, allowedModules);
                        case 'grid':
                          return gridLayout(context, allowedModules);
                        case 'slider':
                          return sliderLayout(context, allowedModules);
                        case 'column':
                          return columnLayout(context, allowedModules);
                        case 'circle':
                          return circleLayout(context, allowedModules);
                        case 'card':
                          return cardLayout(context, allowedModules);

                        default:
                          return linearLayout(context, allowedModules);
                      }
                    })(),
              ),
              kNavBarSpacer(context),
            ],
          ),
        ),
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
            text: 'Bienvenue au mariage de \n',
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
          text: TextSpan(text: 'Bienvenue au Gala \n', style: TextStyle(fontSize: 22, color: context.read<ThemeController>().getTextColor(), fontWeight: FontWeight.w600), children: <TextSpan>[TextSpan(text: eventName, style: TextStyle(fontWeight: FontWeight.bold))]),
        );

      case 'soirée':
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(text: 'Bienvenue à la soirée \n', style: TextStyle(fontSize: 22, color: context.read<ThemeController>().getTextColor(), fontWeight: FontWeight.w600), children: <TextSpan>[TextSpan(text: manFirstName, style: TextStyle(fontWeight: FontWeight.bold))]),
        );

      case 'anniversaire':
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(text: 'Bienvenue à l\'anniversaire de \n', style: TextStyle(fontSize: 22, color: context.read<ThemeController>().getTextColor(), fontWeight: FontWeight.w600), children: <TextSpan>[TextSpan(text: manFirstName, style: TextStyle(fontWeight: FontWeight.bold))]),
        );

      case 'bar mitsvah':
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(text: 'Bienvenue à la Bar Mitsvah de \n', style: TextStyle(fontSize: 22, color: context.read<ThemeController>().getTextColor(), fontWeight: FontWeight.w600), children: <TextSpan>[TextSpan(text: manFirstName, style: TextStyle(fontWeight: FontWeight.bold))]),
        );

      case 'entreprise':
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(text: 'Bienvenue à l\'événement d\'entreprise \n', style: TextStyle(fontSize: 22, color: context.read<ThemeController>().getTextColor(), fontWeight: FontWeight.w600), children: <TextSpan>[TextSpan(text: eventName, style: TextStyle(fontWeight: FontWeight.bold))]),
        );

      default:
        return Text(textAlign: TextAlign.center, 'Bienvenue à notre événement spécial', style: TextStyle(fontSize: 22, color: context.read<ThemeController>().getTextColor(), fontWeight: FontWeight.w600));
    }
  }
}

Widget linearLayout(BuildContext context, List<Module> modules) {
  modules.sort((a, b) => Event.instance.modulesOrder.indexOf(a.id).compareTo(Event.instance.modulesOrder.indexOf(b.id)));

  return ListView(
    shrinkWrap: true,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    physics: const NeverScrollableScrollPhysics(),
    children: [
      for (var i = 0; i < modules.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: moduleCard(
            key: ValueKey(modules[i].id),
            fontSize: modules[i].textSize,
            textColor: fromHex(modules[i].textColor),
            typographie: modules[i].fontType,
            colorFilter: modules[i].colorFilter == '' ? Colors.transparent : fromHex(modules[i].colorFilter),
            title: modules[i].name,
            context: context,
            imageUrl: modules[i].image,
            onTap: () {
              triggerShortVibration();

              Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => buildGuestModuleView(module: modules[i])));
            },
          ),
        ),
    ],
  );
}

Widget gridLayout(BuildContext context, List<Module> modules) {
  modules.sort((a, b) => Event.instance.modulesOrder.indexOf(a.id).compareTo(Event.instance.modulesOrder.indexOf(b.id)));

  return Center(
    child: SizedBox(
      width: MediaQuery.of(context).size.width - 40,
      child: GridView.count(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children:
            modules.map((module) {
              return moduleCardGrid(
                key: ValueKey(module.id),
                textSize: module.textSize,
                textColor: fromHex(module.textColor),
                typographie: module.fontType,
                colorFilter: module.colorFilter == '' ? Colors.transparent : fromHex(module.colorFilter),
                title: module.name,
                context: context,
                imageUrl: module.image,
                onTap: () {
                  triggerShortVibration();

                  Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => buildGuestModuleView(module: module)));
                },
              );
            }).toList(),
      ),
    ),
  );
}

Widget sliderLayout(BuildContext context, List<Module> modules) {
  modules.sort((a, b) => Event.instance.modulesOrder.indexOf(a.id).compareTo(Event.instance.modulesOrder.indexOf(b.id)));

  return SizedBox(
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height * 0.5,
    child: Row(
      children: [
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: modules.length,
            itemBuilder: (context, index) {
              return Padding(
                key: ValueKey(modules[index].id),
                padding: const EdgeInsets.only(right: 8.0),
                child: moduleCardSlider(
                  textSize: modules[index].textSize,
                  textColor: fromHex(modules[index].textColor),
                  typographie: modules[index].fontType,
                  colorFilter: modules[index].colorFilter == '' ? Colors.transparent : fromHex(modules[index].colorFilter),
                  title: modules[index].name,
                  context: context,
                  imageUrl: modules[index].image,
                  onTap: () {
                    triggerShortVibration();

                    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => buildGuestModuleView(module: modules[index])));
                  },
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

Widget columnLayout(BuildContext context, List<Module> modules) {
  modules.sort((a, b) => Event.instance.modulesOrder.indexOf(a.id).compareTo(Event.instance.modulesOrder.indexOf(b.id)));

  return Center(
    child: SizedBox(
      width: MediaQuery.of(context).size.width - 40,
      child: GridView.count(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children:
            modules.map((module) {
              return moduleCardGrid(
                key: ValueKey(module.id),
                textSize: module.textSize,
                textColor: fromHex(module.textColor),
                typographie: module.fontType,
                colorFilter: module.colorFilter == '' ? Colors.transparent : fromHex(module.colorFilter),
                title: module.name,
                context: context,
                imageUrl: module.image,
                onTap: () {
                  triggerShortVibration();

                  Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => buildGuestModuleView(module: module)));
                },
              );
            }).toList(),
      ),
    ),
  );
}

Widget circleLayout(BuildContext context, List<Module> modules) {
  modules.sort((a, b) => Event.instance.modulesOrder.indexOf(a.id).compareTo(Event.instance.modulesOrder.indexOf(b.id)));

  return SizedBox(
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.width * 0.9,
    child: Row(
      children: [
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: modules.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                key: ValueKey(modules[index].id),
                child: moduleCardCircle(
                  textSize: modules[index].textSize,
                  textColor: fromHex(modules[index].textColor),
                  typographie: modules[index].fontType,
                  colorFilter: modules[index].colorFilter == '' ? Colors.transparent : fromHex(modules[index].colorFilter),
                  title: modules[index].name,
                  context: context,
                  imageUrl: modules[index].image,
                  onTap: () {
                    triggerShortVibration();
                    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => buildGuestModuleView(module: modules[index])));
                  },
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

Widget cardLayout(BuildContext context, List<Module> modules) {
  modules.sort((a, b) => Event.instance.modulesOrder.indexOf(a.id).compareTo(Event.instance.modulesOrder.indexOf(b.id)));

  return Center(
    child: SizedBox(
      width: MediaQuery.of(context).size.width - 40,
      child: GridView.count(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
        crossAxisCount: 2,
        shrinkWrap: true,
        childAspectRatio: 0.75,
        physics: const NeverScrollableScrollPhysics(),
        children:
            modules.map((module) {
              return moduleCardCard(
                key: ValueKey(module.id),
                textSize: module.textSize,
                textColor: fromHex(module.textColor),
                typographie: module.fontType,
                colorFilter: module.colorFilter == '' ? Colors.transparent : fromHex(module.colorFilter),
                title: module.name,
                context: context,
                imageUrl: module.image,
                onTap: () {
                  triggerShortVibration();

                  Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => buildGuestModuleView(module: module)));
                },
              );
            }).toList(),
      ),
    ),
  );
}

String getEventInfoMessage(String eventType) {
  switch (eventType.toLowerCase()) {
    case 'mariage':
      return "Vous trouverez toutes les informations du mariage dans les modules correspondants.";
    case 'salon':
      return "Vous trouverez toutes les informations du salon dans les modules correspondants.";
    case 'gala':
      return "Vous trouverez toutes les informations du gala dans les modules correspondants.";
    case 'anniversaire':
      return "Vous trouverez toutes les informations de l'anniversaire dans les modules correspondants.";
    case 'entreprise':
      return "Vous trouverez toutes les informations de l'événement d'entreprise dans les modules correspondants.";
    case 'soirée':
      return "Vous trouverez toutes les informations de la soirée dans les modules correspondants.";
    case 'bar mitsvah':
      return "Vous trouverez toutes les informations de la bar mitsvah dans les modules correspondants.";
    default:
      return "Vous trouverez toutes les informations de l'événement dans les modules correspondants.";
  }
}
