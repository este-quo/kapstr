import 'package:flutter/material.dart';
import 'package:kapstr/controllers/guests.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/organizer/guest_manager/dashboard/dashboard.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:provider/provider.dart';
import 'modules_tabs.dart';

class GuestDashboard extends StatefulWidget {
  const GuestDashboard({super.key});

  @override
  State<StatefulWidget> createState() => _GuestDashboardState();
}

class _GuestDashboardState extends State<GuestDashboard> {
  bool wasLoading = false;
  bool hasShownCompletionSnackBar = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: kWhite,
          elevation: 0,
          surfaceTintColor: kWhite,
          leadingWidth: 0,
          leading: const SizedBox(),
          title: const Text('Mes invités', textAlign: TextAlign.left, style: TextStyle(fontSize: 24, color: kBlack, fontWeight: FontWeight.w600)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const Dashboard()));
                },
                icon: const Icon(Icons.bar_chart_rounded, color: kPrimary, size: 24),
              ),
            ),
          ],
        ),
        backgroundColor: kWhite,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
              // Utilisez un Consumer pour écouter les changements de GuestsController
              Consumer<GuestsController>(
                builder: (context, guestsController, child) {
                  if (guestsController.isLoading) {
                    if (!wasLoading) {
                      wasLoading = true;
                      hasShownCompletionSnackBar = false;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                              content: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [SizedBox(height: 16, width: 16, child: PulsatingLogo(svgPath: 'assets/icons/app/svg_dark.svg', size: 64)), SizedBox(width: 12), Expanded(child: Text('Importation en cours...'))]),
                              duration: Duration(days: 365),
                            ),
                          );
                      });
                    }
                  } else if (wasLoading && !hasShownCompletionSnackBar) {
                    wasLoading = false;
                    hasShownCompletionSnackBar = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Row(children: <Widget>[Icon(Icons.check_rounded, color: Colors.white, size: 16), SizedBox(width: 12), Text('Vos contacts ont bien été importés !', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400))]),
                            duration: Duration(seconds: 3),
                            backgroundColor: kSuccess,
                          ),
                        );
                    });
                  }
                  return Container();
                },
              ),

              ModuleFiltersTab(),
            ],
          ),
        ),
      ),
    );
  }
}
