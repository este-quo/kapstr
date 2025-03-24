import 'package:flutter/material.dart';
import 'package:kapstr/components/buttons/module_action.dart';
import 'package:kapstr/components/dialogs/custom_module.dart';
import 'package:kapstr/controllers/customization.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/helpers/format_colors.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/guest/modules/view_manager.dart';
import 'package:kapstr/views/organizer/modules/album_photo/album_photo.dart';
import 'package:kapstr/views/organizer/modules/update.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:kapstr/widgets/organizer/modules/description_according_to_module_type.dart';
import 'package:kapstr/widgets/organizer/modules/delete_module_dialog.dart';
import 'package:kapstr/widgets/organizer/modules/text_according_to_event.dart';
import 'package:provider/provider.dart';

class ModuleView extends StatefulWidget {
  final Module module;

  const ModuleView({super.key, required this.module});

  @override
  State<ModuleView> createState() => _ModuleViewState();
}

class _ModuleViewState extends State<ModuleView> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<UpdateModuleState> updateModuleKey = GlobalKey<UpdateModuleState>();
    return Scaffold(
      bottomNavigationBar: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MainButton(
              onPressed: () async {
                triggerShortVibration();
                await updateModuleKey.currentState?.saveData();
                Navigator.of(context).pop(widget.module);
              },
              backgroundColor: kBlack,
              child: const Text('Sauvegarder', style: TextStyle(color: kWhite, fontSize: 16)),
            ),
            const SizedBox(height: 12),
            MainButton(
              onPressed: () async {
                //Navigate
                context.read<CustomizationController>().initModuleCustomization(widget.module);
                showCustomModuleDialog(context, widget.module);
              },
              backgroundColor: kPrimary,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [Icon(Icons.edit, color: kWhite, size: 20), SizedBox(width: 12), Text('Personnaliser', style: TextStyle(color: kWhite, fontSize: 16))],
              ),
            ),
            const SizedBox(height: 8),
            widget.module.type == "wedding"
                ? const SizedBox(height: 8)
                : Center(
                  child: TextButton(
                    onPressed: (() async {
                      await deleteModuleDialog(context, widget.module.id);
                    }),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [Text('Supprimer le module', style: TextStyle(color: kDanger, fontSize: 14, fontWeight: FontWeight.w500)), SizedBox(width: 8), Icon(Icons.delete_outline_outlined, color: kDanger, size: 18)],
                    ),
                  ),
                ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      appBar: moduleAppBar(widget.module, context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Title
              RichText(text: TextSpan(text: 'Module ', style: const TextStyle(fontSize: 24, color: kBlack, fontWeight: FontWeight.w600), children: <TextSpan>[TextSpan(text: widget.module.name, style: const TextStyle(fontSize: 24, color: kBlack, fontWeight: FontWeight.w800))])),

              const SizedBox(height: 8),

              // Subtitle
              Text(descriptionAccordingToEventType(widget.module.type), textAlign: TextAlign.left, style: const TextStyle(fontSize: 14, color: kBlack, fontWeight: FontWeight.w300)),

              const SizedBox(height: 24),

              if (widget.module.type != 'wedding' && widget.module.type != 'mairie' && widget.module.type != 'event') ModuleAction(module: widget.module, text: optionsAccordingToEventType(widget.module.type), icon: Icons.edit),
              if (widget.module.type != 'wedding' && widget.module.type != 'mairie' && widget.module.type != 'event') const SizedBox(height: 24),

              SizedBox(width: double.infinity, child: UpdateModule(module: widget.module, key: updateModuleKey)),
              SizedBox(height: 150),
            ],
          ),
        ),
      ),
    );
  }
}

void showCustomModuleDialog(BuildContext context, Module module) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Permet d'utiliser la totalité de l'écran si nécessaire
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) {
      return CustomModuleDialog(module: module);
    },
  );
}

PreferredSize moduleAppBar(Module module, BuildContext context) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(110.0),
    child: AppBar(
      backgroundColor: Colors.transparent, // Mettre transparent pour que l'image soit visible
      elevation: 0,
      leadingWidth: 75,
      toolbarHeight: 40,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: GestureDetector(onTap: () => Navigator.of(context).pop(module), child: const Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: kWhite), Text('Retour', style: TextStyle(color: kWhite, fontSize: 14, fontWeight: FontWeight.w500))])),
      ),
      flexibleSpace: Stack(fit: StackFit.expand, children: [Image.network(module.image, fit: BoxFit.cover, color: fromHex(module.colorFilter).withOpacity(0.5), colorBlendMode: BlendMode.srcOver)]),
      actions: [
        MainButton(
          onPressed: () async {
            triggerShortVibration();

            context.read<EventsController>().changeGuestPreview();

            if (module.type != 'album_photo') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => buildGuestModuleView(module: module, isPreview: true))).then((value) => context.read<EventsController>().changeGuestPreview());
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AlbumPhoto(moduleId: module.id, isGuestView: true))).then((value) => context.read<EventsController>().changeGuestPreview());
            }
          },
          backgroundColor: kBlack,
          width: 105,
          height: 25,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [Text('Mode Invité', style: TextStyle(color: kWhite, fontSize: 12)), SizedBox(width: 8), Icon(Icons.remove_red_eye, color: kWhite, size: 13)],
          ),
        ),
        const SizedBox(width: 16.0),
      ],
    ),
  );
}
