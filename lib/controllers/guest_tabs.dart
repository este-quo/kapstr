import 'package:flutter/material.dart';

enum GuestTabIndex { dashboard, pictureWall, rsvp, profile }

class GuestTabBarController extends ChangeNotifier {
  GuestTabIndex index = GuestTabIndex.dashboard;

  GuestTabIndex getIndex() {
    return index;
  }

  setIndex(GuestTabIndex newIndex) {
    index = newIndex;
    return notifyListeners();
  }
}
