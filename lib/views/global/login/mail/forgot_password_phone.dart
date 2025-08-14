import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:kapstr/widgets/logo_loader.dart';

class ForgotPasswordPhone extends StatefulWidget {
  const ForgotPasswordPhone({super.key});

  @override
  State<ForgotPasswordPhone> createState() => _ForgotPasswordPhoneState();
}

class _ForgotPasswordPhoneState extends State<ForgotPasswordPhone> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _codeFormKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _codeSent = false;
  String? _verificationId;
  
  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendVerificationCode() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String phoneNumber = _phoneController.text.trim();
      if (!phoneNumber.startsWith('+')) {
        phoneNumber = '+33${phoneNumber.replaceFirst('0', '')}';
      }

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          await _handleCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage = 'Une erreur s\'est produite.';
          
          if (e.code == 'invalid-phone-number') {
            errorMessage = 'Le numéro de téléphone n\'est pas valide.';
          } else if (e.code == 'too-many-requests') {
            errorMessage = 'Trop de tentatives. Veuillez réessayer plus tard.';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage, style: const TextStyle(color: kWhite)),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoading = false);
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _codeSent = true;
            _isLoading = false;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}', style: const TextStyle(color: kWhite)),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCode() async {
    if (_isLoading) return;
    if (!_codeFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _codeController.text.trim(),
      );
      
      await _handleCredential(credential);
    } catch (e) {
      String errorMessage = 'Code de vérification incorrect.';
      
      if (e.toString().contains('invalid-verification-code')) {
        errorMessage = 'Le code de vérification est incorrect.';
      } else if (e.toString().contains('session-expired')) {
        errorMessage = 'Le code a expiré. Veuillez en demander un nouveau.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage, style: const TextStyle(color: kWhite)),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCredential(PhoneAuthCredential credential) async {
    try {
      // Ici, vous devriez rediriger vers une page où l'utilisateur peut définir un nouveau mot de passe
      // Pour l'instant, on affiche juste un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Numéro vérifié ! Redirection vers la définition du nouveau mot de passe...', 
                      style: TextStyle(color: kWhite)),
          backgroundColor: Colors.green,
        ),
      );
      
      // Retourner à la page de connexion après un délai
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de vérification: ${e.toString()}', style: const TextStyle(color: kWhite)),
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
        title: const Text('Récupération par SMS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: kBlack)),
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
              
              if (!_codeSent) ...[
                // Icône
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sms_outlined,
                    size: 40,
                    color: kPrimary,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Titre
                const Text(
                  'Récupération par SMS',
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
                  'Entrez votre numéro de téléphone ci-dessous et nous vous enverrons un code de vérification par SMS.',
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
                    controller: _phoneController,
                    decoration: _inputDecoration('Numéro de téléphone'),
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w400),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un numéro de téléphone';
                      }
                      if (value.length < 10) {
                        return 'Veuillez entrer un numéro valide';
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
                    onPressed: _sendVerificationCode,
                    child: _isLoading 
                        ? const PulsatingLogo(svgPath: 'assets/icons/app/svg_dark.svg', size: 32)
                        : const Text(
                            'Envoyer le code SMS',
                            style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                  ),
                ),
                
              ] else ...[
                // Saisie du code de vérification
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sms,
                    size: 40,
                    color: kPrimary,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                const Text(
                  'Code de vérification',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: kBlack,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'Entrez le code de vérification envoyé au ${_phoneController.text}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: kLightGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                Form(
                  key: _codeFormKey,
                  child: TextFormField(
                    controller: _codeController,
                    decoration: _inputDecoration('Code de vérification'),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: kBlack, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 2),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le code de vérification';
                      }
                      if (value.length != 6) {
                        return 'Le code doit contenir 6 chiffres';
                      }
                      return null;
                    },
                  ),
                ),
                
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  child: MainButton(
                    onPressed: _verifyCode,
                    child: _isLoading 
                        ? const PulsatingLogo(svgPath: 'assets/icons/app/svg_dark.svg', size: 32)
                        : const Text(
                            'Vérifier le code',
                            style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                TextButton(
                  onPressed: () {
                    setState(() => _codeSent = false);
                  },
                  child: const Text(
                    'Renvoyer le code SMS',
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
