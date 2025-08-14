import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/helpers/sizer.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/widgets/layout/spacing.dart';
import 'package:numberpicker/numberpicker.dart';

class ModuleDatePicker extends StatefulWidget {
  const ModuleDatePicker({super.key, required this.module, required this.onDateSelected});

  final Module module;
  final Function(DateTime) onDateSelected;

  @override
  State<ModuleDatePicker> createState() => _ModuleDatePickerState();
}

class _ModuleDatePickerState extends State<ModuleDatePicker> {
  int? _currentDayValue;
  int? _currentMonthValue;
  int? _currentYearValue;
  int? _currentHourValue;
  int? _currentMinuteValue;

  void setModuleDate() {
    if (widget.module.date != null) {
      _currentDayValue = int.parse(widget.module.date!.day.toString());
      _currentMonthValue = int.parse(widget.module.date!.month.toString());
      _currentYearValue = int.parse(widget.module.date!.year.toString());
      _currentHourValue = int.parse(widget.module.date!.hour.toString());
      _currentMinuteValue = int.parse(widget.module.date!.minute.toString());
    } else {
      _currentDayValue = int.parse(DateTime.now().day.toString());
      _currentMonthValue = int.parse(DateTime.now().month.toString());
      _currentYearValue = int.parse(DateTime.now().year.toString());
      _currentHourValue = int.parse(DateTime.now().hour.toString());
      _currentMinuteValue = int.parse(DateTime.now().minute.toString());
    }
  }

  void _updateSelectedDate() {
    final now = DateTime.now();
    final selectedDate = DateTime(_currentYearValue!, _currentMonthValue!, _currentDayValue!);
    if (selectedDate.isBefore(now)) {
      if (_currentYearValue! < now.year) {
        setState(() {
          _currentYearValue = now.year;
        });
      } else if (_currentYearValue! == now.year && _currentMonthValue! < now.month) {
        setState(() {
          _currentMonthValue = now.month;
        });
      } else if (_currentYearValue! == now.year && _currentMonthValue! == now.month && _currentDayValue! < now.day) {
        setState(() {
          _currentDayValue = now.day;
        });
        if (_currentDayValue! == now.day && _currentHourValue! < now.hour && _currentMinuteValue! < now.minute) {
          setState(() {
            _currentHourValue = now.hour;
            _currentMinuteValue = now.minute;
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setModuleDate();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(color: kBlack, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Text('Date de l\'évènement', style: TextStyle(color: kWhite, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize)),
          smallSpacerH(context),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NumberPicker(
                  haptics: true,
                  itemWidth: 32,
                  textStyle: TextStyle(color: kLightWhiteTransparent2, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize),
                  selectedTextStyle: TextStyle(color: kWhite, fontSize: Theme.of(context).textTheme.titleMedium!.fontSize),
                  value: int.parse("0${_currentDayValue!}"),
                  minValue: 1,
                  maxValue: 31,
                  onChanged: (value) {
                    setState(() {
                      _currentDayValue = value;
                      _updateSelectedDate();
                      widget.onDateSelected(DateTime(_currentYearValue!, _currentMonthValue!, _currentDayValue!, _currentHourValue!, _currentMinuteValue!));
                    });
                  },
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.08, child: const VerticalDivider(thickness: 1, color: kWhite)),
                NumberPicker(
                  haptics: true,
                  itemWidth: 32,
                  textStyle: TextStyle(color: kLightWhiteTransparent2, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize),
                  selectedTextStyle: TextStyle(color: kWhite, fontSize: Theme.of(context).textTheme.titleMedium!.fontSize),
                  value: _currentMonthValue!,
                  minValue: 1,
                  maxValue: 12,
                  onChanged: (value) {
                    setState(() {
                      _currentMonthValue = value;
                      _updateSelectedDate();
                      widget.onDateSelected(DateTime(_currentYearValue!, _currentMonthValue!, _currentDayValue!, _currentHourValue!, _currentMinuteValue!));
                    });
                  },
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.08, child: const VerticalDivider(thickness: 1, color: kWhite)),
                NumberPicker(
                  haptics: true,
                  itemWidth: 64,
                  textStyle: TextStyle(color: kLightWhiteTransparent2, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize),
                  selectedTextStyle: TextStyle(color: kWhite, fontSize: Theme.of(context).textTheme.titleMedium!.fontSize),
                  value: _currentYearValue!,
                  minValue: 2023,
                  maxValue: 2099,
                  onChanged: (value) {
                    setState(() {
                      _currentYearValue = value;
                      _updateSelectedDate();
                      widget.onDateSelected(DateTime(_currentYearValue!, _currentMonthValue!, _currentDayValue!, _currentHourValue!, _currentMinuteValue!));
                    });
                  },
                ),
              ],
            ),
          ),
          largeSpacerH(context),
          Text('Horaire de l\'évènement', style: Sizer(context).scaleTextStyle(Theme.of(context).textTheme.bodyLarge!).copyWith(color: kWhite, fontWeight: FontWeight.w400)),
          largeSpacerH(context),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _DatePickerItem(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(border: Border.all(color: kWhite), borderRadius: BorderRadius.circular(14)),
                    child: CupertinoButton(
                      onPressed:
                          () => _showTimeDialog(
                            CupertinoDatePicker(
                              initialDateTime: DateTime(0, 0, 0, _currentHourValue!, _currentMinuteValue!),
                              mode: CupertinoDatePickerMode.time,
                              use24hFormat: true,
                              onDateTimeChanged: (DateTime newTime) {
                                setState(() {
                                  _currentHourValue = newTime.hour;
                                  _currentMinuteValue = newTime.minute;
                                  widget.onDateSelected(DateTime(_currentYearValue!, _currentMonthValue!, _currentDayValue!, _currentHourValue!, _currentMinuteValue!));
                                });
                              },
                            ),
                          ),
                      child: Text(_currentMinuteValue! < 10 ? '$_currentHourValue:0$_currentMinuteValue' : '$_currentHourValue:$_currentMinuteValue', style: TextStyle(fontSize: Theme.of(context).textTheme.titleLarge!.fontSize, color: kWhite)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTimeDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder:
          (BuildContext context) => Container(
            height: 216,
            padding: const EdgeInsets.only(top: 6.0),
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: Container(color: kWhite, child: SafeArea(bottom: false, top: false, child: child)),
          ),
    );
  }
}

class _DatePickerItem extends StatelessWidget {
  const _DatePickerItem({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(decoration: const BoxDecoration(), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: children)));
  }
}
