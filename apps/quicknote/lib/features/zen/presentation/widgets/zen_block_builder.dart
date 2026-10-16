import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../core/theme/text_direction_helper.dart';
import '../../../editor/presentation/widgets/blocks/doodle_canvas_modal.dart';

class ZenBlockBuilder {
  static Widget buildBlock(NoteBlock block, Color fg, double fontSize) {
    final content = block.content;
    final isRtl = isRtlText(content);
    final dir = isRtl ? TextDirection.rtl : TextDirection.ltr;
    final align = isRtl ? TextAlign.right : TextAlign.left;

    switch (block.type) {
      case BlockType.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(
            content,
            textDirection: dir,
            textAlign: align,
            style: TextStyle(color: fg.withValues(alpha: 0.9), fontSize: fontSize, height: 1.7),
          ),
        );
      case BlockType.heading2:
        return Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 8),
          child: Text(
            content,
            textDirection: dir,
            textAlign: align,
            style: TextStyle(color: fg, fontSize: fontSize + 4, fontWeight: FontWeight.bold, height: 1.4),
          ),
        );
      case BlockType.checklist:
        final checked = block.metadata['isChecked'] == true;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            textDirection: dir,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                checked ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: checked ? Colors.green : fg.withValues(alpha: 0.4),
                size: fontSize + 2,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  content,
                  textDirection: dir,
                  textAlign: align,
                  style: TextStyle(
                    color: checked ? fg.withValues(alpha: 0.4) : fg,
                    fontSize: fontSize,
                    decoration: checked ? TextDecoration.lineThrough : null,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      case BlockType.quote:
      case BlockType.callout:
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: fg.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: isRtl
                ? Border(right: BorderSide(color: fg.withValues(alpha: 0.4), width: 3))
                : Border(left: BorderSide(color: fg.withValues(alpha: 0.4), width: 3)),
          ),
          child: Text(
            content,
            textDirection: dir,
            textAlign: align,
            style: TextStyle(color: fg.withValues(alpha: 0.9), fontSize: fontSize - 1, fontStyle: FontStyle.italic, height: 1.6),
          ),
        );
      case BlockType.image:
        final caption = block.metadata['caption'] as String? ?? '';
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildZenImage(content),
              ),
              if (caption.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    caption,
                    textDirection: isRtlText(caption) ? TextDirection.rtl : TextDirection.ltr,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: fg.withValues(alpha: 0.6), fontSize: 12),
                  ),
                ),
            ],
          ),
        );
      case BlockType.codeBlock:
        final lang = block.metadata['language'] as String? ?? 'CODE';
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: fg.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(lang, style: TextStyle(color: fg.withValues(alpha: 0.4), fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(content, textDirection: TextDirection.ltr, style: TextStyle(fontFamily: 'monospace', color: fg, fontSize: fontSize - 2)),
            ],
          ),
        );
      case BlockType.doodle:
        final strokes = DoodleStroke.parseStrokes(content);
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          height: 180,
          decoration: BoxDecoration(
            color: fg.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CustomPaint(
              painter: DoodlePainter(strokes, fit: true),
              size: Size.infinite,
            ),
          ),
        );
      case BlockType.audioMemo:
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: fg.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            textDirection: dir,
            children: [
              Icon(Icons.mic, color: fg.withValues(alpha: 0.7), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  content.isEmpty ? 'Audio Memo' : content,
                  textDirection: dir,
                  textAlign: align,
                  style: TextStyle(color: fg, fontSize: fontSize, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        );
      case BlockType.divider:
        return Divider(color: fg.withValues(alpha: 0.2), height: 24, thickness: 1);
      default:
        if (content.trim().isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(content, textDirection: dir, textAlign: align, style: TextStyle(color: fg, fontSize: fontSize)),
        );
    }
  }

  static Widget _buildZenImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://') || kIsWeb) {
      return Image.network(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
    }
    return Image.file(File(path), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
  }
}
