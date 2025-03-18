import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/helpers/sizer.dart';

class TypeOfGuestRow extends StatefulWidget {
  final List<dynamic> guestTypeOfGuest;

  const TypeOfGuestRow({super.key, required this.guestTypeOfGuest});

  @override
  State<TypeOfGuestRow> createState() => _TypeOfGuestRowState();
}

class _TypeOfGuestRowState extends State<TypeOfGuestRow> {
  @override
  Widget build(BuildContext context) {
    List<dynamic> typeOfGuests = widget.guestTypeOfGuest;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:
          allTypeOfGuests.asMap().entries.map((answer) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (typeOfGuests.contains(answer.value)) {
                    typeOfGuests.remove(answer.value);
                  } else {
                    typeOfGuests.add(answer.value);
                  }
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6 / invitationAnswers.length,
                height: Sizer(context).getWidgetHeight(),
                decoration: BoxDecoration(color: typeOfGuests.contains(answer.value) ? kYellow : Colors.transparent, border: Border.all(color: kYellow), borderRadius: BorderRadius.circular(Sizer(context).getRadius())),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Sizer(context).getRadius()),
                  child: Center(child: Text(answer.value, style: Sizer(context).scaleTextStyle(Theme.of(context).textTheme.bodyLarge!).copyWith(fontWeight: FontWeight.w400, color: typeOfGuests.contains(answer.value) ? kWhite : kYellow))),
                ),
              ),
            );
          }).toList(),
    );
  }
}
