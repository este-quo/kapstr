import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/themes/colors/main_theme.dart';

ThemeData lightTheme = mainTheme.copyWith(
  scaffoldBackgroundColor: kWhite,
  splashColor: kLighterGrey.withValues(alpha: 0.5),
  disabledColor: kLighterGrey,
  primaryColor: kYellow,
  colorScheme: const ColorScheme.highContrastLight(surface: Colors.white, secondary: kBlack, error: Color(0xFFC30052)),
  inputDecorationTheme: mainTheme.inputDecorationTheme.copyWith(hintStyle: mainTheme.inputDecorationTheme.hintStyle!.copyWith(color: Colors.black.withValues(alpha: 0.5))),
  textTheme: mainTheme.textTheme.copyWith(
    titleLarge: mainTheme.textTheme.titleLarge!.copyWith(color: kBlack, fontWeight: FontWeight.w500),
    titleMedium: mainTheme.textTheme.titleMedium!.copyWith(color: kBlack, fontWeight: FontWeight.w500),
    titleSmall: mainTheme.textTheme.titleSmall!.copyWith(color: kBlack, fontWeight: FontWeight.w500),
    bodyLarge: mainTheme.textTheme.bodyLarge!.copyWith(color: kBlack),
    bodyMedium: mainTheme.textTheme.bodyMedium!.copyWith(color: kBlack, fontWeight: FontWeight.w500),
    bodySmall: mainTheme.textTheme.bodySmall!.copyWith(color: kBlack, fontWeight: FontWeight.w500),
    labelSmall: mainTheme.textTheme.labelSmall!.copyWith(color: kBlack, fontWeight: FontWeight.w500),
  ),
  primaryTextTheme: mainTheme.primaryTextTheme,
);
