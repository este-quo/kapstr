import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:numberpicker/numberpicker.dart';

class PreciseDatePicker extends StatelessWidget {
  final int selectedDay;
  final int selectedMonth;
  final int selectedYear;
  final Function(int) onDayChanged;
  final Function(int) onMonthChanged;
  final Function(int) onYearChanged;

  const PreciseDatePicker({super.key, required this.selectedDay, required this.selectedMonth, required this.selectedYear, required this.onDayChanged, required this.onMonthChanged, required this.onYearChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NumberPicker(
              haptics: true,
              itemWidth: 48,
              textStyle: TextStyle(color: kLightWhiteTransparent2, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize),
              selectedTextStyle: TextStyle(color: kWhite, fontSize: Theme.of(context).textTheme.titleMedium!.fontSize),
              value: selectedDay,
              minValue: 1,
              maxValue: 31,
              onChanged: onDayChanged,
            ),
            const SizedBox(height: 24, width: 24, child: VerticalDivider(thickness: 1, color: kWhite)),
            NumberPicker(
              haptics: true,
              itemWidth: 48,
              textStyle: TextStyle(color: kLightWhiteTransparent2, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize),
              selectedTextStyle: TextStyle(color: kWhite, fontSize: Theme.of(context).textTheme.titleMedium!.fontSize),
              value: selectedMonth,
              minValue: 1,
              maxValue: 12,
              onChanged: onMonthChanged,
            ),
            const SizedBox(height: 24, width: 24, child: VerticalDivider(thickness: 1, color: kWhite)),
            NumberPicker(
              haptics: true,
              itemWidth: 48,
              textStyle: TextStyle(color: kLightWhiteTransparent2, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize),
              selectedTextStyle: TextStyle(color: kWhite, fontSize: Theme.of(context).textTheme.titleMedium!.fontSize),
              value: selectedYear,
              minValue: DateTime.now().year,
              maxValue: DateTime.now().year + 5,
              onChanged: onYearChanged,
            ),
          ],
        ),
      ],
    );
  }
}
