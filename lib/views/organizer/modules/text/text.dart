import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/modules/text.dart';
import 'package:kapstr/controllers/themes.dart';
import 'package:kapstr/models/modules/text.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/organizer/modules/invitation_card/editable_text.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:kapstr/widgets/theme/background_theme.dart';
import 'package:provider/provider.dart';

class TextPreview extends StatefulWidget {
  const TextPreview({super.key});

  @override
  State<TextPreview> createState() => _TextPreviewState();
}

class _TextPreviewState extends State<TextPreview> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchText();
  }

  Future<void> fetchText() async {
    await context.read<TextModuleController>().getTextById();
    setState(() {
      isLoading = false;
    });
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
      ),
      body: BackgroundTheme(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child:
                    !isLoading
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            MyEditableText(
                              initialText: text.content,
                              onConfirmation: (value, map) async {
                                text.content = value;
                                await context.read<TextModuleController>().updateStyleMap('contentStyle', map);
                              },
                              styleMap: text.contentStyle,
                            ),
                          ],
                        )
                        : const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
