import 'package:flutter/material.dart';

Widget backgroundImageWithBlackFilter() {
  return Container(
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: AssetImage("assets/background_login.png"),
        fit: BoxFit.cover,
      ),
    ),
  );
}
