import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kapstr/views/global/login/button.dart';
import 'package:kapstr/views/global/login/mail/signup.dart';
import 'package:kapstr/controllers/authentication.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/cgu.dart';
import 'package:provider/provider.dart';

class LogIn extends StatelessWidget {
  const LogIn({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: Center(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 164),

                // Logo Kapstr
                Image.asset('assets/logos/kapstr_logo.png', width: MediaQuery.of(context).size.width * 0.4),

                SizedBox(width: MediaQuery.of(context).size.width * 0.7, child: const Text('Créez votre faire part 100% mobile et partagez chaque moment.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400))),

                const Spacer(),
                // Buttons
                _buildSocialLoginButtons(context),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Expanded(child: Divider(color: kLightGrey)), SizedBox(width: 12), Text('ou', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: kLightGrey)), SizedBox(width: 12), Expanded(child: Divider(color: kLightGrey))],
                ),

                const SizedBox(height: 8),

                // Mail login button
                _mailLoginButton(context),

                const SizedBox(height: 16),

                const CGU(),

                const SizedBox(height: 116),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginButtons(BuildContext context) {
    final authProvider = context.read<AuthenticationController>();
    final List<Widget> buttons = [if (Platform.isIOS) _appleLoginButton(context, authProvider), _googleLoginButton(context, authProvider)];

    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: buttons);
  }

  Widget _appleLoginButton(BuildContext context, AuthenticationController authProvider) {
    return LoginButton(
      assetName: 'assets/icons/apple_logo.png',
      text: 'Continuer avec Apple',
      textColor: kWhite,
      backgroundColor: kBlack,
      onPressed: () async {
        await authProvider.signInWithApple(context);
      },
    );
  }

  Widget _googleLoginButton(BuildContext context, AuthenticationController authProvider) {
    return LoginButton(
      assetName: 'assets/icons/google_logo.png',
      text: 'Continuer avec Google',
      textColor: kBlack,
      backgroundColor: Colors.white,
      onPressed: () async {
        try {
          await authProvider.signInWithGoogle(context);
        } catch (e) {
          _showErrorDialog(context, e.toString());
        }
      },
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kWhite,
          surfaceTintColor: kWhite,
          title: Text('Erreur de connexion'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _mailLoginButton(BuildContext context) {
    return LoginButton(
      assetName: 'assets/icons/mail_icon.png',
      text: 'Continuer avec Email',
      textColor: kWhite,
      backgroundColor: kPrimary,
      onPressed: () async {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const EmailSignUp()));
      },
    );
  }
}
