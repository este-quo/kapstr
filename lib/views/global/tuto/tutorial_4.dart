import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/organizer/home/configuration.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class TutorialFour extends StatefulWidget {
  const TutorialFour({super.key});

  @override
  State<TutorialFour> createState() => _TutorialFourState();
}

class _TutorialFourState extends State<TutorialFour> {
  bool _isContentVisible = false; // Contrôle l'affichage du contenu supplémentaire
  bool _isButtonGreen = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Démarrer l'animation 3 secondes après l'initialisation du widget
    _timer = Timer(const Duration(seconds: 2), () {
      setState(() {
        _isContentVisible = true;
        _isButtonGreen = true;
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.57,
              child: OverflowBox(
                alignment: Alignment.bottomCenter,
                minHeight: MediaQuery.of(context).size.height * 0.57 + 60,
                minWidth: MediaQuery.of(context).size.width + 200,
                maxWidth: MediaQuery.of(context).size.width + 200,
                maxHeight: MediaQuery.of(context).size.height * 0.57 + 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(3, (columnIndex) {
                    return Column(
                      children: List.generate(2, (index) {
                        printOnDebug('Column index: $columnIndex, Index: $index');
                        bool isFourthImage = columnIndex * 2 + index == 3;
                        int imageIndex = columnIndex * 2 + index + 1;
                        return Stack(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(boxShadow: [BoxShadow(color: kGrey.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))], color: kWhite, borderRadius: BorderRadius.circular(8)),
                              width: (MediaQuery.of(context).size.width + 184) / 3,
                              height: isFourthImage ? (MediaQuery.of(context).size.width + 184) / 3 + 80 : (MediaQuery.of(context).size.width + 184) / 3,
                              child: Column(
                                children: [
                                  Expanded(child: Container(height: 200, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), image: DecorationImage(image: AssetImage('assets/imagersvp${imageIndex}.png'), fit: BoxFit.cover)))),
                                  if (isFourthImage)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Soirée', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black)),
                                          const SizedBox(height: 4),
                                          AnimatedCrossFade(
                                            firstChild: SizedBox(height: 30, child: MainButton(onPressed: null, child: const Text('Participer', style: TextStyle(color: kWhite, fontSize: 12, fontWeight: FontWeight.w400)))),
                                            secondChild: SizedBox(height: 30, child: MainButton(backgroundColor: const Color.fromARGB(255, 49, 198, 91), child: const Text('Présent', style: TextStyle(color: kWhite, fontSize: 12, fontWeight: FontWeight.w400)), onPressed: () {})),
                                            crossFadeState: _isButtonGreen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                            duration: const Duration(milliseconds: 500),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Indicateur de page
                            if (isFourthImage && _isContentVisible)
                              Positioned(
                                top: 10,
                                right: 10,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 700),
                                  curve: Curves.easeInOut,
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(color: Color.fromARGB(255, 49, 198, 91), shape: BoxShape.circle),
                                  child: const Center(child: Icon(Icons.check, color: Colors.white, size: 20)),
                                ),
                              ),
                          ],
                        );
                      }),
                    );
                  }),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  // Titre
                  Text('Gérez vos réponses RSVP', textAlign: TextAlign.center, style: TextStyle(color: kBlack, fontSize: 32, fontWeight: FontWeight.w700)),

                  SizedBox(height: 12),

                  // Description
                  Text('Ajoutez vos invités et publiez votre app ! Recevez les réponses en temps réel', textAlign: TextAlign.center, style: TextStyle(color: kGrey, fontSize: 16, fontWeight: FontWeight.w400)),

                  SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
