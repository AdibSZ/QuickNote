import 'package:flutter/material.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../core/theme/text_direction_helper.dart';
import '../../../../core/ui_kit/tactile_feedback.dart';

enum ZenTheme { oled, sepia, forest, paper }

class ZenModeModal extends StatefulWidget {
  final Note note;

  const ZenModeModal({super.key, required this.note});

  static void show(BuildContext context, Note note) {
    TactileFeedback.medium();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, anim1, anim2) => ZenModeModal(note: note),
        transitionsBuilder: (context, anim, secondaryAnim, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  State<ZenModeModal> createState() => _ZenModeModalState();
}

class _ZenModeModalState extends State<ZenModeModal> {
  ZenTheme _theme = ZenTheme.oled;
  double _fontSize = 17.0;

  Color _getBg(ZenTheme t) {
    switch (t) {
      case ZenTheme.oled:
        return const Color(0xFF000000);
      case ZenTheme.sepia:
        return const Color(0xFFF4ECD8);
      case ZenTheme.forest:
        return const Color(0xFF141F1A);
      case ZenTheme.paper:
        return const Color(0xFFFFFFFF);
    }
  }

  Color _getTextColor(ZenTheme t) {
    switch (t) {
      case ZenTheme.oled:
        return const Color(0xFFE4E4E7);
      case ZenTheme.sepia:
        return const Color(0xFF433422);
      case ZenTheme.forest:
        return const Color(0xFFD1E7DD);
      case ZenTheme.paper:
        return const Color(0xFF18181B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = _getBg(_theme);
    final fg = _getTextColor(_theme);
    final words = widget.note.wordCount;
    final readingMin = (words / 180).ceil().clamp(1, 60);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Minimal Zen Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: fg.withValues(alpha: 0.6)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  // Font Size Adjusters
                  IconButton(
                    icon: Icon(Icons.text_decrease, size: 20, color: fg.withValues(alpha: 0.7)),
                    onPressed: () {
                      TactileFeedback.light();
                      if (_fontSize > 13) setState(() => _fontSize -= 1.5);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.text_increase, size: 22, color: fg.withValues(alpha: 0.7)),
                    onPressed: () {
                      TactileFeedback.light();
                      if (_fontSize < 28) setState(() => _fontSize += 1.5);
                    },
                  ),
                  const SizedBox(width: 8),
                  // Theme Selector
                  ...ZenTheme.values.map((t) {
                    final isSel = _theme == t;
                    return GestureDetector(
                      onTap: () {
                        TactileFeedback.selection();
                        setState(() => _theme = t);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getBg(t),
                          border: Border.all(
                            color: isSel ? fg : fg.withValues(alpha: 0.25),
                            width: isSel ? 2 : 1,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            // Reading Stats Bar
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'حالت ذن • $words کلمه • حدود $readingMin دقیقه مطالعه',
                style: TextStyle(color: fg.withValues(alpha: 0.4), fontSize: 11),
              ),
            ),
            const Divider(height: 1, thickness: 0.3),
            // Distraction-Free Reading Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.note.title.isEmpty ? 'Untitled Note' : widget.note.title,
                      textDirection: getTextDirection(widget.note.title, defaultIfEmpty: true),
                      style: TextStyle(
                        color: fg,
                        fontSize: _fontSize + 8,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...widget.note.blocks.where((b) => b.type != BlockType.title).map((block) {
                      final content = block.content;
                      final isRtl = isRtlText(content);
                      final dir = isRtl ? TextDirection.rtl : TextDirection.ltr;

                      switch (block.type) {
                        case BlockType.paragraph:
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Text(
                              content,
                              textDirection: dir,
                              style: TextStyle(color: fg.withValues(alpha: 0.9), fontSize: _fontSize, height: 1.7),
                            ),
                          );
                        case BlockType.heading2:
                          return Padding(
                            padding: const EdgeInsets.only(top: 14, bottom: 8),
                            child: Text(
                              content,
                              textDirection: dir,
                              style: TextStyle(color: fg, fontSize: _fontSize + 4, fontWeight: FontWeight.bold, height: 1.4),
                            ),
                          );
                        case BlockType.checklist:
                          final checked = block.metadata['isChecked'] == true;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  checked ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                  color: checked ? Colors.green : fg.withValues(alpha: 0.4),
                                  size: _fontSize + 2,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    content,
                                    textDirection: dir,
                                    style: TextStyle(
                                      color: checked ? fg.withValues(alpha: 0.4) : fg,
                                      fontSize: _fontSize,
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
                              border: Border(right: BorderSide(color: fg.withValues(alpha: 0.4), width: 3)),
                            ),
                            child: Text(
                              content,
                              textDirection: dir,
                              style: TextStyle(color: fg.withValues(alpha: 0.9), fontSize: _fontSize - 1, fontStyle: FontStyle.italic, height: 1.6),
                            ),
                          );
                        default:
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(content, textDirection: dir, style: TextStyle(color: fg, fontSize: _fontSize)),
                          );
                      }
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
