import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kapstr/controllers/themes.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/models/app_event.dart';

import 'package:provider/provider.dart';

class UserLetters extends StatefulWidget {
  const UserLetters({super.key});

  @override
  State<UserLetters> createState() => _UserLettersState();
}

class _UserLettersState extends State<UserLetters> {
  @override
  Widget build(BuildContext context) {
    printOnDebug('Event.instance.manFirstName: ${Event.instance.manFirstName}');
    printOnDebug('Event.instance.womanFirstName: ${Event.instance.womanFirstName}');

    printOnDebug('Event.instance.manFirstName: ${Event.instance.manFirstName.substring(0, 1).toUpperCase()}');
    printOnDebug('Event.instance.womanFirstName: ${Event.instance.womanFirstName.substring(0, 1).toUpperCase()}');

    return Center(
      child: Text(
        '${Event.instance.manFirstName.substring(0, 1).toUpperCase()}'
        '&${Event.instance.womanFirstName.substring(0, 1).toUpperCase()}',
        style: TextStyle(fontSize: 24, fontFamily: GoogleFonts.playfairDisplay().fontFamily, color: context.watch<ThemeController>().getTextColor()),
      ),
    );
  }
}
