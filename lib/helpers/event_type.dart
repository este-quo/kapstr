enum EventTypes { wedding, salon, gala, birthday, party, enterprise, barMitsvah, other }

class Event {
  //for a given string, give the event type
  static EventTypes getEventTypeFromString(String eventType) {
    switch (eventType) {
      case 'mariage':
        return EventTypes.wedding;
      case 'salon':
        return EventTypes.salon;
      case 'gala':
        return EventTypes.gala;
      case 'anniversaire':
        return EventTypes.birthday;
      case 'soirée':
        return EventTypes.party;
      case 'entreprise':
        return EventTypes.enterprise;
      case 'bar mitsvah':
        return EventTypes.barMitsvah;
      case 'autre':
        return EventTypes.other;
      default:
        return EventTypes.other;
    }
  }

  //for a given event type, give the string
  static String getStringFromEventType(EventTypes eventType) {
    switch (eventType) {
      case EventTypes.wedding:
        return 'mariage';
      case EventTypes.salon:
        return 'salon';
      case EventTypes.gala:
        return 'gala';
      case EventTypes.birthday:
        return 'anniversaire';
      case EventTypes.party:
        return 'soirée';
      case EventTypes.enterprise:
        return 'entreprise';
      case EventTypes.barMitsvah:
        return 'bar mitsvah';
      case EventTypes.other:
        return 'autre';
    }
  }
}
