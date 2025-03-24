import 'package:flutter/material.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/helpers/format_colors.dart';
import 'package:kapstr/themes/constants.dart';

class FavoriteColors extends StatefulWidget {
  const FavoriteColors({super.key, required this.initialColor, required this.onColorSelected});

  final Color initialColor;
  final Function(Color) onColorSelected;

  @override
  State<FavoriteColors> createState() => _FavoriteColorsState();
}

class _FavoriteColorsState extends State<FavoriteColors> {
  late Color colorToUpdate;

  @override
  void initState() {
    super.initState();
    colorToUpdate = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    final int totalCount = Event.instance.favoriteColors.length <= 9 ? Event.instance.favoriteColors.length : 9;

    return Container(
      padding: const EdgeInsets.only(left: 0),
      height: 48,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: totalCount,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                colorToUpdate = fromHex(Event.instance.favoriteColors[index]);
              });
              widget.onColorSelected(colorToUpdate);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8.0),
              padding: const EdgeInsets.all(2),
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: fromHex(Event.instance.favoriteColors[index]), borderRadius: BorderRadius.circular(4.0), border: Border.all(color: kBorderColor, width: 1, strokeAlign: BorderSide.strokeAlignInside)),
            ),
          );
        },
      ),
    );
  }
}
