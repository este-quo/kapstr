import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/models/modules/module.dart';

class CustomModuleImage extends StatefulWidget {
  final Module module;

  const CustomModuleImage({super.key, required this.module});

  @override
  State<CustomModuleImage> createState() => _CustomModuleImageState();
}

class _CustomModuleImageState extends State<CustomModuleImage> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: MediaQuery.of(context).size.width - 40,
        height: MediaQuery.of(context).size.width - 40,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: kGrey),
        child: CachedNetworkImage(imageUrl: widget.module.image, fit: BoxFit.cover, placeholder: (context, url) => Container(color: kWhite), errorWidget: (context, url, error) => Container(color: kWhite)),
      ),
    );
  }
}
