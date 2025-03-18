import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/buttons/ic_button.dart';

class MainButton extends StatelessWidget {
  MainButton({super.key, this.onPressed, required this.child, this.backgroundColor = kBlack, this.width = 0, this.height = 0});

  final VoidCallback? onPressed;
  final Widget child;
  final Color backgroundColor;
  double width;
  double height;

  @override
  Widget build(BuildContext context) {
    if (width == 0) {
      width = MediaQuery.of(context).size.width - 40;
    } else {
      width = width;
    }

    if (height == 0) {
      height = 48;
    } else {
      height = height;
    }

    return IcButton(
      backgroundColor: backgroundColor,
      borderColor: const Color.fromARGB(30, 0, 0, 0),
      borderWidth: 1,
      radius: 8,
      height: height,
      width: width,
      onPressed: () async {
        if (onPressed != null) {
          onPressed!();
        }
      },
      child: child,
    );
  }
}
