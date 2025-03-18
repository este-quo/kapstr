import 'package:flutter/material.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/global/events/events.dart';
import 'package:kapstr/views/global/tuto/tutorial_1.dart';
import 'package:kapstr/views/global/tuto/tutorial_2.dart';
import 'package:kapstr/views/global/tuto/tutorial_3.dart';
import 'package:kapstr/views/global/tuto/tutorial_4.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Tutorial extends StatefulWidget {
  const Tutorial({super.key});

  @override
  State<Tutorial> createState() => _TutorialState();
}

class _TutorialState extends State<Tutorial> {
  PageController controller = PageController();
  int currentPage = 0; // Add this line to track the current page index

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      floatingActionButton: MainButton(
        onPressed: () async {
          triggerShortVibration();
          if (currentPage == 3) {
            // Use currentPage to check the condition

            await context.read<UsersController>().updateUserFields({'onboardingComplete': true});

            printOnDebug(context.read<UsersController>().user!.onboardingComplete.toString());

            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pop();
            });
          } else {
            controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
          }
        },
        child: Text(
          currentPage == 3 ? 'Terminer' : 'Suivant', // Use currentPage here as well
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.85,
              child: ClipRect(
                child: PageView(
                  controller: controller,
                  onPageChanged: (int page) {
                    // Add the onPageChanged callback
                    setState(() {
                      currentPage = page; // Update the currentPage on page change
                    });
                  },
                  children: const [ClipRect(child: TutorialOne()), ClipRect(child: TutorialTwo()), ClipRect(child: TutorialThree()), ClipRect(child: TutorialFour())],
                ),
              ),
            ),

            // Steps
            // Page indicator
            SmoothPageIndicator(controller: controller, count: 4, effect: const ExpandingDotsEffect(activeDotColor: kBlack, dotColor: kLightGrey, dotHeight: 8, dotWidth: 8)),
          ],
        ),
      ),
    );
  }
}
