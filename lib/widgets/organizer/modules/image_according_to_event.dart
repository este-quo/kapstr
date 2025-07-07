import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/custom_svg_picture.dart';

Widget imageAccordingToModule(String moduleType) {
  switch (moduleType) {
    case "menu":
      return Image.asset('assets/icons/menu.png', width: 24, height: 24);
    case "cagnotte":
      return const CustomAssetSvgPicture("assets/icons/redirect.svg", color: kBlack);
    case "golden_book":
      return const CustomAssetSvgPicture("assets/livre_dor_module.svg", color: kBlack);
    case "tables":
      return const CustomAssetSvgPicture("assets/tables_module.svg", color: kBlack);
    default:
      return const Icon(Icons.info_outline, color: kBlack);
  }
}
