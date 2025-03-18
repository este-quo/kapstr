import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kapstr/configuration/navigation/entry_point.dart';
import 'package:kapstr/controllers/authentication.dart';
import 'package:kapstr/controllers/event_data.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/global/phone_verification/verification.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';

class PhoneNumberRequestUI extends StatefulWidget {
  const PhoneNumberRequestUI({super.key});

  @override
  _PhoneNumberRequestUIState createState() => _PhoneNumberRequestUIState();
}

class _PhoneNumberRequestUIState extends State<PhoneNumberRequestUI> {
  bool _isLoading = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController controller = TextEditingController();
  PhoneNumber number = PhoneNumber(isoCode: 'FR');
  String verificationId = '';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButton: MainButton(
        onPressed: () async {
          if (_isLoading) return;
          if (!formKey.currentState!.validate()) return;
          setState(() {
            _isLoading = true;
          });
          bool alreadyRegistered = await isPhoneNumberRegistered(controller.text);
          if (alreadyRegistered) {
            setState(() {
              _isLoading = false;
            });
            if (context.mounted) {
              return showAlreadyRegisteredDialog(context);
            }
          }

          await FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: number.phoneNumber!,
            timeout: const Duration(seconds: 60),
            verificationCompleted: (PhoneAuthCredential credential) {},
            verificationFailed: (FirebaseAuthException exception) {
              setState(() {
                _isLoading = false;
              });
              handleError(exception);
            },
            codeSent: (String verificationId, int? forceResendingToken) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PhoneCodeVerification(verificationId: verificationId, forceResendingToken: forceResendingToken, number: number)));
            },
            codeAutoRetrievalTimeout: (String verificationId) {},
          );
        },
        child: _isLoading ? const PulsatingLogo(svgPath: 'assets/icons/app/svg_dark.svg', size: 32) : const Text('Envoyer le code', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Vériﬁcation du téléphone', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black)),
        leading: const SizedBox(),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () async {
              await context.read<AuthenticationController>().logout(context);
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const EntryPoint()), (route) => false);
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Center(
            child: SizedBox(
              width: screenWidth - 40,
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        InternationalPhoneNumberInput(
                          locale: 'fr_FR',
                          onInputChanged: (PhoneNumber number) {
                            setState(() {
                              this.number = number;
                            });
                          },
                          selectorConfig: const SelectorConfig(selectorType: PhoneInputSelectorType.BOTTOM_SHEET),
                          searchBoxDecoration: const InputDecoration(labelText: 'Rechercher par nom de pays ou indicatif régional', hintStyle: TextStyle(color: Colors.black, fontSize: 16)),
                          ignoreBlank: false,
                          autoValidateMode: AutovalidateMode.disabled,
                          selectorTextStyle: const TextStyle(color: Colors.black, fontSize: 16),
                          initialValue: number,
                          textFieldController: controller,
                          keyboardAction: TextInputAction.done,
                          keyboardType: TextInputType.phone,
                          formatInput: true,
                          hintText: 'Numéro de téléphone',
                          inputBorder: const OutlineInputBorder(),
                          onSaved: (PhoneNumber number) {
                            printOnDebug('On Saved: $number');
                          },
                        ),
                        const SizedBox(height: 24),
                        const Text('Veuillez entrer votre numéro de téléphone pour recevoir un code d’authentification.', style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> isPhoneNumberRegistered(String phoneNumber) async {
    // Remplacez ceci par votre vérification de numéro de téléphone avec Firestore
    return false;
  }

  void handleError(FirebaseAuthException exception) {
    String errorMessage = "Une erreur s'est produite lors de l'envoi du code de vérification";

    switch (exception.code) {
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
      case 'number-already-in-use':
        errorMessage = "Ce numéro de téléphone est déjà utilisé par un autre compte.";
        break;
      default:
        errorMessage = exception.message ?? errorMessage;
        break;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kWhite,
          surfaceTintColor: kWhite,
          title: const Text('Erreur de vérification', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
          content: Text(errorMessage, style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w400)),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
        );
      },
    );
  }

  void showAlreadyRegisteredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kWhite,
          surfaceTintColor: kWhite,
          title: const Text('Numéro de téléphone déjà utilisé', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
          content: const Text("Ce numéro de téléphone est déjà utilisé par un autre compte. Veuillez vous connecter avec ce compte.", style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w400)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
