import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:kapstr/widgets/text_input.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isCurrentPasswordObscured = true;
  bool _isNewPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  
  // Détermine si l'utilisateur s'est connecté via Google/Apple (sans mot de passe)
  bool get _isGoogleOrAppleUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    
    // Vérifie si l'utilisateur a un fournisseur Google ou Apple
    final providers = user.providerData.map((provider) => provider.providerId).toList();
    return providers.contains('google.com') || providers.contains('apple.com');
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      // Si l'utilisateur s'est connecté via Google/Apple, pas besoin de l'ancien mot de passe
      if (!_isGoogleOrAppleUser) {
        // Ré-authentifier avec l'ancien mot de passe
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );
        await user.reauthenticateWithCredential(credential);
      }

      // Changer le mot de passe
      await user.updatePassword(_newPasswordController.text);

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mot de passe modifié avec succès', style: TextStyle(color: kWhite)),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
      
    } catch (e) {
      String errorMessage = 'Une erreur s\'est produite. Veuillez réessayer.';
      
      if (e.toString().contains('wrong-password')) {
        errorMessage = 'Mot de passe actuel incorrect.';
      } else if (e.toString().contains('weak-password')) {
        errorMessage = 'Le nouveau mot de passe est trop faible.';
      } else if (e.toString().contains('requires-recent-login')) {
        errorMessage = 'Veuillez vous reconnecter et réessayer.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage, style: const TextStyle(color: kWhite)),
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
        title: const Text('Changer le mot de passe', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: kBlack)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: MainButton(
        onPressed: _changePassword,
        child: _isLoading 
          ? const PulsatingLogo(svgPath: 'assets/icons/app/svg_dark.svg', size: 32)
          : const Text('Modifier le mot de passe', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w500)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                
                // Information sur le type de connexion
                if (_isGoogleOrAppleUser) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Vous êtes connecté via Google/Apple. Vous pouvez définir un mot de passe pour vous connecter avec votre email.',
                            style: TextStyle(color: Colors.blue, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else ...[
                  // Mot de passe actuel (seulement pour les utilisateurs avec email/mot de passe)
                  const Text('Mot de passe actuel', style: TextStyle(fontSize: 18, color: kBlack, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _currentPasswordController,
                    obscureText: _isCurrentPasswordObscured,
                    decoration: InputDecoration(
                      hintText: 'Entrez votre mot de passe actuel',
                      hintStyle: const TextStyle(color: kLightGrey, fontSize: 14, fontWeight: FontWeight.w400),
                      border: const UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
                      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
                      suffixIcon: IconButton(
                        icon: Icon(_isCurrentPasswordObscured ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _isCurrentPasswordObscured = !_isCurrentPasswordObscured;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre mot de passe actuel';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Nouveau mot de passe
                const Text('Nouveau mot de passe', style: TextStyle(fontSize: 18, color: kBlack, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _isNewPasswordObscured,
                  decoration: InputDecoration(
                    hintText: 'Entrez votre nouveau mot de passe',
                    hintStyle: const TextStyle(color: kLightGrey, fontSize: 14, fontWeight: FontWeight.w400),
                    border: const UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
                    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
                    suffixIcon: IconButton(
                      icon: Icon(_isNewPasswordObscured ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _isNewPasswordObscured = !_isNewPasswordObscured;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nouveau mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Confirmer le nouveau mot de passe
                const Text('Confirmer le nouveau mot de passe', style: TextStyle(fontSize: 18, color: kBlack, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _isConfirmPasswordObscured,
                  decoration: InputDecoration(
                    hintText: 'Confirmez votre nouveau mot de passe',
                    hintStyle: const TextStyle(color: kLightGrey, fontSize: 14, fontWeight: FontWeight.w400),
                    border: const UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
                    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
                    suffixIcon: IconButton(
                      icon: Icon(_isConfirmPasswordObscured ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez confirmer le nouveau mot de passe';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Conseils de sécurité
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kLightGrey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conseils pour un mot de passe sécurisé :',
                        style: TextStyle(fontWeight: FontWeight.w600, color: kBlack),
                      ),
                      SizedBox(height: 8),
                      Text('• Au moins 6 caractères', style: TextStyle(color: kBlack, fontSize: 14)),
                      Text('• Mélangez lettres, chiffres et symboles', style: TextStyle(color: kBlack, fontSize: 14)),
                      Text('• Évitez les informations personnelles', style: TextStyle(color: kBlack, fontSize: 14)),
                    ],
                  ),
                ),
                
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
