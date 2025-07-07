import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/configuration/navigation/entry_point.dart';
import 'package:kapstr/controllers/authentication.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/guests.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/global/events/create/completed.dart';
import 'package:kapstr/views/global/events/events.dart';
import 'package:kapstr/views/global/login/name.dart';
import 'package:kapstr/views/global/phone_verification/complete_name.dart';
import 'package:kapstr/views/global/phone_verification/request.dart';
import 'package:kapstr/widgets/layout/spacing.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pinput/pinput.dart';
import 'package:kapstr/services/firebase/cloud_firestore/cloud_firestore.dart' as cloud_firestore;

class PhoneCodeVerification extends StatefulWidget {
  final String verificationId;
  final int? forceResendingToken;
  final PhoneNumber number;

  const PhoneCodeVerification({super.key, required this.verificationId, this.forceResendingToken, required this.number});

  @override
  PhoneCodeVerificationState createState() => PhoneCodeVerificationState();
}

class PhoneCodeVerificationState extends State<PhoneCodeVerification> {
  final _phoneCodeVerificationFieldFocusNode = FocusNode();
  final pinController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_phoneCodeVerificationFieldFocusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    const errorColor = Color.fromRGBO(255, 234, 238, 1);

    const defaultPinTheme = PinTheme(textStyle: TextStyle(color: kBlack, fontSize: 24, fontWeight: FontWeight.w400), width: 32, height: 32, decoration: BoxDecoration(color: kWhite, border: Border(bottom: BorderSide(color: kBlack, width: 1))));

