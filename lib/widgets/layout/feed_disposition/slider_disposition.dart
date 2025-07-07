import 'package:cached_network_image/cached_network_image.dart';
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

class SliderDisposition extends StatefulWidget {
  final List<Module> modules;
  final Function callback;

  const SliderDisposition({super.key, required this.modules, required this.callback});

  @override
  State<SliderDisposition> createState() => _SliderDispositionState();
}

class _SliderDispositionState extends State<SliderDisposition> {
  @override
  void didUpdateWidget(covariant SliderDisposition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.modules != widget.modules) {
      // Sort the modules only if there is a change in the widget's modules property
      widget.modules.sort((a, b) => Event.instance.modulesOrder.indexOf(a.id).compareTo(Event.instance.modulesOrder.indexOf(b.id)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.5,
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
                return Padding(
                  key: ValueKey(widget.modules[index].id),
                  padding: const EdgeInsets.only(right: 8.0),
                  child: moduleCardSlider(
                    textColor: fromHex(widget.modules[index].textColor),
                    textSize: widget.modules[index].textSize,
                    typographie: widget.modules[index].fontType,
                    colorFilter: widget.modules[index].colorFilter == '' ? Colors.transparent : fromHex(widget.modules[index].colorFilter),
                    title: widget.modules[index].name,
                    context: context,
                    imageUrl: widget.modules[index].image,
                    onTap: () {
                      triggerShortVibration();

                      !context.read<EventsController>().isGuestPreview
                          ? Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => ModuleView(module: widget.modules[index]))).then((value) {
                            context.read<EventsController>().updateModule(value);
                            // Clear the image cache after updating the module
                            PaintingBinding.instance.imageCache.clear();
                            widget.callback();
                          })
                          : widget.modules[index].type != 'album_photo'
                          ? Navigator.push(context, MaterialPageRoute(builder: (context) => buildGuestModuleView(module: widget.modules[index], isPreview: true)))
                          : Navigator.push(context, MaterialPageRoute(builder: (context) => AlbumPhoto(moduleId: widget.modules[index].id, isGuestView: true)));
                    },
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
