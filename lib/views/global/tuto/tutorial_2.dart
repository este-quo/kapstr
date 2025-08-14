import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';

class TutorialTwo extends StatefulWidget {
  const TutorialTwo({super.key});

  @override
  State<TutorialTwo> createState() => _TutorialTwoState();
}

class _TutorialTwoState extends State<TutorialTwo> {
  Timer? _timer;
  final Random _random = Random();
  final List<String> _imagePaths = [
    'assets/theme1.png',
    'assets/theme2.png',
    'assets/theme3.png',
    'assets/theme4.png',
    'assets/theme5.png',
    'assets/theme6.png',
    'assets/theme7.png',
    'assets/theme8.png',
    'assets/theme9.png',
    'assets/theme10.png',
    'assets/theme11.png',
    'assets/theme12.png',
    'assets/theme13.png',
    'assets/theme14.png',
    'assets/theme15.png',
    'assets/theme16.png',
    'assets/theme17.png',
    'assets/theme18.png',
    'assets/theme19.png',
    'assets/theme20.png',
  ];

  // Stocker les indices des images actuellement affichées
  List<int> _currentImageIndices = [0, 1, 2, 3, 4, 5];

  @override
  void initState() {
    super.initState();
    _currentImageIndices = List.generate(_imagePaths.length, (index) => index);
    _startImageRotation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheImages(); // Move precaching logic here
  }

  void _precacheImages() {
    // Précharger chaque image dans la liste
    for (String imagePath in _imagePaths) {
      precacheImage(AssetImage(imagePath), context);
    }
  }

  void _startImageRotation() {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        // Mélanger la liste des indices d'images pour obtenir un nouvel ordre sans doublons
        _currentImageIndices.shuffle(_random);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          children: [
            // Image
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.5,
              child: OverflowBox(
                alignment: Alignment.bottomCenter,
                minHeight: MediaQuery.of(context).size.height * 0.5 + 60,
                minWidth: MediaQuery.of(context).size.width + 90,
                maxWidth: MediaQuery.of(context).size.width + 90,
                maxHeight: MediaQuery.of(context).size.height * 0.5 + 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(3, (columnIndex) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(2, (index) {
                        int imageIndex = columnIndex * 2 + index;

                        double heightFraction = columnIndex == 1 ? (index == 0 ? 0.45 : 0.55) : (index == 0 ? 0.55 : 0.45);

                        return AnimatedSwitcher(
                          duration: Duration(milliseconds: 500),
                          switchInCurve: Curves.easeIn,
                          child: Container(
                            width: (MediaQuery.of(context).size.width + 74) / 3,
                            height: ((MediaQuery.of(context).size.height * 0.5) + 52) * heightFraction,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: kGrey, image: DecorationImage(image: AssetImage(_imagePaths[_currentImageIndices[imageIndex]]), fit: BoxFit.cover)),
                          ),
                        );
                      }),
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Titre
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Text('Personnalisez votre design facilement', textAlign: TextAlign.center, style: TextStyle(color: kBlack, fontSize: 32, fontWeight: FontWeight.w700)),

                  SizedBox(height: 12),

                  // Description
                  Text('300 thèmes disponibles pour customiser votre un faire-part unique !', textAlign: TextAlign.center, style: TextStyle(color: kGrey, fontSize: 16, fontWeight: FontWeight.w400)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
