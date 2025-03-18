import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/custom_svg_picture.dart';
import 'package:provider/provider.dart';

// Enumération pour les types de disposition
enum DispositionType { grid, linear, slider, column, circle, card }

class DispoButton extends StatefulWidget {
  const DispoButton({super.key});

  @override
  State<DispoButton> createState() => _DispoButtonState();
}

class _DispoButtonState extends State<DispoButton> {
  DispositionType _currentDisposition = DispositionType.grid;

  @override
  void initState() {
    super.initState();
    _currentDisposition = _dispositionFromString(Event.instance.blocDisposition);
  }

  DispositionType _dispositionFromString(String disposition) {
    switch (disposition) {
      case 'grid':
        return DispositionType.grid;
      case 'linear':
        return DispositionType.linear;
      case 'slider':
        return DispositionType.slider;
      case 'column':
        return DispositionType.column;
      case 'circle':
        return DispositionType.circle;
      case 'card':
        return DispositionType.card;
      default:
        // Vous pourriez soit retourner une valeur par défaut, soit lancer une erreur si la chaîne ne correspond à aucune disposition.
        return DispositionType.grid; // ou throw FlutterError('Invalid disposition type');
    }
  }

  void _updateDisposition(DispositionType type) async {
    setState(() {
      _currentDisposition = type;
    });
    Event.instance.blocDisposition = type.toString().split('.').last;
    context.read<EventsController>().updateEvent(Event.instance);

    if (!mounted) return;
    await context.read<EventsController>().updateEventField(key: 'bloc_disposition', value: type.toString().split('.').last);
  }

  String _iconPath(DispositionType disposition) {
    switch (disposition) {
      case DispositionType.grid:
        return 'assets/icons/grid.svg';
      case DispositionType.linear:
        return 'assets/icons/linear.svg';
      case DispositionType.slider:
        return 'assets/icons/slider.svg';
      case DispositionType.column:
        return 'assets/icons/column.svg';
      case DispositionType.circle:
        return 'assets/icons/circle.svg';
      case DispositionType.card:
        return 'assets/icons/card.svg';
      default:
        return 'assets/icons/grid.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      backgroundColor: Colors.transparent,
      foregroundColor: kYellow,
      elevation: 0,
      overlayColor: Colors.transparent,
      overlayOpacity: 0,
      direction: SpeedDialDirection.down,
      children:
          DispositionType.values
              .where((type) => type != _currentDisposition)
              .map(
                (type) => SpeedDialChild(
                  child: CustomAssetSvgPicture(_iconPath(type), width: 24, height: 24, color: Event.instance.buttonColor == '' ? kYellow : Color(int.parse('0xFF${Event.instance.buttonColor}'))),
                  backgroundColor: Colors.transparent,
                  onTap: () => _updateDisposition(type),
                  elevation: 0,
                  foregroundColor: kYellow,
                ),
              )
              .toList(),
      // L'icône principale affichera l'icône de la disposition actuelle
      child: CustomAssetSvgPicture(_iconPath(_currentDisposition), width: 24, height: 24, color: Event.instance.buttonColor == '' ? kYellow : Color(int.parse('0xFF${Event.instance.buttonColor}'))),
    );
  }
}
