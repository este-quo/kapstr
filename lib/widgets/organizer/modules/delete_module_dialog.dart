import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/controllers/modules/modules.dart';
import 'package:kapstr/views/organizer/home/configuration.dart';
import 'package:provider/provider.dart';

Future<void> deleteModuleDialog(BuildContext context, String moduleId) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        titlePadding: EdgeInsets.zero,
        surfaceTintColor: kWhite,
        backgroundColor: kWhite,
        title: const SizedBox(),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce module ?', style: TextStyle(color: kBlack, fontWeight: FontWeight.w500, fontSize: 16)),
        actions: <Widget>[
          TextButton(
            child: const Text('Annuler', style: TextStyle(color: kBlack)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Supprimer', style: TextStyle(color: kDanger)),
            onPressed: () async {
              await context
                  .read<ModulesController>()
                  .deleteModule(moduleId: moduleId)
                  .then((value) {
                    const SnackBar(content: Text('Module supprimé'));
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const OrgaHomepageConfiguration()), (Route<dynamic> route) => route.isFirst);
                  })
                  .onError((error, stackTrace) {
                    const SnackBar(content: Text('Erreur lors de la suppression du module'), backgroundColor: kDanger);
                  });
            },
          ),
        ],
      );
    },
  );
}
