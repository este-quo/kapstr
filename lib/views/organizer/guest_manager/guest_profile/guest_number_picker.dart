import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/helpers/sizer.dart';
import 'package:numberpicker/numberpicker.dart';

class GuestNumberPicker extends StatefulWidget {
  final int valueToUpdate;
  final String title;
  final int minValue;
  final int maxValue;

  const GuestNumberPicker({super.key, required this.valueToUpdate, required this.title, required this.minValue, required this.maxValue});

  @override
  State<GuestNumberPicker> createState() => _GuestNumberPickerState();
}

class _GuestNumberPickerState extends State<GuestNumberPicker> {
  @override
  Widget build(BuildContext context) {
    int valueToUpdate = widget.valueToUpdate;
    String title = widget.title;

    return GestureDetector(
      onTap: () {
        showDialog<int>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              surfaceTintColor: kWhite,
              backgroundColor: kWhite,
              title: Center(child: Text(title, style: Sizer(context).scaleTextStyle(Theme.of(context).textTheme.bodyLarge!).copyWith(fontWeight: FontWeight.w400, color: kYellow))),
              content: StatefulBuilder(
                builder: (context, sBsetState) {
                  return NumberPicker(
                    haptics: true,
                    selectedTextStyle: const TextStyle(color: kYellow),
                    value: valueToUpdate,
                    minValue: widget.minValue,
                    maxValue: widget.maxValue,
                    onChanged: (value) {
                      setState(() => valueToUpdate = value);
                      sBsetState(() => valueToUpdate = value);
                    },
                  );
                },
              ),
              actions: [
                TextButton(
                  child: Text("OK", style: Sizer(context).scaleTextStyle(Theme.of(context).textTheme.bodyLarge!).copyWith(fontWeight: FontWeight.w900, color: kYellow)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(title, style: Sizer(context).scaleTextStyle(Theme.of(context).textTheme.bodyLarge!).copyWith(fontWeight: FontWeight.w400, color: kYellow)),
          const SizedBox(),
          Text(valueToUpdate.toString(), style: Sizer(context).scaleTextStyle(Theme.of(context).textTheme.titleSmall!).copyWith(fontWeight: FontWeight.w900, color: kYellow)),
        ],
      ),
    );
  }
}
