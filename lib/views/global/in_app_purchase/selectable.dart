import 'package:flutter/material.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/themes/constants.dart';

class SelectableBox extends StatefulWidget {
  final Widget child;
  final String productId; // Unique productId for each box
  final String? selectedProductId; // Shared selected productId
  final Function(String) onChanged; // Callback when the box is selected

  const SelectableBox({super.key, required this.child, required this.productId, required this.selectedProductId, required this.onChanged});

  @override
  _SelectableBoxState createState() => _SelectableBoxState();
}

class _SelectableBoxState extends State<SelectableBox> {
  bool get isSelected => widget.productId == widget.selectedProductId;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        triggerShortVibration();
        widget.onChanged(widget.productId);
      },
      child: Container(margin: EdgeInsets.zero, height: 64, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: isSelected ? kBlack : kWhite, border: Border.all(color: kBlack, width: 1)), child: widget.child),
    );
  }
}
