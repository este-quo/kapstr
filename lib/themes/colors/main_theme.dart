import 'package:flutter/material.dart';

ThemeData mainTheme = ThemeData(
  inputDecorationTheme: const InputDecorationTheme(
    focusedBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    enabledBorder: InputBorder.none,
    hintStyle: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
    ),
  ),
  textTheme: const TextTheme().apply(
    fontFamily: 'Inter',
  ),
  primaryTextTheme: const TextTheme().apply(fontFamily: 'Inter'),
);
