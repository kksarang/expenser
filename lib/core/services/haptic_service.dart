import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/widgets.dart';
import '../../presentation/providers/settings_provider.dart';

/// Reusable haptic feedback helper.
/// Checks the user's haptic setting before triggering vibration.
class HapticService {
  /// Light vibration — for add, update, save actions.
  static void triggerLight(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (settings.hapticEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  /// Medium vibration — for delete and destructive actions.
  static void triggerMedium(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (settings.hapticEnabled) {
      HapticFeedback.mediumImpact();
    }
  }
}
