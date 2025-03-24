import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';

import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/models/app_event.dart';

import 'package:kapstr/themes/constants.dart';

import 'package:kapstr/widgets/buttons/main_button.dart';

import 'package:kapstr/widgets/layout/get_device_type.dart';
import 'package:provider/provider.dart';

class EventAcessPage extends StatefulWidget {
  const EventAcessPage({super.key});

  @override
  EventAcessPageState createState() => EventAcessPageState();
}

class EventAcessPageState extends State<EventAcessPage> {
  bool _isPrivateSelected = true;
  bool _isPublicSelected = false;

  @override
  void initState() {
    super.initState();

    final visibility = Event.instance.visibility;

    if (visibility == 'private') {
      setState(() {
        _isPrivateSelected = true;
        _isPublicSelected = false;
      });
    } else {
      setState(() {
        _isPrivateSelected = false;
        _isPublicSelected = true;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: MainButton(
        child: const Center(child: Text('Sauvegarder', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400))),
        onPressed: () async {
          final value = _isPrivateSelected ? 'private' : 'public';

          setState(() {
            Event.instance.visibility = value;
          });

          await context.read<EventsController>().updateEventField(key: 'visibility', value: value);

          context.read<EventsController>().updateEvent(Event.instance);

          Navigator.of(context).pop();
        },
      ),
      appBar: AppBar(
        title: const Text('Accessibilité'),
        backgroundColor: kWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 75,
        toolbarHeight: 40,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(onTap: () => Navigator.of(context).pop(), child: const Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: kBlack), Text('Retour', style: TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w500))])),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                setState(() {
                  _isPrivateSelected = true;
                  _isPublicSelected = false;
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: _isPrivateSelected ? kBlack : kWhite, border: Border.all(width: 1, color: _isPrivateSelected ? kBlack : kBlack.withValues(alpha: 0.3))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_rounded, color: _isPrivateSelected ? kWhite : kBlack),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Privé', textAlign: TextAlign.start, style: TextStyle(color: _isPrivateSelected ? kWhite : kBlack, fontSize: 16, fontWeight: FontWeight.w400)),
                        const Text('Seuls mes invités peuvent rejoindre', textAlign: TextAlign.start, style: TextStyle(color: kLightGrey, fontSize: 12, fontWeight: FontWeight.w400)),
                      ],
                    ),
                    const Spacer(),
                    _buildSelectionIndicator(_isPrivateSelected, kBlack, context),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                printOnDebug('Public selected');
                setState(() {
                  _isPrivateSelected = false;
                  _isPublicSelected = true;
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: _isPublicSelected ? kBlack : kWhite, border: Border.all(width: 1, color: _isPublicSelected ? kBlack : kBlack.withValues(alpha: 0.3))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.public_rounded, color: _isPublicSelected ? kWhite : kBlack),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Public', textAlign: TextAlign.start, style: TextStyle(color: _isPublicSelected ? kWhite : kBlack, fontSize: 16, fontWeight: FontWeight.w400)),
                        const Text('Tout le monde peut rejoindre', textAlign: TextAlign.start, style: TextStyle(color: kLightGrey, fontSize: 12, fontWeight: FontWeight.w400)),
                      ],
                    ),
                    const Spacer(),
                    _buildSelectionIndicator(_isPublicSelected, kBlack, context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildSelectionIndicator(bool isSelected, Color borderColor, BuildContext context) {
  final indicatorSize = getDeviceType(context) == 'phone' ? 20.0 : 24.0;
  return Container(
    width: indicatorSize,
    height: indicatorSize,
    decoration: BoxDecoration(shape: BoxShape.circle, color: kWhite, border: Border.all(width: 1, color: borderColor)),
    child: isSelected ? Container(margin: const EdgeInsets.all(5), decoration: const BoxDecoration(shape: BoxShape.circle, color: kBlack)) : Container(),
  );
}
