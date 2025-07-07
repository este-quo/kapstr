import 'package:flutter/material.dart';
import 'package:kapstr/helpers/event_type.dart';
import 'package:kapstr/widgets/buttons/ic_button.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/logo_loader.dart';

class OnBoardingLayout extends StatefulWidget {
  const OnBoardingLayout({super.key, required this.children, required this.confirm, required this.title});
  final String title;
  final List<Widget> children;
  final Future<void> Function() confirm;
  @override
  OnBoardingLayoutState createState() => OnBoardingLayoutState();
}

class OnBoardingLayoutState extends State<OnBoardingLayout> {
  EventTypes? selected;
  bool isLoading = false; // Loading state variable

  void confirmWithLoading() async {
    setState(() => isLoading = true);

    await widget.confirm(); // Use await here

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
        elevation: 0,
        centerTitle: true,
        title: Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: kBlack)),
        leading: const SizedBox(),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: kBlack),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      floatingActionButton:
          MediaQuery.of(context).viewInsets.bottom == 0
              ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: IcButton(
                  borderColor: const Color.fromARGB(30, 0, 0, 0),
                  borderWidth: 1,
                  height: 48,
                  radius: 8,
                  onPressed: isLoading ? null : confirmWithLoading,
                  backgroundColor: kBlack,
                  child: isLoading ? const PulsatingLogo(svgPath: 'assets/icons/app/svg_dark.svg', size: 24) : const Text('Suivant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: kWhite)),
                ),
              )
              : null,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: const BoxDecoration(color: kWhite),
        child: SingleChildScrollView(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), physics: const BouncingScrollPhysics(), child: Column(children: widget.children)),
      ),
    );
  }
}
