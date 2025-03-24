import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/views/guest/modules/view_manager.dart';
import 'package:kapstr/views/organizer/modules/album_photo/album_photo.dart';
import 'package:kapstr/views/organizer/modules/module_view.dart';
import 'package:kapstr/widgets/layout/feed_disposition/module_card.dart';
import 'package:kapstr/helpers/format_colors.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class LinearDisposition extends StatefulWidget {
  final List<Module> modules;
  final Function callback;

  const LinearDisposition({super.key, required this.modules, required this.callback});

  @override
  State<LinearDisposition> createState() => _LinearDispositionState();
}

class _LinearDispositionState extends State<LinearDisposition> {
  @override
  void didUpdateWidget(covariant LinearDisposition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.modules != widget.modules) {
      // Sort the modules only if there is a change in the widget's modules property
      widget.modules.sort((a, b) => Event.instance.modulesOrder.indexOf(a.id).compareTo(Event.instance.modulesOrder.indexOf(b.id)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableGridView.count(
      onReorder: (oldIndex, newIndex) async {
        setState(() {
          if (newIndex > widget.modules.length - 1) newIndex = widget.modules.length - 1;
          Module movedModule = widget.modules.removeAt(oldIndex);
          widget.modules.insert(newIndex, movedModule);

          // Update the Event.instance.modulesOrder list with the new order
          Event.instance.modulesOrder = widget.modules.map((module) => module.id).toList();
        });

        // Update the order in Firestore
        await context.read<EventsController>().updateModulesOrder();
      },
      shrinkWrap: true,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      crossAxisCount: 1,
      childAspectRatio: 2.5,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var i = 0; i < widget.modules.length; i++)
          moduleCard(
            key: ValueKey(widget.modules[i].id),
            fontSize: widget.modules[i].textSize,
            textColor: fromHex(widget.modules[i].textColor),
            typographie: widget.modules[i].fontType,
            colorFilter: widget.modules[i].colorFilter == '' ? Colors.transparent : fromHex(widget.modules[i].colorFilter),
            title: widget.modules[i].name,
            context: context,
            imageUrl: widget.modules[i].image,
            onTap: () {
              triggerShortVibration();

              !context.read<EventsController>().isGuestPreview
                  ? Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => ModuleView(module: widget.modules[i]))).then((value) {
                    context.read<EventsController>().updateModule(value);
                    // Clear the image cache after updating the module
                    PaintingBinding.instance.imageCache.clear();
                    widget.callback();
                  })
                  : widget.modules[i].type != 'album_photo'
                  ? Navigator.push(context, MaterialPageRoute(builder: (context) => buildGuestModuleView(module: widget.modules[i], isPreview: true)))
                  : Navigator.push(context, MaterialPageRoute(builder: (context) => AlbumPhoto(moduleId: widget.modules[i].id, isGuestView: true)));
            },
          ),
      ],
    );
  }
}