    return Scaffold(
      backgroundColor: kWhite,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
        elevation: 0,
        centerTitle: true,
        title: const Text('Vériﬁcation du téléphone', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: kBlack)),
        leading: const SizedBox(),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: kBlack),
            onPressed: () async {
              await context.read<AuthenticationController>().logout(context);
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const EntryPoint()), (route) => false);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: screenWidth - 40,
            child: Column(
              children: [
                const SizedBox(height: 32),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [const Text('Nous avons envoyé un code de vérification au ', style: TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w400)), Text(widget.number.phoneNumber!, style: const TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w500))],
                ),
                const SizedBox(height: 24),
                Pinput(
                  focusNode: _phoneCodeVerificationFieldFocusNode,
                  controller: pinController,
                  length: 6,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.phone,
                  defaultPinTheme: defaultPinTheme,
                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                  onChanged: (value) {
                    if (value.length == 6) {
                      _onPhoneVerificationComplete(value);
                    }
                  },
                  onCompleted: (pin) {
                    FocusScope.of(context).unfocus();
                  },
                  cursor: Column(mainAxisAlignment: MainAxisAlignment.end, children: [Container(margin: const EdgeInsets.only(bottom: 9), width: 24, height: 1, color: kYellow)]),
                  errorPinTheme: defaultPinTheme.copyBorderWith(border: const Border(bottom: BorderSide(color: errorColor, width: 1))),
                ),
                const SizedBox(height: 24),
                const Text('Vous n’avez pas reçu de code ?', style: TextStyle(color: kGrey, fontSize: 14, fontWeight: FontWeight.w400)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    await FirebaseAuth.instance.verifyPhoneNumber(
                      phoneNumber: widget.number.phoneNumber!,
                      timeout: const Duration(seconds: 60),
                      verificationCompleted: (PhoneAuthCredential credential) async {
                        await FirebaseAuth.instance.currentUser?.linkWithCredential(credential);
                        if (!mounted) return;
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const OnboardingComplete()), (route) => false);
                      },
                      verificationFailed: _handleVerificationFailed,
                      codeSent: (String verificationId, int? forceResendingToken) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PhoneCodeVerification(verificationId: verificationId, forceResendingToken: forceResendingToken, number: widget.number)));
                      },
                      codeAutoRetrievalTimeout: (String verificationId) {},
                    );
                  },
                  child: const Text('Me renvoyer un code', style: TextStyle(color: kBlueLink, fontSize: 14, fontWeight: FontWeight.w400)),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PhoneNumberRequestUI()));
                  },
                  child: const Text('Utiliser un autre numéro', style: TextStyle(color: kBlueLink, fontSize: 14, fontWeight: FontWeight.w400)),
                ),
                xLargeSpacerH(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onPhoneVerificationComplete(String phone) async {
    try {
      final code = pinController.text.trim();
      AuthCredential credential = PhoneAuthProvider.credential(verificationId: widget.verificationId, smsCode: code);

      await FirebaseAuth.instance.currentUser?.linkWithCredential(credential);

      await cloud_firestore.createUser({
        "phone": widget.number.phoneNumber,
        "id_auth_token": FirebaseAuth.instance.currentUser!.uid,
        "message_token": await FirebaseMessaging.instance.getToken(),
        "created_events": [],
        "joined_events": [],
        "image_url": FirebaseAuth.instance.currentUser!.photoURL ?? '',
        "name": FirebaseAuth.instance.currentUser!.displayName ?? '',
        "email": FirebaseAuth.instance.currentUser!.email ?? '',
        "onboarding_complete": false,
        "credits": 1,
      });

      await context.read<UsersController>().initUser();
      if (context.read<AuthenticationController>().isPendingConnection) {
        await context.read<GuestsController>().createGuestFromUser(context.read<UsersController>().user!, context.read<EventsController>().event.id);
        if (!mounted) return;
        await context.read<UsersController>().addNewJoinedEvent(Event.instance.id, context);
        if (context.mounted) {
          await context.read<GuestsController>().getGuests(context.read<EventsController>().event.id).then((guests) async {
            await context.read<GuestsController>().addGuestsToEvent(guests, context);
          });
        }
        await context.read<EventsController>().confirmGuestAddition(context.read<EventsController>().event.id, context.read<UsersController>().user!.phone, context.read<UsersController>().user!.id);
      }
      context.read<AuthenticationController>().setPendingConnection(false);
      context.read<UsersController>().user!.name == "" ? Navigator.push(context, MaterialPageRoute(builder: (context) => const CompleteNameFormPage())) : Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MyEvents()), (route) => false);
    } catch (e) {
      _handleVerificationFailed(e as FirebaseAuthException);
    }
  }

  void _handleVerificationFailed(FirebaseAuthException e) {
    String errorMessage = "Une erreur s'est produite lors de l'envoi du code de vérification";

    printOnDebug("code :${e.code}");
    printOnDebug("message :${e.message}");

    switch (e.code) {
      case 'invalid-phone-number':
        errorMessage = "Le numéro de téléphone fourni n'est pas valide. Veuillez vérifier et réessayer.";
        break;
      case 'too-many-requests':
        errorMessage = "Trop de tentatives d'authentification ont été effectuées. Veuillez attendre un moment avant de réessayer.";
        break;
      case 'quota-exceeded':
        errorMessage = "Le quota de SMS a été dépassé. Veuillez réessayer plus tard.";
        break;
      case 'network-request-failed':
        errorMessage = "Échec de la connexion réseau. Veuillez vérifier votre connexion Internet et réessayer.";
        break;
      case 'user-disabled':
        errorMessage = "Le compte associé à ce numéro de téléphone a été désactivé.";
        break;
      case 'operation-not-allowed':
        errorMessage = "L'opération de vérification du numéro de téléphone n'est pas autorisée.";
        break;
      case 'credential-already-in-use':
        errorMessage = "Il semble que ce numéro de téléphone soit déjà associé à un compte existant. Si vous avez oublié vos identifiants, vous pouvez essayer de réinitialiser votre mot de passe ou de contacter le support pour obtenir de l'aide.";
        break;
      default:
        errorMessage = e.message ?? errorMessage;
        break;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kWhite,
          surfaceTintColor: kWhite,
          title: const Text('Erreur de vérification', style: TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w500)),
          content: Text(errorMessage, style: const TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w400)),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
        );
      },
    );
  }
}
