import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAssetSvgPicture extends StatelessWidget {
  final String assetPath;
  final Color? color;
  final BlendMode? blendMode;
  final double? height;
  final double? width;
  final BoxFit? fit;

  const CustomAssetSvgPicture(
    this.assetPath, {
    this.color,
    this.blendMode,
    this.height,
    this.width,
    this.fit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    BlendMode blendMode = this.blendMode ?? BlendMode.srcIn;

    ColorFilter? colorFilter;
    if (color != null) {
      colorFilter = ColorFilter.mode(color!, blendMode);
    }

    return SvgPicture.asset(
      assetPath,
      colorFilter: colorFilter,
      height: height,
      width: width,
      fit: fit ?? BoxFit.contain,
    );
  }
}
