import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/feed.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/helpers/capitalize.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:provider/provider.dart';

class Post extends StatelessWidget {
  const Post({super.key, required this.id, required this.name, required this.imagesUrl, required this.profilePictureUrl, required this.content, required this.postedAt, required this.userId});

  final String id;
  final String name;
  final List<String> imagesUrl;
  final String profilePictureUrl;
  final String content;
  final DateTime postedAt;
  final String userId;

  @override
  Widget build(BuildContext context) {
    bool canShowMenu = false;
    if (context.watch<UsersController>().user != null) {
      canShowMenu = !context.watch<FeedController>().isGuestView || userId == context.watch<UsersController>().user!.id;
    } else {
      canShowMenu = false;
    }

    printOnDebug('Building Post $id date $postedAt');
    String getMonthName(int monthNumber) {
      const monthNames = ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"];
      return monthNames[monthNumber - 1];
    }

    String getElapsedTime(DateTime date) {
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 30) {
        // Plus d'un mois, retourner la date
        return "${date.day} ${getMonthName(date.month)}";
      } else if (difference.inDays >= 1) {
        // Entre un jour et un mois, retourner le nombre de jours
        return "${difference.inDays}j";
      } else if (difference.inHours >= 1) {
        // Entre une heure et un jour, retourner le nombre d'heures
        return "${difference.inHours}h";
      } else if (difference.inMinutes >= 1) {
        // Moins d'une heure, retourner le nombre de minutes
        return "${difference.inMinutes}m";
      } else {
        // Moins d'une minute, retourner "à l'instant"
        return "à l'instant";
      }
    }

    return Container(
      color: kWhite,
      padding: const EdgeInsets.only(top: 12),
      margin: const EdgeInsets.only(bottom: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile picture
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 42,
                  height: 42,
                  child:
                      context.watch<UsersController>().user == null || context.watch<UsersController>().user!.imageUrl == ""
                          ? const CircleAvatar(radius: 92, backgroundColor: kLightGrey, child: Icon(Icons.person, color: kWhite, size: 20))
                          : CircleAvatar(radius: 42, backgroundColor: kLightGrey, backgroundImage: CachedNetworkImageProvider(context.watch<UsersController>().user!.imageUrl)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // name
                                SizedBox(width: MediaQuery.of(context).size.width - 48 - 12 - 16 - 24 - 8 - 8, child: Text(capitalizeNames(name), overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: kBlack, fontWeight: FontWeight.w500))),

                                const SizedBox(height: 2),

                                // Date
                                Text(getElapsedTime(postedAt), overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: kGrey, fontWeight: FontWeight.w400)),
                              ],
                            ),
                          ),

                          // more
                          if (canShowMenu)
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: PopupMenuButton<String>(
                                elevation: 8,
                                surfaceTintColor: kWhite,
                                splashRadius: 1,
                                padding: const EdgeInsets.all(0.0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                shadowColor: kBlack.withOpacity(0.2),
                                onSelected: (String result) {
                                  if (result == 'delete') {
                                    context.read<FeedController>().removePost(id);
                                  }
                                  if (result == 'report') {
                                    showReportDialog(context, id);
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  List<PopupMenuEntry<String>> items = [
                                    const PopupMenuItem<String>(
                                      value: 'report',
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [Text('Signaler le message', style: TextStyle(color: kDanger, fontSize: 14, fontWeight: FontWeight.w400)), Icon(Icons.warning_amber_rounded, color: kDanger, size: 18)],
                                      ),
                                    ),
                                  ];

                                  items.add(
                                    const PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [Text('Supprimer le message', style: TextStyle(color: kDanger, fontSize: 14, fontWeight: FontWeight.w400)), Icon(Icons.delete_rounded, color: kDanger, size: 18)],
                                      ),
                                    ),
                                  );

                                  return items;
                                },
                                icon: const Icon(Icons.more_horiz_rounded, color: kBlack, size: 24),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Message
          content != '' ? Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0), child: Text(content, style: const TextStyle(fontSize: 14, color: kBlack, fontWeight: FontWeight.w400))) : const SizedBox(),

          const SizedBox(height: 12),

          // Images
          imagesUrl.isEmpty
              ? const SizedBox()
              : SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: imagesUrl.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: imagesUrl.length == 1 || index == imagesUrl.length - 1 ? EdgeInsets.zero : const EdgeInsets.only(right: 16.0),
                      child: GestureDetector(
                        onTap: () => handleImageTap(context, imageUrl: imagesUrl[index]),
                        child: Container(
                          padding: EdgeInsets.zero,
                          width: imagesUrl.length == 1 ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width * 0.85,
                          height: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(color: const Color.fromARGB(255, 255, 255, 255), borderRadius: BorderRadius.circular(0)),
                          child: CachedNetworkImage(
                            imageUrl: imagesUrl[index],
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            placeholder:
                                (context, url) => Center(
                                  child: CircularProgressIndicator(), // Affiche un spinner pendant le chargement
                                ),
                            errorWidget: (context, url, error) => const Icon(Icons.error), // Icône en cas d'erreur
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image qui prend la largeur de l'écran
            TapRegion(
              onTapOutside: (event) {
                Navigator.of(context).pop();
              },
              child: SizedBox(width: size.width, child: CachedNetworkImage(imageUrl: imageUrl, placeholder: (context, url) => const Placeholder(), errorWidget: (context, url, error) => const Icon(Icons.error), fit: BoxFit.contain)),
            ),
            // Bouton "Fermer" en dessous de l'image
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Fermer', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    iconSize: 32,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

void showReportDialog(BuildContext context, String id) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      bool isSpam = false;
      bool isInappropriate = false;
      bool isViolence = false;

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            backgroundColor: kWhite,
            surfaceTintColor: kWhite,
            title: const Text('Signaler'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CheckboxListTile(
                  title: const Text('Spam'),
                  value: isSpam,
                  onChanged: (bool? value) {
                    setState(() {
                      isSpam = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Inapproprié'),
                  value: isInappropriate,
                  onChanged: (bool? value) {
                    setState(() {
                      isInappropriate = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Violence'),
                  value: isViolence,
                  onChanged: (bool? value) {
                    setState(() {
                      isViolence = value ?? false;
                    });
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Annuler'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Signaler'),
                onPressed: () {
                  String warn = '';
                  if (isSpam) warn += 'Spam ';
                  if (isInappropriate) warn += 'Inapproprié ';
                  if (isViolence) warn += 'Violence ';

                  // Call the reportPost method
                  context.read<FeedController>().reportPost(id, warn.trim());

                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    },
  );
}
