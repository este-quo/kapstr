import 'package:flutter/material.dart';
import 'package:kapstr/helpers/event_type.dart';
import 'package:kapstr/views/global/events/create/type/row.dart';

class EventList extends StatelessWidget {
  final Function(EventTypes selectedEventType) onEventSelected;
  final EventTypes? selectedEventType;

  const EventList({super.key, required this.onEventSelected, this.selectedEventType});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        TypeRow(
          title: 'Mariage',
          type: EventTypes.wedding,
          shortName: 'wedding',
          isNotAvailableYet: false,
          isSelected: selectedEventType == EventTypes.wedding,
          onSelected: () {
            onEventSelected(EventTypes.wedding);
          },
        ),
        TypeRow(
          title: 'Anniversaire',
          type: EventTypes.birthday,
          shortName: 'birthday',
          isNotAvailableYet: false,
          isSelected: selectedEventType == EventTypes.birthday,
          onSelected: () {
            onEventSelected(EventTypes.birthday);
          },
        ),
        TypeRow(
          title: 'Soirée',
          type: EventTypes.birthday,
          shortName: 'party',
          isNotAvailableYet: false,
          isSelected: selectedEventType == EventTypes.party,
          onSelected: () {
            onEventSelected(EventTypes.party);
          },
        ),
        TypeRow(
          title: 'Gala',
          type: EventTypes.gala,
          shortName: 'gala',
          isNotAvailableYet: false,
          isSelected: selectedEventType == EventTypes.gala,
          onSelected: () {
            onEventSelected(EventTypes.gala);
          },
        ),
        TypeRow(
          title: 'Bar Mitsvah',
          type: EventTypes.barMitsvah,
          shortName: 'barMitsvah',
          isNotAvailableYet: false,
          isSelected: selectedEventType == EventTypes.barMitsvah,
          onSelected: () {
            onEventSelected(EventTypes.barMitsvah);
          },
        ),
        TypeRow(
          title: 'Evèn. d\'entreprise',
          type: EventTypes.enterprise,
          shortName: 'corporateParty',
          isNotAvailableYet: false,
          isSelected: selectedEventType == EventTypes.enterprise,
          onSelected: () {
            onEventSelected(EventTypes.enterprise);
          },
        ),
        TypeRow(
          title: 'Salon/Exposition',
          type: EventTypes.salon,
          shortName: 'corporateParty',
          isNotAvailableYet: false,
          isSelected: selectedEventType == EventTypes.salon,
          onSelected: () {
            onEventSelected(EventTypes.salon);
          },
        ),
        TypeRow(
          title: 'Autre',
          type: EventTypes.other,
          shortName: 'autre',
          isNotAvailableYet: false,
          isSelected: selectedEventType == EventTypes.other,
          onSelected: () {
            onEventSelected(EventTypes.other);
          },
        ),
      ],
    );
  }
}
