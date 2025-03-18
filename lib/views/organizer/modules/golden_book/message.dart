import 'package:flutter/material.dart';
import 'package:kapstr/controllers/themes.dart';
import 'package:kapstr/models/guest.dart';
import 'package:kapstr/models/modules/golden_book_message.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/organizer/modules/golden_book/card.dart';
import 'package:kapstr/widgets/theme/background_theme.dart';
import 'package:provider/provider.dart';

class GuestMessage extends StatelessWidget {
  const GuestMessage({super.key, required this.moduleId, required this.message, required this.guest});

  final String moduleId;
  final GoldenBookMessage message;
  final Guest guest;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 75,
        toolbarHeight: 40,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: context.read<ThemeController>().getTextColor()), Text('Retour', style: TextStyle(color: context.read<ThemeController>().getTextColor(), fontSize: 14, fontWeight: FontWeight.w500))]),
          ),
        ),
        actions: const [SizedBox(width: 91)],
      ),
      body: BackgroundTheme(
        child: SafeArea(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text('Livre d\'or', textAlign: TextAlign.left, style: TextStyle(fontSize: 24, color: context.read<ThemeController>().getTextColor(), fontWeight: FontWeight.w600)),

                    // Message
                    SizedBox(height: MediaQuery.of(context).size.height * 0.6, child: MessageCard(moduleId: moduleId, message: message)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
