import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/buttons/ic_button.dart';

class MainButton extends StatelessWidget {
  const MainButton({super.key, this.onPressed, required this.child, this.backgroundColor = kBlack, this.width = 0, this.height = 0});

  final VoidCallback? onPressed;
  final Widget child;
  final Color backgroundColor;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final double resolvedWidth = width == 0 ? MediaQuery.of(context).size.width - 40 : width;
    final double resolvedHeight = height == 0 ? 48 : height;

    return IcButton(
      backgroundColor: backgroundColor,
      borderColor: const Color.fromARGB(30, 0, 0, 0),
      borderWidth: 1,
      radius: 8,
      height: resolvedHeight,
      width: resolvedWidth,
      onPressed: () async {
        if (onPressed != null) {
          onPressed!();
        }
      },
      child: child,
    );
  }
}
