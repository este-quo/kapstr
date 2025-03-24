import 'package:flutter/material.dart';
import 'package:kapstr/controllers/authentication.dart';
import 'package:kapstr/controllers/modules/golden_book.dart';
import 'package:kapstr/controllers/notification.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/models/app_guest.dart';
import 'package:kapstr/models/modules/golden_book_message.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/global/login/login.dart';
import 'package:kapstr/views/guest/modules/golden_book/card_preview.dart';
import 'package:kapstr/views/guest/modules/layout.dart';
import 'package:kapstr/widgets/layout/spacing.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:kapstr/widgets/theme/background_theme.dart';
import 'package:provider/provider.dart';

class GoldenBookGuest extends StatefulWidget {
  const GoldenBookGuest({super.key, required this.moduleId, this.isPreview = false});

  final String moduleId;
  final bool isPreview;

  @override
  State<GoldenBookGuest> createState() => _GoldenBookGuestState();
}

class _GoldenBookGuestState extends State<GoldenBookGuest> {
  final TextEditingController _controller = TextEditingController();
  late Future<GoldenBookMessage> _messageFuture;
  bool isLoading = false;
  bool isControllerInitialized = false;

  @override
  void initState() {
    super.initState();
    _messageFuture = context.read<GoldenBookController>().getGuestMessage(widget.moduleId, AppGuest.instance.id);
  }

  Future<void> _handleSend() async {
    if (context.read<UsersController>().user != null) {
      if (isLoading) return;
      setState(() {
        isLoading = true;
      });
      await context.read<GoldenBookController>().sendMessage(widget.moduleId, _controller.text, AppGuest.instance.id);

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Votre message à bien été envoyé', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w400)), backgroundColor: kSuccess));

      await context.read<NotificationController>().addOrganizerNotification(
        title: 'Livre d\'or',
        body: '${context.watch<UsersController>().user!.name} a laissé un nouveau message',
        image: context.watch<UsersController>().user!.name != '' ? context.watch<UsersController>().user!.imageUrl : null,
        type: 'golden_book',
      );

      Navigator.pop(context);
    } else {
      context.read<AuthenticationController>().setPendingConnection(true);

      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.3),
        useSafeArea: true,
        builder: (context) {
          return DraggableScrollableSheet(
            initialChildSize: 1,
            minChildSize: 0.8,
            maxChildSize: 1,
            expand: false,
            builder: (context, scrollController) {
              return const LogIn();
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      floatingActionButton: FloatingActionButton(backgroundColor: kPrimary, onPressed: _handleSend, child: isLoading ? const CircularProgressIndicator(color: kWhite) : const Icon(Icons.send, color: kWhite)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: BackgroundTheme(
        child: GuestModuleLayout(
          title: "Livre d'or",
          isThemeApplied: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<GoldenBookMessage>(
                  future: _messageFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64));
                    } else if (snapshot.hasError) {
                      return const Text('Erreur lors du chargement du message');
                    } else if (snapshot.hasData) {
                      if (!isControllerInitialized) {
                        _controller.text = snapshot.data!.message;
                        isControllerInitialized = true;
                      }
                      return SingleChildScrollView(
                        child: GestureDetector(
                          onTap: () => FocusScope.of(context).unfocus(),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [smallSpacerH(context), SizedBox(height: MediaQuery.of(context).size.height * 0.65, width: MediaQuery.of(context).size.width, child: CardPreview(controller: _controller)), xLargeSpacerH(context)]),
                        ),
                      );
                    } else {
                      return const Text('Aucun message');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
