import 'package:flutter/material.dart';
import 'package:kapstr/helpers/sizer.dart';
import 'package:kapstr/helpers/debug_helper.dart';

class IcButton extends StatelessWidget {
  final EdgeInsets? padding;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? disabledBorderColor;
  final Color? disabledBackgroundColor;
  final bool? isDisabled;
  final double? borderWidth;
  final double? height;
  final double? width;
  final VoidCallback? onPressed;
  final Widget? child;
  final String? text;
  final bool isTransparent;
  final TextStyle? style;
  final Color? textColor;
  final double? radius;
  final bool? isWidthAutoScaled;
  final bool? isHeightAutoScaled;
  final bool hasUnderline;
  final bool doSomethingWhenDisabled;

  const IcButton({
    this.padding,
    this.borderColor,
    this.backgroundColor,
    this.borderWidth,
    this.width,
    this.height,
    this.onPressed,
    this.child,
    this.text,
    this.isTransparent = false,
    this.style,
    this.textColor,
    this.disabledBackgroundColor,
    this.disabledBorderColor,
    this.isDisabled,
    this.radius,
    this.isWidthAutoScaled,
    this.isHeightAutoScaled,
    this.hasUnderline = false,
    this.doSomethingWhenDisabled = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    EdgeInsets? padding = this.padding ?? EdgeInsets.zero;

    // verification of the widget's validity
    // if the width is defined, it cannot be auto scaled
    if (this.isWidthAutoScaled != null && this.width != null) {
      throw ('IcButton cannot have the isWidthAutoScaled'
          ' and width property at the same time');
    }

    // we only want to display a text or a widget
    if (this.child != null && text != null) {
      throw ('IcButton cannot have the child'
          ' and text property at the same time');
    }

    // all colors are overwritten if isTransparent is true
    if (isTransparent == true && (this.backgroundColor != null || this.borderColor != null || this.disabledBackgroundColor != null || this.disabledBorderColor != null)) {
      printOnDebug(
        'IcButton Warning : colors will be overwritten by'
        ' the isTransparent property',
      );
    }

    bool? isDisabled = this.isDisabled ?? false;

    bool isWidthAutoScaled = this.isWidthAutoScaled ?? false;
    double? width = this.width ?? double.infinity;

    if (isWidthAutoScaled) {
      width = null;
    }

    Color textColor = this.textColor ?? Theme.of(context).colorScheme.background;

    Widget? child;
    if (this.child != null) child = this.child;
    if (text != null) {
      child = Text(text!, style: style ?? Sizer(context).scaleTextStyle(Theme.of(context).textTheme.bodyLarge!).copyWith(color: textColor, decoration: hasUnderline ? TextDecoration.underline : null));

      if (isWidthAutoScaled) {
        Widget childText = Row(mainAxisSize: MainAxisSize.min, children: [_widthPadding(context), Flexible(child: child), _widthPadding(context)]);
        child = childText;
      }
    }

    // init colors
    Color? borderColor = this.borderColor ?? Colors.transparent;
    Color? disabledBorderColor = this.disabledBorderColor ?? Theme.of(context).disabledColor;
    Color? backgroundColor = this.backgroundColor ?? Theme.of(context).colorScheme.background;
    Color? disabledBackgroundColor = this.disabledBackgroundColor ?? Theme.of(context).disabledColor;

    if (isTransparent) {
      backgroundColor = Colors.transparent;
      borderColor = Colors.transparent;
      disabledBackgroundColor = Colors.transparent;
      disabledBackgroundColor = Colors.transparent;
    }

    bool isHeightAutoScaled = this.isHeightAutoScaled ?? false;

    double? height;
    if (!isHeightAutoScaled) {
      height = this.height ?? Sizer(context).getAlphaButtonHeight();
    }

    Widget button = InkWell(
      onTap: (!isDisabled || (isDisabled && doSomethingWhenDisabled)) ? onPressed : _doNothing,
      splashColor: Colors.transparent,
      splashFactory: InkSplash.splashFactory,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
        padding: padding,
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: radius != null ? BorderRadius.circular(radius!) : BorderRadius.circular(100),
          border: Border.all(color: isDisabled ? disabledBorderColor : borderColor, width: borderWidth ?? Sizer(context).getLineWidth() * 0.5, strokeAlign: BorderSide.strokeAlignOutside),
          color: isDisabled ? disabledBackgroundColor : backgroundColor,
        ),
        child: Center(child: child),
      ),
    );

    if (isWidthAutoScaled) {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [button]);
    }

    return button;
  }

  _widthPadding(BuildContext context) {
    return SizedBox(width: Sizer(context).getWidthSpace());
  }

  _doNothing() {
    printOnDebug("Button is disabled");
  }
}
