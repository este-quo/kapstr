import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/authentication.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/global/feed/send_post.dart';
import 'package:kapstr/views/global/login/login.dart';
import 'package:kapstr/views/organizer/modules/golden_book/profile_picture.dart';
import 'package:provider/provider.dart';

class SendPostQuick extends StatelessWidget {
  const SendPostQuick({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (context.read<UsersController>().user != null) {
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            barrierColor: Colors.black.withOpacity(0.3),
            useSafeArea: true,
            builder: (context) {
              return DraggableScrollableSheet(
                initialChildSize: 1,
                minChildSize: 0.8,
                maxChildSize: 1,
                expand: false,
                builder: (context, scrollController) {
                  return SendPost(scrollController: scrollController);
                },
              );
            },
          );
        } else {
          context.read<AuthenticationController>().setPendingConnection(true);
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            barrierColor: Colors.black.withOpacity(0.3),
            useSafeArea: true,
            builder: (context) {
              return DraggableScrollableSheet(
                initialChildSize: 1,
                minChildSize: 0.8,
                maxChildSize: 1,
                expand: false,
                builder: (context, scrollController) {
                  return const LogIn();
                },
              );
            },
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 8),
        width: MediaQuery.of(context).size.width,
        height: 64,
        color: kWhite,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
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
            const Expanded(child: Text('Exprimez-vous...', style: TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w400))),
            const SizedBox(width: 12),
            const CircleAvatar(backgroundColor: kWhite, radius: 18, child: Icon(Icons.photo_library_rounded, color: kPrimary, size: 24)),
          ],
        ),
      ),
    );
  }
}
