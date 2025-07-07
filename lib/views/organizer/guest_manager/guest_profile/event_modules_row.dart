import 'package:flutter/material.dart';
import 'package:kapstr/helpers/sizer.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/themes/constants.dart';

class EventModulesRow extends StatelessWidget {
  final List<Module> modulesAllowingGuests;
  final void Function()? onTap;
  final Color textColor;
  final Color backgroundColor;
  final String moduleName;

  const EventModulesRow({super.key, required this.modulesAllowingGuests, this.onTap, required this.textColor, required this.backgroundColor, required this.moduleName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: Sizer(context).getWidthSpace() / 3, vertical: Sizer(context).getWidthSpace() / 3),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), border: Border.all(color: kYellow), color: backgroundColor),
        child: Center(child: Text(moduleName, style: Sizer(context).scaleTextStyle(Theme.of(context).textTheme.bodyLarge!).copyWith(fontWeight: FontWeight.w400, color: textColor))),
      ),
    );
  }
}
