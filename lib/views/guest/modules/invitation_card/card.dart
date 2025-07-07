import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/guest/modules/invitation_card/recto.dart';
import 'package:kapstr/views/guest/modules/invitation_card/verso.dart';

import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class InvitationCard extends StatelessWidget {
  const InvitationCard({super.key, isPreview = false});

  @override
  Widget build(BuildContext context) {
    final controller = PageController();

    return Scaffold(
      extendBody: true,
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
        actions: const [SizedBox(width: 91)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              SizedBox(height: 650, child: PageView(controller: controller, clipBehavior: Clip.none, children: const <StatefulWidget>[CardRectoGuest(), CardVersoGuest()])),

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
