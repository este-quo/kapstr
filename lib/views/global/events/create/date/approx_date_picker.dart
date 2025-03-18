import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:numberpicker/numberpicker.dart';

class ApproxDatePicker extends StatelessWidget {
  final int selectedApproxDay;
  final int selectedApproxPeriod;
  final Function(int) onApproxDayChanged;
  final Function(int) onApproxPeriodChanged;
  final List<String> periodItems;

  const ApproxDatePicker({super.key, required this.selectedApproxDay, required this.selectedApproxPeriod, required this.onApproxDayChanged, required this.onApproxPeriodChanged, required this.periodItems});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NumberPicker(
              haptics: true,
              itemWidth: 32,
              textStyle: TextStyle(color: kLightWhiteTransparent2, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize),
              selectedTextStyle: TextStyle(color: kWhite, fontSize: Theme.of(context).textTheme.titleMedium!.fontSize),
              value: selectedApproxDay,
              minValue: 1,
              maxValue: 31,
              onChanged: onApproxDayChanged,
            ),
            const SizedBox(height: 24, width: 24, child: VerticalDivider(thickness: 1, color: kWhite)),
            NumberPicker(
              haptics: true,
              textMapper: (index) {
                return periodItems[int.parse(index) - 1];
              },
              itemWidth: 75,
              textStyle: TextStyle(color: kLightWhiteTransparent2, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize),
              selectedTextStyle: TextStyle(color: kWhite, fontSize: Theme.of(context).textTheme.titleMedium!.fontSize),
              value: selectedApproxPeriod,
              minValue: 1,
              maxValue: 3,
              onChanged: onApproxPeriodChanged,
            ),
          ],
        ),
      ],
    );
  }
}
