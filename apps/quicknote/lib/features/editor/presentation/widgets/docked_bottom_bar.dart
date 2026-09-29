import 'package:flutter/material.dart';
import 'package:quicknote_core/quicknote_core.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui_kit/glass_icon_button.dart';
import '../../../../core/ui_kit/glass_pill_bar.dart';

class DockedBottomBar extends StatelessWidget {
  final VoidCallback onAddBlock;
  final VoidCallback onRecordVoice;
  final VoidCallback onInsertCode;
  final VoidCallback onAddChecklist;
  final VoidCallback onFormatText;

  const DockedBottomBar({
    super.key,
    required this.onAddBlock,
    required this.onRecordVoice,
    required this.onInsertCode,
    required this.onAddChecklist,
    required this.onFormatText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.paddingOf(context).bottom + 12,
      ),
      child: GlassPillBar(
        maxWidth: 360,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GlassIconButton(
              icon: Icon(Icons.add_circle_outline, size: 22, color: onSurface),
              tooltip: TextRegistry.get(TextKey.addBlock),
              onPressed: onAddBlock,
            ),
            GlassIconButton(
              icon: Icon(Icons.mic_none, size: 21, color: onSurface),
              tooltip: TextRegistry.get(TextKey.recordVoice),
              onPressed: onRecordVoice,
            ),
            GlassIconButton(
              icon: Icon(Icons.data_object, size: 21, color: onSurface),
              tooltip: TextRegistry.get(TextKey.insertCodeBlock),
              onPressed: onInsertCode,
            ),
            GlassIconButton(
              icon: Icon(Icons.check_box_outlined, size: 21, color: onSurface),
              tooltip: TextRegistry.get(TextKey.checklistTask),
              onPressed: onAddChecklist,
            ),
            GlassIconButton(
              icon: Icon(Icons.format_size, size: 21, color: onSurface),
              tooltip: TextRegistry.get(TextKey.textFormatting),
              onPressed: onFormatText,
            ),
          ],
        ),
      ),
    );
  }
}
