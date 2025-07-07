import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/helpers/sizer.dart';

class ConfirmationDialog extends StatelessWidget {
  final void Function() onPressed;
  final String confirmationText;
  final String cancelText;
  final String title;

  const ConfirmationDialog({super.key, required this.onPressed, required this.confirmationText, required this.cancelText, required this.title});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: kWhite,
      backgroundColor: kWhite,
      contentPadding: EdgeInsets.all(Sizer(context).getWidthSpace() / 2),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(title, textAlign: TextAlign.center, style: Sizer(context).scaleTextStyle(Theme.of(context).textTheme.bodyLarge!).copyWith(fontWeight: FontWeight.w400)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: kWhite, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text(cancelText, style: Sizer(context).scaleTextStyle(Theme.of(context).textTheme.bodyLarge!).copyWith(fontWeight: FontWeight.w400)),
                ),
                ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(backgroundColor: kDanger, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text(confirmationText, style: Sizer(context).scaleTextStyle(Theme.of(context).textTheme.bodyLarge!).copyWith(fontWeight: FontWeight.w400, color: kWhite)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
