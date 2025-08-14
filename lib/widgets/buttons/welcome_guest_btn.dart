import 'package:flutter/material.dart';

class PowerOffButton extends StatefulWidget {
  final double width;
  final double height;

  const PowerOffButton({super.key, required this.width, required this.height});

  @override
  _PowerOffButtonState createState() => _PowerOffButtonState();
}

class _PowerOffButtonState extends State<PowerOffButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_animationController.isDismissed) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        width: _animationController.value * widget.width,
        height: widget.height,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(widget.height / 2), color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.5), blurRadius: 5, spreadRadius: 1)]),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: _animationController.value * widget.width / 2,
              child: Container(width: widget.height * 0.8, height: widget.height * 0.8, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: Colors.grey, width: 1.5)), child: Icon(Icons.power_settings_new, size: widget.height * 0.4, color: Colors.grey)),
            ),
            Positioned(
              right: _animationController.value * widget.width / 2,
              child: Container(width: widget.height * 0.8, height: widget.height * 0.8, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: Colors.grey, width: 1.5)), child: Icon(Icons.flashlight_off, size: widget.height * 0.4, color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}
