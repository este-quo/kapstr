import 'package:flutter/material.dart';
import 'package:kapstr/helpers/share_app.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';

class SendInvitationButton extends StatelessWidget {
  const SendInvitationButton({super.key, this.recipients, required this.isPublic});

  final List<String>? recipients;
  final bool isPublic;

  @override
  Widget build(BuildContext context) {
    return MainButton(
      onPressed: () async {
        if (recipients != null) {
          sendSMSToGuests(context, recipients!);
        } else {
          shareEvent(context);
        }
      },
      backgroundColor: kPrimary,
      child: Text(textAlign: TextAlign.center, isPublic ? 'Partager mon invitation' : 'Envoyer mon invitation', style: TextStyle(color: kWhite, fontSize: 16.0, fontWeight: FontWeight.w400)),
    );
  }
}
