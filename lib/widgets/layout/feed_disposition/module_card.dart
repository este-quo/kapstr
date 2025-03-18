import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildModuleCard({
  required BuildContext context,
  required Color colorFilter,
  required String imageUrl,
  required String title,
  required void Function()? onTap,
  required String typographie,
  required Color textColor,
  required int fontSize,
  double? width,
  double? height,
  double borderRadius = 8,
  double imageSize = 125,
  bool isCircle = false,
  bool isSlider = false,
  Key? key,
}) {
  return GestureDetector(
    key: key,
    onTap: onTap,
    child: Container(
      width: width ?? MediaQuery.of(context).size.width - 40,
      height: height ?? (isSlider ? MediaQuery.of(context).size.height * 0.5 : 120),
      decoration: BoxDecoration(
        color: colorFilter,
        borderRadius: BorderRadius.circular(isCircle ? 1000 : borderRadius),
        border: Border.all(
          color: imageUrl.isNotEmpty ? Colors.transparent : textColor,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isCircle ? 1000 : borderRadius),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      colorFilter: colorFilter != Colors.transparent ? ColorFilter.mode(colorFilter, BlendMode.srcOver) : null,
                      fit: BoxFit.cover,
                      alignment: isCircle ? Alignment.topCenter : Alignment.center,
                    ),
                  ),
                ),
              ),
            Center(
              child: _buildDefaultContent(title, typographie, textColor, fontSize),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildDefaultContent(String title, String typographie, Color textColor, int fontSize) {
  return Center(
    child: Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.w600,
        fontSize: fontSize.toDouble(),
        fontFamily: GoogleFonts.getFont(typographie).fontFamily,
      ),
    ),
  );
}

Widget moduleCard({
  required BuildContext context,
  required Color colorFilter,
  required String imageUrl,
  required String title,
  required void Function()? onTap,
  required String typographie,
  required Color textColor,
  required int fontSize,
  Key? key,
}) {
  return buildModuleCard(
    context: context,
    colorFilter: colorFilter,
    imageUrl: imageUrl,
    title: title,
    onTap: onTap,
    typographie: typographie,
    textColor: textColor,
    fontSize: fontSize,
    key: key,
  );
}

Widget moduleCardGrid({
  required BuildContext context,
  required Color colorFilter,
  required String imageUrl,
  required String title,
  required void Function()? onTap,
  required String typographie,
  required Color textColor,
  required int textSize,
  Key? key,
}) {
  return buildModuleCard(
    context: context,
    colorFilter: colorFilter,
    imageUrl: imageUrl,
    title: title,
    onTap: onTap,
    typographie: typographie,
    textColor: textColor,
    fontSize: textSize,
    borderRadius: 12,
    key: key,
  );
}

Widget moduleCardSlider({
  required BuildContext context,
  required Color colorFilter,
  required String imageUrl,
  required int textSize,
  required String title,
  required void Function()? onTap,
  required String typographie,
  required Color textColor,
  Key? key,
}) {
  return buildModuleCard(
    context: context,
    colorFilter: colorFilter,
    imageUrl: imageUrl,
    title: title,
    onTap: onTap,
    typographie: typographie,
    textColor: textColor,
    fontSize: textSize,
    isSlider: true,
    key: key,
  );
}

Widget moduleCardCircle({
  required BuildContext context,
  required Color colorFilter,
  required String imageUrl,
  required int textSize,
  required String title,
  required void Function()? onTap,
  required String typographie,
  required Color textColor,
  Key? key,
}) {
  return buildModuleCard(
    context: context,
    colorFilter: colorFilter,
    imageUrl: imageUrl,
    title: title,
    onTap: onTap,
    typographie: typographie,
    textColor: textColor,
    fontSize: textSize,
    isCircle: true,
    key: key,
  );
}

Widget moduleCardCard({
  required BuildContext context,
  required Color colorFilter,
  required String imageUrl,
  required String title,
  required void Function()? onTap,
  required String typographie,
  required Color textColor,
  required int textSize,
  Key? key,
}) {
  return buildModuleCard(
    context: context,
    colorFilter: colorFilter,
    imageUrl: imageUrl,
    title: title,
    onTap: onTap,
    typographie: typographie,
    textColor: textColor,
    fontSize: textSize,
    borderRadius: 12,
    key: key,
  );
}
