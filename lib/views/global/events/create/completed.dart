import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/organizer/home/configuration.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class OnboardingComplete extends StatefulWidget {
  const OnboardingComplete({super.key});

  @override
  State<OnboardingComplete> createState() => _OnboardingCompleteState();
}

class _OnboardingCompleteState extends State<OnboardingComplete> {
  double _progress = 0;
  Timer? _completelyFakeTimer;
  @override
  void initState() {
    super.initState();
    _animatedCircleTimer();
  }

  @override
  void dispose() {
    _completelyFakeTimer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int loadingProgress = (_progress * 100).floor();
    return Scaffold(
      floatingActionButton:
          loadingProgress == 100
              ? MainButton(
                onPressed: () {
                  triggerShortVibration();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const OrgaHomepageConfiguration()));
                },
                backgroundColor: kWhite,
                child: const Text(textAlign: TextAlign.center, 'Démarrer', style: TextStyle(color: kBlack, fontSize: 16.0, fontWeight: FontWeight.w400)),
              )
              : const SizedBox(),
      extendBody: true,
      backgroundColor: kBlack,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/icons/app/splash_dark.png', width: 120),
              const SizedBox(height: 32),
              Center(
                child:
                    loadingProgress != 100
                        ? const Text('Votre application est en cours de création', textAlign: TextAlign.center, style: TextStyle(color: kWhite, fontSize: 20, fontWeight: FontWeight.w400))
                        : const Text('Votre application est prête !', style: TextStyle(color: kWhite, fontSize: 20, fontWeight: FontWeight.w400)),
              ),
              const SizedBox(height: 48),
              Container(
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 1.5, color: kWhite.withValues(alpha: 0.2))),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 1.5, color: kWhite.withValues(alpha: 0.6))),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    child: CircularPercentIndicator(
                      radius: 100,
                      animation: true,
                      animationDuration: 1000,
                      lineWidth: 1.5,
                      percent: _progress,
                      circularStrokeCap: CircularStrokeCap.round,
                      animateFromLastPercent: true,
                      backgroundColor: const Color(0xFF979797),
                      progressColor: kWhite,
                      center: Padding(padding: const EdgeInsets.only(top: 5.0), child: Text(textAlign: TextAlign.center, '$loadingProgress%', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: kWhite, fontStyle: FontStyle.italic))),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 64),
            ],
          ),
        ],
      ),
    );
  }

  void _animatedCircleTimer() {
    _completelyFakeTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if ((_progress * 100).floor() < 95) {
        setState(() {
          _progress += Random().nextDouble() / 10;
        });
      }
      if ((_progress * 100).floor() >= 95) {
        setState(() {
          _progress = 1;
        });
        timer.cancel();
      }
    });
  }
}
