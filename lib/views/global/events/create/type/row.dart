import 'package:flutter/material.dart';
import 'package:kapstr/helpers/event_type.dart';
import 'package:kapstr/widgets/layout/get_device_type.dart';
import 'package:kapstr/widgets/layout/spacing.dart';
import 'package:kapstr/themes/constants.dart';

class TypeRow extends StatelessWidget {
  final String title;
  final EventTypes type;
  final String shortName;
  final bool isNotAvailableYet;
  final VoidCallback onSelected;
  final bool isSelected;

  const TypeRow({super.key, required this.title, required this.type, required this.shortName, this.isNotAvailableYet = false, required this.onSelected, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    // Define common styles with conditional adjustments for non-available items
    final borderColor = kBlack.withValues(alpha: 0.3);
    // Adjust text color based on isNotAvailableYet
    final textColor = isNotAvailableYet ? Colors.grey : (isSelected ? kWhite : kBlack);
    final backgroundColor = isSelected && !isNotAvailableYet ? kBlack : kWhite;

    return TextButton(
      style: ButtonStyle(overlayColor: WidgetStateProperty.all(Colors.transparent)),
      onPressed: isNotAvailableYet ? null : () => onSelected(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: 64,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: backgroundColor, border: Border.all(width: 1, color: borderColor)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(title, textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w400)), smallSpacerH(context), _buildSelectionIndicator(isSelected && !isNotAvailableYet, borderColor, context)],
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator(bool isSelected, Color borderColor, BuildContext context) {
    final indicatorSize = getDeviceType(context) == 'phone' ? 20.0 : 24.0;
    return Container(
      width: indicatorSize,
      height: indicatorSize,
      decoration: BoxDecoration(shape: BoxShape.circle, color: kWhite, border: Border.all(width: 1, color: borderColor)),
      child: isSelected ? Container(margin: const EdgeInsets.all(5), decoration: const BoxDecoration(shape: BoxShape.circle, color: kBlack)) : Container(),
    );
  }
}
