import 'package:flutter/material.dart';
import 'package:kapstr/helpers/event_type.dart';

class EventDataController extends ChangeNotifier {
  EventTypes eventType = EventTypes.wedding;
  String eventVisibility = "public";
  String eventDate = "";
  String manFirstName = "";
  String manLastName = "";
  String womanFirstName = "";
  String womanLastName = "";
  String phoneNumber = "";
  String logoUrl = "";

  void reset() {
    eventType = EventTypes.wedding;
    eventVisibility = "public";
    eventDate = "";
    manFirstName = "";
    manLastName = "";
    womanFirstName = "";
    womanLastName = "";
    phoneNumber = "";
    logoUrl = "";
    notifyListeners();
  }

  void updateEventType(EventTypes value) {
    eventType = value;
    notifyListeners();
  }

  void updateEventVisibility(String value) {
    eventVisibility = value;
    notifyListeners();
  }

  void updateEventLogo(String value) {
    logoUrl = value;
    notifyListeners();
  }

  void updateEventDate(String value) {
    eventDate = value;
    notifyListeners();
  }

  void updateManFirstName(String value) {
    manFirstName = value;
    notifyListeners();
  }

  void updateManLastName(String value) {
    manLastName = value;
    notifyListeners();
  }

  void updateWomanFirstName(String value) {
    womanFirstName = value;
    notifyListeners();
  }

  void updateWomanLastName(String value) {
    womanLastName = value;
    notifyListeners();
  }

  void updatePhoneNumber(String value) {
    phoneNumber = value;
    notifyListeners();
  }
}
