import 'package:flutter/material.dart';

Color fromHex(String hexString) {
  final buffer = StringBuffer();

  // Remove leading hash sign if it exists
  String cleanHexString = hexString.replaceFirst('#', '');

  // Ensure the string is a valid hex string
  if (!RegExp(r'^[a-fA-F0-9]+$').hasMatch(cleanHexString)) {
    throw FormatException('Invalid hexadecimal value: $hexString');
  }

  if (cleanHexString.length == 6) buffer.write('ff');
  buffer.write(cleanHexString);

  try {
    return Color(int.parse(buffer.toString(), radix: 16));
  } catch (e) {
    throw FormatException('Failed to parse color from: $hexString');
  }
}

String extractHex(String colorString) {
  final match = RegExp(r'0x[0-9a-fA-F]+').firstMatch(colorString);
  return match != null ? match.group(0) ?? '' : '';
}
