import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.id, required this.title, required this.body, this.image, required this.seen});

  final String id;
  final String title;
  final String body;
  final String? image;
  final bool seen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(color: seen ? kWhite : kPrimary.withValues(alpha: 0.1), border: Border(bottom: BorderSide(width: 1, color: Colors.black.withValues(alpha: 0.1)))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile picture
          SizedBox(width: 48, height: 48, child: image != null && image != '' ? CircleAvatar(backgroundImage: CachedNetworkImageProvider(image!), backgroundColor: kLighterGrey) : const CircleAvatar(backgroundColor: kLighterGrey, child: Icon(Icons.person, color: kWhite, size: 28))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(title, style: const TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w500)), Text(body, style: const TextStyle(color: kLightGrey, fontSize: 14, fontWeight: FontWeight.w400))],
            ),
          ),
        ],
      ),
    );
  }
}
