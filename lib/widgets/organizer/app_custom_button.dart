import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/views/organizer/theme/browse_all.dart';

class AppCustomButton extends StatefulWidget {
  final VoidCallback onReturn;

  const AppCustomButton({super.key, required this.onReturn});

  @override
  State<AppCustomButton> createState() => _AppCustomButtonState();
}

class _AppCustomButtonState extends State<AppCustomButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => const BrowseThemes())).then((value) => widget.onReturn()); // Call the callback here
      },
      child: Container(margin: const EdgeInsets.all(4), width: 24, height: 24, child: Image.asset("assets/icons/magic-wand.png", color: Event.instance.buttonColor == '' ? kYellow : Color(int.parse('0xFF${Event.instance.buttonColor}')), width: 24)),
    );
  }
}
