import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/models/guest.dart';
import 'package:kapstr/models/modules/golden_book_message.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/logo_loader.dart';

class ProfilePicture extends StatelessWidget {
  const ProfilePicture({super.key, required this.name, required this.imageUrl, this.moduleId, this.message, this.guest});

  final String name;
  final String imageUrl;
  final String? moduleId;
  final GoldenBookMessage? message;
  final Guest? guest;

  @override
  Widget build(BuildContext context) {
    String getGuestInitial(String guestName) {
      return guestName.split(' ').map((word) => word.isNotEmpty ? word[0] : '').take(2).join().toUpperCase();
    }

    if (imageUrl.isEmpty) {
      // Afficher les initiales si imageUrl est vide
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(100), border: Border.all(color: kBorderColor, width: 1, strokeAlign: BorderSide.strokeAlignOutside)),
        child: ClipRRect(borderRadius: BorderRadius.circular(50), child: Center(child: Text(getGuestInitial(name), style: const TextStyle(color: kBlack, fontSize: 20, fontWeight: FontWeight.w500)))),
      );
    } else {
      // Afficher l'image si imageUrl n'est pas vide
      return ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: SizedBox(
          width: 80,
          height: 80,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (BuildContext context, String url) {
              return const Center(child: SizedBox(width: 24, height: 24, child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 24)));
            },
            errorWidget: (BuildContext context, String url, dynamic error) {
              return const Icon(Icons.error);
            },
          ),
        ),
      );
    }
  }
}
