import 'package:flutter/material.dart';
import 'package:kapstr/widgets/organizer/modules/image_according_to_event.dart';

class IconAccordingToEvent extends StatelessWidget {
  final String moduleType;
  const IconAccordingToEvent({super.key, required this.moduleType});

  @override
  Widget build(BuildContext context) {
    return Container(margin: const EdgeInsets.only(left: 20), width: 20, height: 20, child: imageAccordingToModule(moduleType));
  }
}
