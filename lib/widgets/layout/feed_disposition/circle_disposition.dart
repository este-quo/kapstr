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

class CircleDisposition extends StatefulWidget {
  final List<Module> modules;
  final Function callback;

  const CircleDisposition({super.key, required this.modules, required this.callback});

  @override
  State<CircleDisposition> createState() => _CircleDispositionState();
}

class _CircleDispositionState extends State<CircleDisposition> {
  @override
  void didUpdateWidget(covariant CircleDisposition oldWidget) {
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
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width * 0.9,
      child: Row(
        children: [
          Expanded(
            child: ReorderableListView.builder(
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
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              scrollDirection: Axis.horizontal,
              itemCount: widget.modules.length,
              itemBuilder: (context, index) {
                final module = widget.modules[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  key: ValueKey(module.id),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.width * 0.9,
                    child: moduleCardCircle(
                      textColor: fromHex(module.textColor),
                      textSize: module.textSize,
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
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
