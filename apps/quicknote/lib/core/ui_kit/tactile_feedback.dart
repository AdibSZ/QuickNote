import 'package:flutter/services.dart';

/// Centralized tactile feedback manager delivering Apple-grade haptic clicks.
class TactileFeedback {
  static void click() {
    HapticFeedback.selectionClick();
  }

  static void selection() {
    HapticFeedback.selectionClick();
  }

  static void light() {
    HapticFeedback.lightImpact();
  }

  static void medium() {
    HapticFeedback.mediumImpact();
  }

  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  static void success() {
    HapticFeedback.mediumImpact();
  }
}
