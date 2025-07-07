import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/controllers/event_data.dart';
import 'package:kapstr/views/global/events/create/content.dart';
import 'package:kapstr/views/global/events/create/date/event_date_choice.dart';
import 'package:kapstr/views/global/events/create/date/precise_date_picker.dart';
import 'package:kapstr/views/global/events/create/man/man_infos.dart';
import 'package:kapstr/views/global/events/create/layout.dart';
import 'package:provider/provider.dart';

class GetEventDate extends StatefulWidget {
  const GetEventDate({super.key});

  @override
  GetEventDateState createState() => GetEventDateState();
}

class GetEventDateState extends State<GetEventDate> {
  late int selectedDay;
  late int selectedMonth;
  late int selectedYear;

  int selectedApproxDay = 1;
  int selectedApproxPeriod = 1;

  String dateAnswer = dateAnswers[0];

  String dropdownValue = '1 mois';
  List<String> periodItems = ['semaine', 'mois', 'année'];

  bool dropdownFilter = false;

  @override
  void initState() {
    super.initState();
    selectedDay = DateTime.now().day;
    selectedMonth = DateTime.now().month;
    selectedYear = DateTime.now().year;
  }

  void _updateSelectedDate() {
    final now = DateTime.now();
    final selectedDate = DateTime(selectedYear, selectedMonth, selectedDay);

    if (selectedDate.isBefore(now)) {
      setState(() {
        selectedDay = now.day;
        selectedMonth = now.month;
        selectedYear = now.year;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingData = context.read<EventDataController>();

    Future<void> confirm() async {
      // Mise à jour : vérifie si l'utilisateur connaît la date
      if (_isDateKnown()) {
        // L'utilisateur connaît la date, stocke la date sélectionnée
        onboardingData.eventDate = DateTime(selectedYear, selectedMonth, selectedDay).toString();
      } else {
        // L'utilisateur ne connaît pas la date, stocke une chaîne vide
        onboardingData.eventDate = DateTime(2000, 1, 1).toString();
      }
      // Passe à la page suivante
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ManInfosUI()));
    }

    return OnBoardingLayout(
      title: 'Date de l\'événement',
      confirm: confirm,
      children: [
        NewEventContent(
          middleContent: Column(
            children: [
              Column(
                children:
                    dateAnswers
                        .map(
                          (String answer) => EventDateChoice(
                            answer: answer,
                            isSelected: dateAnswer == answer,
                            onSelected: () {
                              setState(() {
                                dateAnswer = answer;
                              });
                            },
                            groupValue: dateAnswer,
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 24),
              _isDateKnown()
                  ? PreciseDatePicker(
                    selectedDay: selectedDay,
                    selectedMonth: selectedMonth,
                    selectedYear: selectedYear,
                    onDayChanged: (value) {
                      setState(() {
                        selectedDay = value;
                        _updateSelectedDate();
                      });
                    },
                    onMonthChanged: (value) {
                      setState(() {
                        selectedMonth = value;
                        _updateSelectedDate();
                      });
                    },
                    onYearChanged: (value) {
                      setState(() {
                        selectedYear = value;
                        _updateSelectedDate();
                      });
                    },
                  )
                  : const SizedBox(),
            ],
          ),
        ),
      ],
    );
  }

  bool _isDateKnown() {
    return dateAnswer == 'Je connais la date';
  }
}
