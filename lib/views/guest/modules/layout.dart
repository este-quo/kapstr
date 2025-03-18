import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/themes.dart';
import 'package:kapstr/themes/constants.dart';

import 'package:provider/provider.dart';

class GuestModuleLayout extends StatefulWidget {
  const GuestModuleLayout({super.key, required this.child, required this.title, this.isThemeApplied = false});

  final Widget child;
  final String title;
  final bool isThemeApplied;

  @override
  State<GuestModuleLayout> createState() => _GuestModuleLayoutState();
}

class _GuestModuleLayoutState extends State<GuestModuleLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      backgroundColor:
          widget.isThemeApplied
              ? context.read<EventsController>().event.fullResThemeUrl == ""
                  ? kWhite
                  : Colors.transparent
              : kWhite,
      appBar: AppBar(
        backgroundColor: context.read<EventsController>().event.fullResThemeUrl == "" ? kWhite : Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 75,
        toolbarHeight: 40,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Row(
              children: [
                Icon(Icons.arrow_back_ios, size: 16, color: widget.isThemeApplied ? context.read<ThemeController>().getTextColor() : kBlack),
                Text('Retour', style: TextStyle(color: widget.isThemeApplied ? context.read<ThemeController>().getTextColor() : kBlack, fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text(widget.title, textAlign: TextAlign.left, style: TextStyle(fontSize: 24, color: widget.isThemeApplied ? context.read<ThemeController>().getTextColor() : kBlack, fontWeight: FontWeight.w600))),

              const SizedBox(height: 8),

              widget.child,
            ],
          ),
        ),
      ),
    );
  }
}
