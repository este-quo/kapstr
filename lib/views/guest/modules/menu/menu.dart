import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/modules/menu.dart';
import 'package:kapstr/controllers/themes.dart';
import 'package:kapstr/models/modules/menu.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/guest/modules/invitation_card/display_text.dart';
import 'package:kapstr/widgets/theme/background_theme.dart';
import 'package:provider/provider.dart';

class MenuGuest extends StatefulWidget {
  const MenuGuest({super.key, isPreview = false});

  @override
  State<MenuGuest> createState() => _MenuGuestState();
}

class _MenuGuestState extends State<MenuGuest> {
  bool isLoading = true;

  Future<void> fetchMenu() async {
    await context.read<MenuModuleController>().getMenuById();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchMenu();
  }

  @override
  Widget build(BuildContext context) {
    MenuModule menu = context.read<MenuModuleController>().currentMenu;

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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyDisplayText(text: menu.title, styleMap: menu.titleStyle),
                    const SizedBox(height: 24),
                    MyDisplayText(text: menu.entry, styleMap: menu.entryStyle),
                    const SizedBox(height: 8),
                    MyDisplayText(text: menu.entryContent, styleMap: menu.entryContentStyle),
                    const SizedBox(height: 24),
                    MyDisplayText(text: menu.mainCourse, styleMap: menu.mainCourseStyle),
                    const SizedBox(height: 8),
                    MyDisplayText(text: menu.mainCourseContent, styleMap: menu.mainCourseContentStyle),
                    const SizedBox(height: 24),
                    MyDisplayText(text: menu.dessert, styleMap: menu.dessertStyle),
                    const SizedBox(height: 8),
                    MyDisplayText(text: menu.dessertContent, styleMap: menu.dessertContentStyle),
                    const SizedBox(height: 24),
                    MyDisplayText(text: menu.names, styleMap: menu.namesStyles),
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
