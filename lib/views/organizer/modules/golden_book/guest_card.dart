import 'package:flutter/material.dart';
import 'package:kapstr/controllers/modules/golden_book.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/golden_book_message.dart';
import 'package:kapstr/models/guest.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/organizer/modules/golden_book/profile_picture.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:provider/provider.dart';

class GuestCard extends StatelessWidget {
  const GuestCard({super.key, required this.moduleId, required this.message});

  final String moduleId;
  final GoldenBookMessage message;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Guest>(
      future: context.read<GoldenBookController>().getGuestFromMessages(moduleId, message),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SizedBox(height: 32, width: 32, child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 32)));
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur lors du chargement des données', style: TextStyle(color: Event.instance.textColor == '' ? kBlack : Color(int.parse('0xFF${Event.instance.textColor}')))));
        } else if (snapshot.hasData) {
          Guest guest = snapshot.data!;

          return ProfilePicture(name: guest.name, imageUrl: guest.imageUrl, moduleId: moduleId, message: message, guest: guest);
        }

        return const Center(child: SizedBox(height: 32, width: 32, child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 32)));
      },
    );
  }
}
