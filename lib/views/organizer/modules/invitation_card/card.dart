import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kapstr/controllers/modules/invitations.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/organizer/modules/invitation_card/editable_text.dart';
import 'package:kapstr/views/organizer/modules/invitation_card/recto.dart';
import 'package:kapstr/views/organizer/modules/invitation_card/verso.dart';

import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class InvitationCardPreview extends StatefulWidget {
  const InvitationCardPreview({super.key});

  @override
  State<InvitationCardPreview> createState() => _InvitationCardPreviewState();
}

class _InvitationCardPreviewState extends State<InvitationCardPreview> {
  @override
  Widget build(BuildContext context) {
    final controller = PageController();
    var rectoKey = GlobalKey();
    var versoKey = GlobalKey();

    return Scaffold(
      extendBody: true,
      backgroundColor: kLighterGrey,
      floatingActionButton: GestureDetector(
        onTap: () async {
          if (controller.page == 0) {
            rectoEditableTextKey.currentState?.toggleEditing();
          } else if (controller.page == 1) {
            versoEditableTextKey.currentState?.toggleEditing();
          } else {
            return;
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(color: kBlack, borderRadius: BorderRadius.circular(999), border: Border.all(color: const Color.fromARGB(30, 0, 0, 0), width: 1, strokeAlign: BorderSide.strokeAlignOutside)),
          child: const Icon(Icons.brush_rounded, color: kWhite, size: 22),
        ),
      ),
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
        elevation: 0,
        leadingWidth: 75,
        toolbarHeight: 40,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(onTap: () => Navigator.of(context).pop(), child: const Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: kBlack), Text('Retour', style: TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w500))])),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Show confirmation dialog
              final bool? confirmed = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: kWhite,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    surfaceTintColor: kWhite,
                    title: const Text('Confirmation'),
                    content: const Text('Êtes-vous sûr de vouloir réinitialiser la carte d\'invitation ?', style: TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w400)),
                    actions: <Widget>[TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')), TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Réinitialiser'))],
                  );
                },
              );

              // If confirmed, execute your logic
              if (confirmed ?? false) {
                await context.read<InvitationsController>().resetInvitation();
                setState(() {
                  rectoKey = GlobalKey();
                  versoKey = GlobalKey();
                  controller.jumpToPage(0);
                });
              }
            },
            child: const Text('Réinitialiser', style: TextStyle(color: kPrimary, fontSize: 14, fontWeight: FontWeight.w400)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              SizedBox(height: 650, child: PageView(controller: controller, clipBehavior: Clip.none, children: <StatefulWidget>[CardRecto(key: rectoKey), CardVerso(key: versoKey)])),

              const SizedBox(height: 16),

              // Page indicator
              SmoothPageIndicator(controller: controller, count: 2, effect: const WormEffect(dotHeight: 8, dotWidth: 8, activeDotColor: kBlack, dotColor: kGrey)),
            ],
          ),
        ),
      ),
    );
  }
}
