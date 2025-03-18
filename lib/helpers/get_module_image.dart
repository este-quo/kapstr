import 'package:firebase_storage/firebase_storage.dart';

Future<String> getModuleImage(Reference image) async {
  return await image.getDownloadURL();
}
