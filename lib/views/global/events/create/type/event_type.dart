import 'package:flutter/material.dart';
import 'package:kapstr/controllers/event_data.dart';
import 'package:kapstr/helpers/event_type.dart';
import 'package:kapstr/views/global/events/create/type/types_list.dart';
import 'package:kapstr/views/global/events/create/layout.dart';
import 'package:kapstr/views/global/events/create/woman/woman_infos.dart';
import 'package:provider/provider.dart';

class EventType extends StatefulWidget {
  const EventType({super.key});

  @override
  ChooseEventTypeState createState() => ChooseEventTypeState();
}

class ChooseEventTypeState extends State<EventType> {
  EventTypes? selected;

  @override
  void initState() {
    super.initState();
  }

  bool hasSelectedAnEvent() {
    return selected != null;
  }

  @override
  Widget build(BuildContext context) {
    final onboardingData = context.read<EventDataController>();

    Future<void> confirm() async {
      if (hasSelectedAnEvent()) {
        onboardingData.eventType = selected!;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WomanInfosUI()));
      }
    }

    return OnBoardingLayout(
      confirm: confirm,
      title: "Type d’événement",
      children: [
        const SizedBox(height: 20),
        EventList(
          onEventSelected: (eventType) {
            setState(() {
              selected = eventType;
            });
          },
          selectedEventType: selected,
        ),
        const SizedBox(height: 96),
      ],
    );
  }
}
