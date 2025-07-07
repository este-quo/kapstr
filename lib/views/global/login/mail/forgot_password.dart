import 'package:flutter/material.dart';
import 'package:kapstr/controllers/authentication.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:provider/provider.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await context.read<AuthenticationController>().resetPassword(_emailController.text.trim());
      setState(() => _emailSent = true);
    } catch (e) {
      String errorMessage = 'Une erreur s\'est produite. Veuillez réessayer.';
      
      if (e.toString().contains('user-not-found')) {
        errorMessage = 'Aucun compte n\'est associé à cette adresse email.';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'L\'adresse email n\'est pas valide.';
      } else if (e.toString().contains('too-many-requests')) {
        errorMessage = 'Trop de tentatives. Veuillez réessayer plus tard.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage, style: const TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w400)),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
        elevation: 0,
        centerTitle: true,
        title: const Text('Mot de passe oublié', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: kBlack)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              
              if (!_emailSent) ...[
                // Icône
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 40,
                    color: kPrimary,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Titre
                const Text(
                  'Récupération du mot de passe',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: kBlack,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Description
                const Text(
                  'Entrez votre adresse email ci-dessous et nous vous enverrons un lien pour réinitialiser votre mot de passe.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: kLightGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Formulaire
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _emailController,
                    decoration: _inputDecoration('Adresse email'),
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w400),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une adresse email';
                      }
                      if (!value.contains('@')) {
                        return 'Veuillez entrer une adresse email valide';
                      }
                      return null;
                    },
                  ),
                ),
                
                const SizedBox(height: 100),
                
                // Bouton
                SizedBox(
                  width: double.infinity,
                  child: MainButton(
                    onPressed: _resetPassword,
                    child: _isLoading 
                        ? const PulsatingLogo(svgPath: 'assets/icons/app/svg_dark.svg', size: 32)
                        : const Text(
                            'Envoyer le lien',
                            style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                  ),
                ),
                
              ] else ...[
                // Confirmation d'envoi
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    size: 40,
                    color: Colors.green,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                const Text(
                  'Email envoyé !',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: kBlack,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'Nous avons envoyé un lien de réinitialisation à ${_emailController.text}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: kLightGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                const Text(
                  'Vérifiez votre boîte de réception et suivez les instructions pour réinitialiser votre mot de passe.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: kLightGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Bouton retour à la connexion
                SizedBox(
                  width: double.infinity,
                  child: MainButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Retour à la connexion',
                      style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Bouton renvoyer l'email
                TextButton(
                  onPressed: () {
                    setState(() => _emailSent = false);
                  },
                  child: const Text(
                    'Renvoyer l\'email',
                    style: TextStyle(color: kPrimary, fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      hintText: hintText,
      hintStyle: const TextStyle(color: kLightGrey, fontSize: 14, fontWeight: FontWeight.w400),
      border: const UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
    );
  }
}
