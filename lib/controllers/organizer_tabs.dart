import 'package:flutter/material.dart';

enum OrganizerTabIndex { dashboard, pictureWall, guests, profile }

class OrgaTabBarController extends ChangeNotifier {
  OrganizerTabIndex index = OrganizerTabIndex.dashboard;

  OrganizerTabIndex getIndex() {
    return index;
  }

  setIndex(OrganizerTabIndex newIndex) {
    index = newIndex;
    return notifyListeners();
  }
}
