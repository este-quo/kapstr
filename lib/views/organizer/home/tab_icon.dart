import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/controllers/organizer_tabs.dart';
import 'package:kapstr/widgets/custom_svg_picture.dart';
import 'package:provider/provider.dart';

class OrgaHomePageTabBarButton extends StatelessWidget {
  final OrganizerTabIndex index;
  final OrganizerTabIndex currentIndex;
  final Function(OrganizerTabIndex) onChanged;
  final String assetPath;
  final String tabName;

  const OrgaHomePageTabBarButton({super.key, required this.index, required this.currentIndex, required this.onChanged, required this.assetPath, required this.tabName});

  @override
  Widget build(BuildContext context) {
    const double buttonSize = 40.0;

    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: InkWell(
        onTap: () async {
          triggerShortVibration();
          onChanged(index);
        },
        borderRadius: BorderRadius.circular(buttonSize / 2),
        child: Container(
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
                      tabName == "Profil" && context.watch<UsersController>().user!.imageUrl != ""
                          ? CircleAvatar(radius: 10, backgroundImage: CachedNetworkImageProvider(context.watch<UsersController>().user!.imageUrl))
                          : CustomAssetSvgPicture(assetPath, color: index == currentIndex ? kBlack : Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.30)),
                ),
                Text(tabName, style: TextStyle(color: index == currentIndex ? kBlack : Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.30), fontSize: 10)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
