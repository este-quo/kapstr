import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PulsatingLogo extends StatefulWidget {
  final String svgPath;
  final double size;

  const PulsatingLogo({required this.svgPath, this.size = 100.0, super.key});

  @override
  _PulsatingLogoState createState() => _PulsatingLogoState();
}

class _PulsatingLogoState extends State<PulsatingLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 1), vsync: this)..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(scale: _animation.value, child: SvgPicture.asset(widget.svgPath, width: widget.size, height: widget.size));
      },
    );
  }
}
