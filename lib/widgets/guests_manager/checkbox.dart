import 'package:flutter/material.dart';
import 'package:kapstr/models/guest.dart';
import 'package:kapstr/themes/constants.dart';

class MyCheckbox extends StatelessWidget {
  final Guest guest;
  final ValueChanged<bool?> onChanged;
  final bool isSelected;

  const MyCheckbox({super.key, required this.guest, required this.onChanged, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      splashRadius: 1,
      fillColor: WidgetStateProperty.resolveWith((states) => guest.isSelected ? kYellow : kLighterGrey),
      side: const BorderSide(color: kLighterGrey),
      checkColor: kWhite,
      activeColor: kYellow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      value: guest.isSelected,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.comfortable,
      onChanged: (bool? value) {
        onChanged(value);
      },
    );
  }
}
