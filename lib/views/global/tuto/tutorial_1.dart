import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/global/tuto/animated_image_filter.dart';

class TutorialOne extends StatefulWidget {
  const TutorialOne({super.key});

  @override
  State<TutorialOne> createState() => _TutorialOneState();
}

class _TutorialOneState extends State<TutorialOne> {
  final List<Map<String, String>> imageData = [
    {'image': 'assets/goldenbook.png', 'text': "Livre d'or"},
    {'image': 'assets/mairie.png', 'text': "Mairie"},
    {'image': 'assets/tables.png', 'text': 'Tables'},
    {'image': 'assets/card.png', 'text': 'Carte'},
    {'image': 'assets/menu.png', 'text': 'Menu'},
    {'image': 'assets/album.png', 'text': 'Album Photo'},
    {'image': 'assets/video.png', 'text': 'Vidéo'},
    {'image': 'assets/wedding.png', 'text': 'Mariage'},
    {'image': 'assets/cagnotte.png', 'text': 'Cagnotte'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.5,
              child: OverflowBox(
                alignment: Alignment.bottomCenter,
                minHeight: MediaQuery.of(context).size.height * 0.5 + 60,
                minWidth: MediaQuery.of(context).size.width + 90,
                maxWidth: MediaQuery.of(context).size.width + 90,
                maxHeight: MediaQuery.of(context).size.height * 0.5 + 60,
                child: GridView.builder(
                  padding: const EdgeInsets.only(top: 30, left: 15, right: 15),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1, mainAxisSpacing: 10, crossAxisSpacing: 10),
                  itemCount: imageData.length,
                  itemBuilder: (context, index) {
                    final item = imageData[index];
                    return AnimatedImageFilter(imagePath: item['image']!, text: item['text']!);
                  },
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Rest of your widget tree
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text('Créez votre', textAlign: TextAlign.center, style: TextStyle(color: kBlack, fontSize: 32, fontWeight: FontWeight.w700)),
                  Text('faire-part mobile', textAlign: TextAlign.center, style: TextStyle(color: kBlack, fontSize: 32, fontWeight: FontWeight.w700)),
                  SizedBox(height: 12),
                  Text('Customisez votre application en ajoutant les modules pertinents pour votre mariage', textAlign: TextAlign.center, style: TextStyle(color: kGrey, fontSize: 16, fontWeight: FontWeight.w400)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
