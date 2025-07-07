import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/helpers/sizer.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/widgets/layout/back_arrow_btn.dart';
import 'package:kapstr/widgets/layout/spacing.dart';
import 'package:kapstr/widgets/taglines/tagline.dart';

class CustomModuleHeader extends StatelessWidget {
  final Module module;
  const CustomModuleHeader({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        xLargeSpacerH(),
        Container(
          margin: EdgeInsets.all(Sizer(context).getWidthSpace()),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const BackArrowButton(), Tagline(upText: 'Complétez', downText: 'votre ${module.name}', color: kBlack), SizedBox(width: Sizer(context).getWidthSpace())]),
        ),
      ],
    );
  }
}
