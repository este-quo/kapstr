import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';

class EventDateChoice extends StatelessWidget {
  final String answer;
  final bool isSelected;
  final Function() onSelected;
  final String groupValue;

  const EventDateChoice({super.key, required this.answer, required this.isSelected, required this.onSelected, required this.groupValue});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(textAlign: TextAlign.center, answer, style: TextStyle(color: isSelected ? kPrimary : kLightGrey, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize)),
              Radio<String>(
                fillColor: isSelected ? WidgetStateProperty.all(kPrimary) : WidgetStateProperty.all(kWhite),
                activeColor: kPrimary,
                value: answer,
                groupValue: groupValue,
                onChanged: (String? value) {
                  onSelected();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
