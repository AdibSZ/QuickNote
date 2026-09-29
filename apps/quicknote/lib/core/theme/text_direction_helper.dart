import 'package:flutter/material.dart';

/// Detects whether text starts with RTL (Persian, Arabic, Hebrew) characters.
/// Defaults to false on empty strings so English placeholders stay clean and natural.
bool isRtlText(String text, {bool defaultIfEmpty = false}) {
  if (text.trim().isEmpty) return defaultIfEmpty;
  for (final rune in text.runes) {
    // Skip whitespace, numbers, and common markdown/punctuation symbols
    if (rune <= 0x0040 || (rune >= 0x005B && rune <= 0x0060) || (rune >= 0x007B && rune <= 0x00BF)) {
      continue;
    }
    // Arabic/Persian range (0x0600 - 0x08FF, 0xFB50 - 0xFDFF, 0xFE70 - 0xFEFF)
    // Hebrew range (0x0590 - 0x05FF)
    if ((rune >= 0x0590 && rune <= 0x08FF) ||
        (rune >= 0xFB1D && rune <= 0xFDFF) ||
        (rune >= 0xFE70 && rune <= 0xFEFF)) {
      return true;
    }
    // Latin / English characters
    if ((rune >= 0x0041 && rune <= 0x005A) || (rune >= 0x0061 && rune <= 0x007A)) {
      return false;
    }
  }
  return defaultIfEmpty;
}

TextDirection getTextDirection(String text, {bool defaultIfEmpty = false}) {
  return isRtlText(text, defaultIfEmpty: defaultIfEmpty) ? TextDirection.rtl : TextDirection.ltr;
}

TextAlign getTextAlign(String text, {TextAlign fallback = TextAlign.left, bool defaultIfEmpty = false}) {
  return isRtlText(text, defaultIfEmpty: defaultIfEmpty) ? TextAlign.right : fallback;
}
