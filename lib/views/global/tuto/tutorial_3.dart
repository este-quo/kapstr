import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';

class TutorialThree extends StatefulWidget {
  const TutorialThree({super.key});

  @override
  State<TutorialThree> createState() => _TutorialThreeState();
}

class _TutorialThreeState extends State<TutorialThree> {
  final List<double> _opacities = List.filled(6, 0.0);

  @override
  void initState() {
    super.initState();

    _animateImages();
  }

  void _animateImages() {
    // Example sequence - customize based on your needs
    // This example will make the first image appear, then the second and third together, and so on.
    var sequence = [
      [3],
      [1, 5],
      [0, 4],
      [2],
    ];

    var delay = Duration(seconds: 0); // Initial delay

    for (var group in sequence) {
      Future.delayed(delay, () {
        if (!mounted) return;
        setState(() {
          for (var index in group) {
            _opacities[index] = 1.0; // Make the image(s) fully visible
          }
        });
      });
      delay += Duration(seconds: 1); // Increment delay for the next group
    }
  }

  @override
  void dispose() {
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
                        // Inverser la taille des images uniquement pour la colonne du milieu (index 1)
                        double heightFraction =
                            columnIndex == 1
                                ? (index == 0 ? 0.45 : 0.55) // Inverser pour la colonne du milieu
                                : (index == 0 ? 0.55 : 0.45); // Taille normale pour les autres colonnes

                        return AnimatedOpacity(
                          opacity: _opacities[imageIndex],
                          duration: Duration(seconds: 1),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: AssetImage('assets/image${imageIndex + 1}.png'), // Assurez-vous que les noms des assets correspondent à vos images.
                                fit: BoxFit.cover,
                              ),
                            ),
                            width: (MediaQuery.of(context).size.width + 74) / 3, // Correction pour l'espacement et la largeur correcte
                            height: ((MediaQuery.of(context).size.height * 0.5) + 52) * heightFraction, // Utilisez heightFraction pour déterminer la hauteur
                          ),
                        );
                      }),
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 48),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  // Titre
                  Text('Capturez vos moments', textAlign: TextAlign.center, style: TextStyle(color: kBlack, fontSize: 32, fontWeight: FontWeight.w700)),

                  SizedBox(height: 12),

                  // Description
                  Text('Partagez des photos avec vos invités sur le mur social de l’évènement ', textAlign: TextAlign.center, style: TextStyle(color: kGrey, fontSize: 16, fontWeight: FontWeight.w400)),

                  SizedBox(height: 24),

                  SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
