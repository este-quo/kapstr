import 'package:flutter/material.dart';
import 'package:kapstr/controllers/modules/cagnotte.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/models/modules/cagnotte.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/organizer/modules/cagnotte/card.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:provider/provider.dart';

class Cagnotte extends StatefulWidget {
  const Cagnotte({super.key, required this.moduleId});

  final String moduleId;

  @override
  State<Cagnotte> createState() => _CagnotteState();
}

class _CagnotteState extends State<Cagnotte> {
  bool isLoading = false;

  Future<CagnotteModule?> _fetchCagnotteModule() async {
    try {
      return await context.read<CagnotteController>().getCagnotteById(widget.moduleId);
    } catch (e) {
      printOnDebug("Error fetching cagnotte module: $e");
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 75,
        toolbarHeight: 40,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(onTap: () => Navigator.of(context).pop(), child: const Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: kBlack), Text('Retour', style: TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w500))])),
        ),
        actions: const [SizedBox(width: 91)],
      ),
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: kWhite,
      body: SafeArea(
        child: FutureBuilder<CagnotteModule?>(
          future: _fetchCagnotteModule(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: SizedBox(height: 40, width: 40, child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 40)));
            } else if (snapshot.hasError) {
              return const Center(child: Text("Une erreur est survenue", style: TextStyle(color: kYellow)));
            } else if (snapshot.hasData) {
              return _buildCagnotte(snapshot.data!);
            } else {
              return const Center(child: Column(children: [Text("Aucune cagnotte n'a été créée", style: TextStyle(color: kYellow))]));
            }
          },
        ),
      ),
    );
  }

  Widget _buildCagnotte(CagnotteModule cagnotte) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text('Lien externe', textAlign: TextAlign.left, style: TextStyle(fontSize: 24, color: kBlack, fontWeight: FontWeight.w600)),

            const SizedBox(height: 8),

            // Subtitle
            const Text('Ajouter un lien pour mettre en avant votre cagnotte, ou pour rediriger les participants vers un site web.', textAlign: TextAlign.left, style: TextStyle(fontSize: 14, color: kBlack, fontWeight: FontWeight.w400)),
            const SizedBox(height: 16),

            // Cagnottes List
            if (cagnotte.cagnotteUrl.isNotEmpty) buildLinkList(cagnotte.cagnotteUrl),

            // Add Button
            Center(
              child: MainButton(
                onPressed: () async {
                  if (isLoading) return;
                  _showAddLinkDialog();
                },
                child: Text(cagnotte.cagnotteUrl.isNotEmpty ? 'Modifier le lien' : 'Ajouter un lien', style: const TextStyle(fontSize: 16, color: kWhite, fontWeight: FontWeight.w400)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLinkList(String link) {
    return CagnotteCard(link: link);
  }

  void _showAddLinkDialog() async {
    String linkUrl = '';

    // Show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kWhite,
          surfaceTintColor: kWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text('Entrez votre lien', style: TextStyle(color: kBlack, fontSize: 18, fontWeight: FontWeight.w500)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  onChanged: (value) {
                    linkUrl = value;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Votre lien (google.com)',
                    hintStyle: TextStyle(color: kLightGrey, fontSize: 16, fontWeight: FontWeight.w400),
                    border: UnderlineInputBorder(borderSide: BorderSide(color: kBlack, width: 1.0)),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBlack, width: 1.0)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBlack, width: 1.0)),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler', style: TextStyle(color: kBlack)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Valider'),
              onPressed: () async {
                if (linkUrl.isNotEmpty) {
                  Navigator.of(context).pop();
                  setState(() {
                    isLoading = true;
                  });

                  try {
                    await context.read<CagnotteController>().addLinkToCagnotte(linkUrl, widget.moduleId);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lien ajouté avec succès"), backgroundColor: kSuccess, duration: Duration(seconds: 2)));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur lors de l'ajout du lien"), backgroundColor: Colors.red, duration: Duration(seconds: 2)));
                  } finally {
                    setState(() {
                      isLoading = false;
                    });
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
