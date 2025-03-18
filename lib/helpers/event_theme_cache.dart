import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EventThemeCache with ChangeNotifier {
  ImageProvider? _cachedImage;
  String _currentEventId = "";

  ImageProvider? get cachedImage => _cachedImage;
  String get currentEventId => _currentEventId;

  void updateEventTheme(String eventId, String imageUrl) {
    if (eventId != _currentEventId) {
      _currentEventId = eventId;
      _cachedImage = CachedNetworkImageProvider(imageUrl);
      notifyListeners();
    }
  }
}
