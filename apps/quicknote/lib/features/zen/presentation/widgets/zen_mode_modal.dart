import 'package:flutter/material.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../core/theme/text_direction_helper.dart';
import '../../../../core/ui_kit/tactile_feedback.dart';
import 'zen_block_builder.dart';

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
                'Zen Mode • $words words • ~$readingMin min read',
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.note.title.isEmpty ? 'Untitled Note' : widget.note.title,
                      textDirection: isRtlText(widget.note.title) ? TextDirection.rtl : TextDirection.ltr,
                      textAlign: isRtlText(widget.note.title) ? TextAlign.right : TextAlign.left,
                      style: TextStyle(
                        color: fg,
                        fontSize: _fontSize + 8,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...widget.note.blocks.where((b) => b.type != BlockType.title).map((block) {
                      return ZenBlockBuilder.buildBlock(block, fg, _fontSize);
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
