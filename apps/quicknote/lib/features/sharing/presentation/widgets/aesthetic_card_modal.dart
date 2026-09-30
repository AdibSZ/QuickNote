import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui_kit/app_emblem.dart';
import '../../../../core/ui_kit/tactile_feedback.dart';

enum CardThemePreset { aurora, sunset, emerald, oled }

class AestheticCardModal extends StatefulWidget {
  final Note note;

  const AestheticCardModal({super.key, required this.note});

  static void show(BuildContext context, Note note) {
    TactileFeedback.light();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AestheticCardModal(note: note),
    );
  }

  @override
  State<AestheticCardModal> createState() => _AestheticCardModalState();
}

class _AestheticCardModalState extends State<AestheticCardModal> {
  CardThemePreset _preset = CardThemePreset.aurora;

  List<Color> _getGradient(CardThemePreset preset) {
    switch (preset) {
      case CardThemePreset.aurora:
        return const [Color(0xFF2E0854), Color(0xFF1E1B4B), Color(0xFF0F172A)];
      case CardThemePreset.sunset:
        return const [Color(0xFF431407), Color(0xFF7C2D12), Color(0xFF1C1917)];
      case CardThemePreset.emerald:
        return const [Color(0xFF022C22), Color(0xFF064E3B), Color(0xFF0F172A)];
      case CardThemePreset.oled:
        return const [Color(0xFF000000), Color(0xFF111827), Color(0xFF030712)];
    }
  }

  Color _getAccent(CardThemePreset preset) {
    switch (preset) {
      case CardThemePreset.aurora:
        return const Color(0xFFA855F7);
      case CardThemePreset.sunset:
        return const Color(0xFFF97316);
      case CardThemePreset.emerald:
        return const Color(0xFF10B981);
      case CardThemePreset.oled:
        return const Color(0xFF38BDF8);
    }
  }

  void _copyCardContent() {
    TactileFeedback.selection();
    final text = '✨ ${widget.note.title.isEmpty ? "Note" : widget.note.title}\n\n'
        '${widget.note.toPlainText()}\n\n'
        '#${widget.note.category} • QuickNote';
    Clipboard.setData(ClipboardData(text: text));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Aesthetic card copied to clipboard ✨'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _getGradient(_preset);
    final accent = _getAccent(_preset);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12, width: 0.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Share as Aesthetic Card', style: AppTypography.title(Colors.white, size: 16)),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Theme Presets Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: CardThemePreset.values.map((p) {
              final isSel = _preset == p;
              final pAcc = _getAccent(p);
              return GestureDetector(
                onTap: () {
                  TactileFeedback.selection();
                  setState(() => _preset = p);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: pAcc,
                    border: Border.all(
                      color: isSel ? Colors.white : Colors.transparent,
                      width: isSel ? 2.5 : 0,
                    ),
                    boxShadow: isSel ? [BoxShadow(color: pAcc.withValues(alpha: 0.5), blurRadius: 10)] : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // The Aesthetic Card Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withValues(alpha: 0.35), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: accent.withValues(alpha: 0.4), width: 0.5),
                      ),
                      child: Text(
                        widget.note.category,
                        style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '${widget.note.updatedAt.year}/${widget.note.updatedAt.month}/${widget.note.updatedAt.day}',
                      style: const TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  widget.note.title.isEmpty ? 'Untitled Note' : widget.note.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.note.preview.isEmpty ? 'Quick thoughts & notes' : widget.note.preview,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const AppEmblem(size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'QuickNote • Hyper-fast Notes',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _copyCardContent,
              icon: const Icon(Icons.share_outlined, size: 18),
              label: const Text('Share & Copy Card Text'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
