import 'package:flutter/material.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui_kit/tactile_feedback.dart';

class SlashCommandSheet {
  static void show(BuildContext context, NoteEditorCubit cubit) {
    TactileFeedback.click();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final commands = [
      _SlashItem(
        icon: Icons.notes,
        title: 'Paragraph',
        subtitle: 'Plain text with rich typography',
        type: BlockType.paragraph,
      ),
      _SlashItem(
        icon: Icons.title,
        title: 'Heading',
        subtitle: 'Large section header',
        type: BlockType.heading2,
      ),
      _SlashItem(
        icon: Icons.check_box_outlined,
        title: 'Checklist / To-Do',
        subtitle: 'Interactive task item with progress',
        type: BlockType.checklist,
        metadata: {'isChecked': false},
      ),
      _SlashItem(
        icon: Icons.lightbulb_outline,
        title: 'Callout Highlight',
        subtitle: 'Frosted accent box with custom icon',
        type: BlockType.callout,
        metadata: {'icon': '💡', 'tint': 'amber'},
      ),
      _SlashItem(
        icon: Icons.format_quote_rounded,
        title: 'Quote',
        subtitle: 'Italic blockquote with accent bar',
        type: BlockType.quote,
      ),
      _SlashItem(
        icon: Icons.data_object,
        title: 'Code Block',
        subtitle: 'Monospaced snippet with copy action',
        type: BlockType.codeBlock,
        content: '// Write code here\n',
        metadata: {'language': 'DART'},
      ),
      _SlashItem(
        icon: Icons.mic_none,
        title: 'Voice Memo',
        subtitle: 'Apple Voice Memos audio recording',
        type: BlockType.audioMemo,
        content: 'Voice Note',
        metadata: {'durationSeconds': 0},
      ),
      _SlashItem(
        icon: Icons.horizontal_rule,
        title: 'Divider',
        subtitle: 'Subtle hairline separator',
        type: BlockType.divider,
      ),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.7,
            maxWidth: 520,
          ),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceContainerHighest.withValues(alpha: 0.98)
                : AppColors.lightSurfaceContainerHighest.withValues(alpha: 0.98),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppColors.darkHairlineBorder : AppColors.lightHairlineBorder,
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.add_circle_outline, size: 18, color: primary),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Insert Block',
                        style: AppTypography.title(onSurface, size: 16, weight: FontWeight.w600),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 18, color: onSurfaceVar),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: commands.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final item = commands[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        TactileFeedback.light();
                        Navigator.pop(ctx);
                        cubit.addBlock(
                          item.type,
                          content: item.content ?? '',
                          metadata: item.metadata,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkSurfaceContainerLow
                                    : AppColors.lightSurfaceContainerLow,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                  width: 0.5,
                                ),
                              ),
                              child: Icon(item.icon, size: 20, color: primary),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: AppTypography.body(onSurface, size: 14, weight: FontWeight.w600),
                                  ),
                                  Text(
                                    item.subtitle,
                                    style: AppTypography.caption(onSurfaceVar, size: 11),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, size: 16, color: onSurfaceVar.withValues(alpha: 0.4)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SlashItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final BlockType type;
  final String? content;
  final Map<String, dynamic>? metadata;

  _SlashItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.type,
    this.content,
    this.metadata,
  });
}
