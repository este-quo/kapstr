import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/custom_svg_picture.dart';
import 'package:kapstr/controllers/guest_tabs.dart';
import 'package:provider/provider.dart';

class GuestHomePageTabBarButton extends StatelessWidget {
  final GuestTabIndex index;
  final GuestTabIndex currentIndex;
  final Function(GuestTabIndex) onChanged;
  final String assetPath;
  final bool showNotification;
  final String tabName;

  const GuestHomePageTabBarButton({
    super.key,
    required this.index,
    required this.currentIndex,
    required this.onChanged,
    required this.assetPath,
    required this.tabName,
    this.showNotification = false, // Default value is set to false
  });

  @override
  Widget build(BuildContext context) {
    const double buttonSize = 48.0;
    const double notificationDotSize = 8.0;
    const double notificationDotRight = 12.0; // Adjust as needed for your layout
    const double notificationDotTop = 13.0; // Adjust as needed for your layout

    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: InkWell(
        onTap: () {
          triggerShortVibration();
          onChanged(index);
        },
        borderRadius: BorderRadius.circular(buttonSize / 2),
        child: Stack(
          clipBehavior: Clip.none, // Allows overflow
          children: [
            Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(shape: BoxShape.circle, color: index == currentIndex ? Colors.white : null),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          (tabName == "Profil" && context.watch<UsersController>().user != null && context.watch<UsersController>().user!.imageUrl.isNotEmpty)
                              ? CircleAvatar(radius: 10, backgroundImage: CachedNetworkImageProvider(context.watch<UsersController>().user!.imageUrl))
                              : CustomAssetSvgPicture(assetPath, color: index == currentIndex ? kBlack : Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.30)),
                    ),
                    Text(tabName, style: TextStyle(color: index == currentIndex ? kBlack : Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.30), fontSize: 10)),
                  ],
                ),
              ),
            ),
            if (showNotification) // Display notification dot if showNotification is true
              Positioned(right: notificationDotRight, top: notificationDotTop, child: Container(width: notificationDotSize, height: notificationDotSize, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
          ],
        ),
      ),
    );
  }
}
