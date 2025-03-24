import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kapstr/controllers/themes.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/views/global/feed/save_the_date_page.dart';
import 'package:kapstr/widgets/custom_svg_picture.dart';

import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:provider/provider.dart';

class SaveTheDate extends StatefulWidget {
  const SaveTheDate({super.key});

  @override
  State<SaveTheDate> createState() => _SaveTheDateState();
}

class _SaveTheDateState extends State<SaveTheDate> {
  late Module module;
  late DateTime moduleDate;
  Duration timeLeft = Duration.zero;
  late Timer timer;

  void updateTime() {
    final now = DateTime.now();
    setState(() {
      timeLeft = moduleDate.difference(now);
    });
  }

  @override
  void initState() {
    super.initState();
    module = Event.instance.modules.firstWhere((module) => module.type == 'wedding');
    moduleDate = module.date!;

    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => updateTime());
    updateTime();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    if (moduleDate.isBefore(now)) {
      return const SizedBox.shrink(); // Retourner un widget vide ou tout autre widget de votre choix
    }

    // Calcul des jours, heures et minutes restants
    int daysLeft = timeLeft.inDays;
    int hoursLeft = timeLeft.inHours % 24;
    int minutesLeft = timeLeft.inMinutes % 60;
    int secondsLeft = timeLeft.inSeconds % 60;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => SaveTheDatePage(module: module, moduleDate: moduleDate)));
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: kBlack,
          // image: DecorationImage(
          //   image: const AssetImage('assets/save_the_date.jpg'),
          //   fit: BoxFit.cover,
          //   colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.3), BlendMode.darken),
          // ),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            children: [
              // Title
              Text('Save the Date', style: TextStyle(fontSize: 26, color: context.read<ThemeController>().getTextColor(color: kWhite), fontWeight: FontWeight.w500, fontFamily: GoogleFonts.greatVibes().fontFamily)),

              const SizedBox(height: 16),

              // Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 24),
                  // Days
                  _timerBackground(child: Center(child: Text('${daysLeft}j', style: const TextStyle(fontSize: 16, color: kBlack, fontWeight: FontWeight.w500, fontFamily: 'Inter')))),

                  // Hours
                  _timerBackground(child: Center(child: Text('${hoursLeft}h', style: const TextStyle(fontSize: 16, color: kBlack, fontWeight: FontWeight.w500, fontFamily: 'Inter')))),

                  // Minutes
                  _timerBackground(child: Center(child: Text('${minutesLeft}m', style: const TextStyle(fontSize: 16, color: kBlack, fontWeight: FontWeight.w500, fontFamily: 'Inter')))),

                  // Seconds
                  _timerBackground(child: Center(child: Text('${secondsLeft}s', style: const TextStyle(fontSize: 16, color: kBlack, fontWeight: FontWeight.w500, fontFamily: 'Inter')))),

                  // Redirect to save the date page
                  Padding(padding: const EdgeInsets.all(8.0), child: CustomAssetSvgPicture('assets/icons/forward_arrow.svg', width: 16, height: 16, color: context.read<ThemeController>().getTextColor(color: kWhite))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _timerBackground({required Widget child}) {
  return Container(width: 50, height: 50, decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(8)), child: Center(child: child));
}
