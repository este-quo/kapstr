import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:kapstr/controllers/modules/modules.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:provider/provider.dart';
import 'package:google_places_flutter/model/prediction.dart';

class PlacePicker extends StatefulWidget {
  final String initialPlaceAddress;
  final String moduleId;
  final Module module;

  const PlacePicker({super.key, required this.initialPlaceAddress, required this.moduleId, required this.module});

  @override
  State<StatefulWidget> createState() => _PlacePickerState();
}

class _PlacePickerState extends State<PlacePicker> {
  late String placeAdress;
  late TextEditingController placeAddressController;
  late FocusNode placeAddressFocusNode;

  @override
  void initState() {
    super.initState();
    placeAdress = widget.initialPlaceAddress == 'Adresse du lieu' ? '' : widget.initialPlaceAddress;
    placeAddressController = TextEditingController(text: placeAdress);
    placeAddressFocusNode = FocusNode();
  }

  @override
  void dispose() {
    placeAddressController.dispose();
    placeAddressFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (placeAddressFocusNode.canRequestFocus) {
        placeAddressFocusNode.requestFocus();
      }
    });
  }

  Future<void> _validateAndProceed() async {
    await context.read<ModulesController>().updatePlaceAddress(placeAddress: placeAddressController.text, moduleId: widget.moduleId);
    if (widget.module.type == "wedding") {
      await context.read<ModulesController>().updateInvitationCardAddress(placeAddressController.text);
    }
    if (!mounted) return;
    Navigator.pop(context, placeAddressController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kWhite,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: GestureDetector(onTap: () => Navigator.of(context).pop(), child: const Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: kBlack), Text('Retour', style: TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w500))])),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: GooglePlaceAutoCompleteTextField(
              showError: false,
              debounceTime: 100,
              focusNode: placeAddressFocusNode,
              googleAPIKey: "AIzaSyDhK630n5dhEfU_nPdGzOq7Fi4GuNxMxcw",
              textEditingController: placeAddressController,
              textStyle: const TextStyle(fontSize: 16, color: kBlack, fontWeight: FontWeight.w400),
              itemClick: (Prediction prediction) async {
                placeAddressController.text = prediction.description ?? '';
                placeAddressController.selection = TextSelection.fromPosition(TextPosition(offset: prediction.description?.length ?? 0));
                await _validateAndProceed();
              },
              inputDecoration: const InputDecoration(hintText: "Rechercher une adresse", hintStyle: TextStyle(fontSize: 16, color: kBlack, fontWeight: FontWeight.w400), contentPadding: EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 12), suffixIcon: Icon(Icons.search)),
              itemBuilder: (context, index, Prediction prediction) {
                return Container(color: kWhite, padding: const EdgeInsets.all(10), child: Row(children: [const Icon(Icons.location_on), const SizedBox(width: 8), Expanded(child: Text(prediction.description ?? ""))]));
              },
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: MainButton(
              onPressed: () async {
                await _validateAndProceed();
              },
              child: const Text('Valider', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }
}
