import 'package:flutter/material.dart';

enum PhoneType { small, medium, large, extraLarge }

class Sizer {
  final BuildContext context;

  Sizer(this.context);

  TextStyle scaleTextStyle(TextStyle textStyle) {
    double fontSize = _getScalablePixel(textStyle.fontSize!);

    return textStyle.copyWith(
      fontSize: fontSize,
    );
  }

  double _getScalablePixel(double fontSize) {
    double h = fontSize * MediaQuery.of(context).size.height / 100;
    double w = fontSize * MediaQuery.of(context).size.width / 100;

    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    BoxConstraints constraints =
        BoxConstraints(maxHeight: MediaQuery.of(context).size.height, maxWidth: MediaQuery.of(context).size.width);

    double aspectRatio = constraints
        .constrainDimensions(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height)
        .aspectRatio;

    double factor = ((((h + w) + (pixelRatio * aspectRatio)) / 2.08) / 100);
    return factor * fontSize * _getTextRatio();
  }

  double getCustomHeight(double height) {
    return height * (MediaQuery.of(context).size.height / 100) * _getRatio();
  }

  double getCustomWidth(double width) {
    return width * (MediaQuery.of(context).size.width / 100) * _getRatio();
  }

  double getPadding() {
    return 4 * (MediaQuery.of(context).size.height / 100) * _getRatio();
  }

  double getTextPadding() {
    return 10 * (MediaQuery.of(context).size.width / 100) * _getRatio();
  }

  double getWidgetHeight() {
    return 8 * (MediaQuery.of(context).size.height / 100) * _getRatio();
  }

  double getOptInButtonHeight() {
    return 6 * (MediaQuery.of(context).size.height / 100) * _getRatio();
  }

  double getIconButtonHeight() {
    return 4 * (MediaQuery.of(context).size.height / 100) * _getRatio();
  }

  double getRadius() {
    return 2.5 * (MediaQuery.of(context).size.height / 100) * _getRatio();
  }

  double getBlyyndButtonRadius() {
    return 3.5 * (MediaQuery.of(context).size.height / 100) * _getRatio();
  }

  double getLineWidth() {
    return 0.35 * (MediaQuery.of(context).size.height / 100) * _getRatio();
  }

  double getSpace() {
    return 3 * (MediaQuery.of(context).size.height / 100) * _getRatio();
  }

  double getSmallSpace() {
    return 0.9 * (MediaQuery.of(context).size.height / 100) * _getRatio();
  }

  EdgeInsets getSignInTextEdges() {
    return EdgeInsets.symmetric(
        vertical: getPadding() / 1.35 * _getRatio(), horizontal: getTextPadding() * _getRatio());
  }

  EdgeInsets getTextEdges() {
    return EdgeInsets.symmetric(vertical: getPadding() / 1.35 * _getRatio(), horizontal: getTextWidthEdges());
  }

  double getTextHeightEdges() {
    return 1.75 * (MediaQuery.of(context).size.height / 100) * _getRatio();
  }

  double getTextWidthEdges() {
    return getTextPadding() / 1.6 * _getRatio();
  }

  TextStyle getMixedBodyTextStyle() {
    return scaleTextStyle(Theme.of(context).textTheme.bodyLarge!)
        .copyWith(fontWeight: Theme.of(context).textTheme.bodyMedium!.fontWeight);
  }

  double getGridSpacing() {
    return 0.3 * (MediaQuery.of(context).size.height / 100) * _getRatio();
  }

  double getWidthSpace() {
    return 6 * (MediaQuery.of(context).size.width / 100) * _getRatio();
  }

  double getCardHeightRatio() {
    return 0.66;
  }

  double getCreateAccountBottomPadding() {
    return 1.2 * getSpace();
  }

  double _getTextRatio() {
    PhoneType phoneType = PhoneType.medium;
    double ratio = 1;

    var pixelRatio = View.of(context).devicePixelRatio;

    //Size in logical pixels
    var logicalScreenSize = View.of(context).physicalSize / pixelRatio;
    var logicalHeight = logicalScreenSize.height;

    if (logicalHeight > 800) {
      phoneType = PhoneType.large;
    }

    switch (phoneType) {
      case PhoneType.small:
      case PhoneType.medium:
        ratio = 1.05;
        break;
      case PhoneType.large:
      case PhoneType.extraLarge:
        ratio = 0.95;
        break;
    }

    return ratio;
  }

  EdgeInsets getBlyyndButtonPadding() {
    return EdgeInsets.symmetric(vertical: getTextHeightEdges(), horizontal: getTextWidthEdges());
  }

  double getAlphaButtonHeight() {
    return 7 * (MediaQuery.of(context).size.height / 100) * _getRatio();
  }

  double _getRatio() {
    PhoneType phoneType = PhoneType.medium;
    double ratio = 1;

    var pixelRatio = View.of(context).devicePixelRatio;

    //Size in logical pixels
    var logicalScreenSize = View.of(context).physicalSize / pixelRatio;
    var logicalHeight = logicalScreenSize.height;

    if (logicalHeight > 800) {
      phoneType = PhoneType.large;
    }

    switch (phoneType) {
      case PhoneType.small:
      case PhoneType.medium:
        ratio = 1;
        break;
      case PhoneType.large:
      case PhoneType.extraLarge:
        ratio = 0.8;
        break;
    }

    return ratio;
  }
}
