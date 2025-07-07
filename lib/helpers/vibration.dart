import 'package:haptic_feedback/haptic_feedback.dart';

Future<void> triggerShortVibration() async {
  await Haptics.vibrate(HapticsType.soft);
}
