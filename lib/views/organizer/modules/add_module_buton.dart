import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kapstr/themes/constants.dart';

class AddModuleButton extends StatefulWidget {
  final BuildContext context;
  final Color colorFilter;
  final String? imageUrl;
  final String title;
  final void Function()? onTap;
  final String typographie;
  final Color textColor;
  final int fontSize;
  final Widget icon;
  final bool isLoading;

  const AddModuleButton({super.key, required this.context, required this.colorFilter, this.imageUrl, required this.title, required this.onTap, required this.typographie, required this.textColor, required this.fontSize, required this.icon, required this.isLoading});

  @override
  State<AddModuleButton> createState() => _AddModuleButtonState();
}

class _AddModuleButtonState extends State<AddModuleButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          key: widget.key,
          onTap: widget.onTap,
          child: Container(
            width: MediaQuery.of(context).size.width - 40,
            height: 64,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: kBlack.withValues(alpha: 0.2), width: 1, strokeAlign: BorderSide.strokeAlignOutside)),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    SizedBox(width: 24, height: 24, child: widget.icon),
                    const SizedBox(width: 20),
                    Row(
                      children: [
                        Text(textAlign: TextAlign.center, widget.title, style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w500, fontSize: widget.fontSize.toDouble(), fontFamily: widget.typographie == '' ? 'Inter' : GoogleFonts.getFont(widget.typographie).fontFamily)),
                        if (widget.title == 'Lien externe') Text(" (cagnotte, site, ...)", style: TextStyle(color: kGrey, fontWeight: FontWeight.w400, fontSize: widget.fontSize.toDouble(), fontFamily: widget.typographie == '' ? 'Inter' : GoogleFonts.getFont(widget.typographie).fontFamily)),
                        if (widget.title == 'Média') Text(" (pdf, photo)", style: TextStyle(color: kGrey, fontWeight: FontWeight.w400, fontSize: widget.fontSize.toDouble(), fontFamily: widget.typographie == '' ? 'Inter' : GoogleFonts.getFont(widget.typographie).fontFamily)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
