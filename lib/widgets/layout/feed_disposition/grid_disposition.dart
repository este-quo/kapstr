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

class GridDisposition extends StatefulWidget {
  final List<Module> modules;
  final Function callback;

  const GridDisposition({super.key, required this.modules, required this.callback});

  @override
  State<GridDisposition> createState() => _GridDispositionState();
}

class _GridDispositionState extends State<GridDisposition> {
  @override
  void initState() {
    super.initState();
    _sortModules();
  }

  @override
  void didUpdateWidget(covariant GridDisposition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.modules != widget.modules) {
      _sortModules();
    }
  }

  void _sortModules() {
    setState(() {
      widget.modules.sort((a, b) => Event.instance.modulesOrder.indexOf(a.id).compareTo(Event.instance.modulesOrder.indexOf(b.id)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 40,
        child: ReorderableGridView.count(
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

            // Clear the image cache after updating the module order
            PaintingBinding.instance.imageCache.clear();
          },
          padding: const EdgeInsets.all(0),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(widget.modules.length, (index) {
            final module = widget.modules[index];
            return moduleCardGrid(
              key: ValueKey(module.id),
              textSize: module.textSize,
              textColor: fromHex(module.textColor),
              typographie: module.fontType,
              colorFilter: module.colorFilter == '' ? Colors.transparent : fromHex(module.colorFilter),
              title: module.name,
              context: context,
              imageUrl: module.image,
              onTap: () {
                triggerShortVibration();

                !context.read<EventsController>().isGuestPreview
                    ? Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => ModuleView(module: module))).then((value) {
                      context.read<EventsController>().updateModule(value);
                      // Clear the image cache after updating the module
                      PaintingBinding.instance.imageCache.clear();
                      widget.callback();
                    })
                    : module.type != 'album_photo'
                    ? Navigator.push(context, MaterialPageRoute(builder: (context) => buildGuestModuleView(module: module, isPreview: true)))
                    : Navigator.push(context, MaterialPageRoute(builder: (context) => AlbumPhoto(moduleId: module.id, isGuestView: true)));
              },
            );
          }),
        ),
      ),
    );
  }
}
