import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/modules/text.dart';
import 'package:kapstr/controllers/themes.dart';
import 'package:kapstr/models/modules/text.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/guest/modules/invitation_card/display_text.dart';
import 'package:kapstr/widgets/theme/background_theme.dart';
import 'package:provider/provider.dart';

class TextGuest extends StatefulWidget {
  const TextGuest({super.key, isPreview = false});

  @override
  State<TextGuest> createState() => _TextGuestState();
}

class _TextGuestState extends State<TextGuest> {
  bool isLoading = true;

  Future<void> fetchText() async {
    await context.read<TextModuleController>().getTextById();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchText();
  }

  @override
  Widget build(BuildContext context) {
    TextModule text = context.read<TextModuleController>().currentText;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
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
            child: Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: context.read<ThemeController>().getTextColor()), Text('Retour', style: TextStyle(color: context.read<ThemeController>().getTextColor(), fontSize: 14, fontWeight: FontWeight.w500))]),
          ),
        ),
        actions: const [SizedBox(width: 91)],
      ),
      body: BackgroundTheme(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [MyDisplayText(text: text.content == "Cliquez pour éditer le texte" ? "" : text.content, styleMap: text.contentStyle)]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
