import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/models/app_guest.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/guest/modules/golden_book/text_input.dart';
import 'package:kapstr/views/organizer/modules/golden_book/profile_picture.dart';
import 'package:provider/provider.dart';

class CardPreview extends StatefulWidget {
  const CardPreview({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<CardPreview> createState() => _CardPreviewState();
}

class _CardPreviewState extends State<CardPreview> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Message Container
        Container(
          padding: const EdgeInsets.only(top: 64, left: 16, right: 16, bottom: 16),
          margin: const EdgeInsets.only(top: 40),
          width: MediaQuery.of(context).size.width - 40,
          decoration: BoxDecoration(color: context.watch<EventsController>().event.fullResThemeUrl == '' ? kWhite : kWhite.withValues(alpha: 1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 1)),
          child: Column(
            children: [
              TextInput(controller: widget.controller),
              const Spacer(),
              Text(
                AppGuest.instance.name, // Utilisation des données du guest
                textAlign: TextAlign.center,
                style: TextStyle(color: context.watch<EventsController>().event.fullResThemeUrl == '' ? kWhite : kBlack, fontSize: 26, fontWeight: FontWeight.w500, fontFamily: GoogleFonts.greatVibes().fontFamily),
              ),
            ],
          ),
        ),
        // Profile Picture
        context.watch<UsersController>().user == null ? const Positioned(top: 0, child: ProfilePicture(name: "Invité Exemple", imageUrl: "")) : Positioned(top: 0, child: ProfilePicture(name: context.watch<UsersController>().user!.name, imageUrl: context.watch<UsersController>().user!.imageUrl)),
      ],
    );
  }
}
