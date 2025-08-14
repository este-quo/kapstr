import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedImageFilter extends StatefulWidget {
  final String imagePath;
  final String text;
  const AnimatedImageFilter({super.key, required this.imagePath, required this.text});

  @override
  _AnimatedImageFilterState createState() => _AnimatedImageFilterState();
}

class _AnimatedImageFilterState extends State<AnimatedImageFilter> {
  late Color filterColor; // Utilisation de late pour initialisation différée
  late Color previousColor; // Utilisation de late pour initialisation différée

  final List<Color> colors = [Color(0x00FFFFFF), Color(0x992036A0), Color(0x99E78F40), Color(0x996172C2), Color(0x99095A6A), Color(0x99D3705C), Color(0x9953B9CD), Color(0x993D104E), Color(0x99D3B81A), Color(0x99B29500)];

  Timer? colorChangeTimer;

  @override
  void initState() {
    super.initState();
    // Initialisation des couleurs avec une valeur aléatoire dès le départ
    final randomIndex = Random().nextInt(colors.length);
    filterColor = colors[randomIndex];
    previousColor = filterColor; // La couleur précédente peut être la même au début
    changeFilterColor();
  }

  void changeFilterColor() {
    colorChangeTimer = Timer.periodic(Duration(milliseconds: 750), (timer) {
      final randomIndex = Random().nextInt(colors.length);
      setState(() {
        previousColor = filterColor;
        filterColor = colors[randomIndex];
      });
    });
  }

  @override
  void dispose() {
    colorChangeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(begin: previousColor, end: filterColor),
      duration: Duration(seconds: 3),
      builder: (context, Color? color, child) {
        return Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), image: DecorationImage(image: AssetImage(widget.imagePath), colorFilter: ColorFilter.mode(color!, BlendMode.srcOver), fit: BoxFit.cover)),
          child: Center(child: Text(widget.text, style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w400, fontFamily: GoogleFonts.getFont('Great Vibes').fontFamily))),
        );
      },
    );
  }
}
