import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/modules/modules.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/models/tmp/customization.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:provider/provider.dart';

class CustomizationController extends ChangeNotifier {
  late Customization customization;
  late Customization updatedCustomization;

  void initModuleCustomization(Module module) {
    updatedCustomization = Customization(backgroundColor: module.colorFilter, fontSize: module.textSize, fontName: module.fontType, textColor: module.textColor, imageUrl: module.image);
  }

  Future<void> updateCustomization({required BuildContext context, required String moduleId}) async {
    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(moduleId).update({
        'color_filter': updatedCustomization.backgroundColor,
        'typographie': updatedCustomization.fontName,
        'text_color': updatedCustomization.textColor,
        'text_size': updatedCustomization.fontSize,
      });
      if (updatedCustomization.imageUrl != null) {
        await context.read<ModulesController>().updateImage(moduleId: moduleId, newImage: updatedCustomization.imageUrl!);
        context.read<EventsController>().updateEvent(Event.instance);
      }

      context.read<EventsController>().updateModuleCustomization(customization: updatedCustomization, moduleId: moduleId);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future updateAllCustomizations({required BuildContext context}) async {
    try {
      var modules = await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').get();
      for (var module in modules.docs) {
        await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(module.id).update({
          'color_filter': updatedCustomization.backgroundColor,
          'typographie': updatedCustomization.fontName,
          'text_color': updatedCustomization.textColor,
          'text_size': updatedCustomization.fontSize,
        });
        context.read<EventsController>().updateModuleCustomization(customization: updatedCustomization, moduleId: module.id);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
