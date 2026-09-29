import 'package:flutter/material.dart';
import '../../../../core/theme/text_direction_helper.dart';
import '../../../../core/ui_kit/tactile_feedback.dart';

class NoteMetadataDialogs {
  static void showChangeCategory({
    required BuildContext context,
    required String currentCategory,
    required Set<String> existingCategories,
    required ValueChanged<String> onSelected,
  }) {
    TactileFeedback.click();
    final controller = TextEditingController(text: currentCategory);
    final activeSuggestions = existingCategories.where((c) => c.isNotEmpty).toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Category', style: TextStyle(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              textDirection: isRtlText(controller.text) ? TextDirection.rtl : TextDirection.ltr,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'e.g. Work, Personal, Ideas...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            if (activeSuggestions.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Active Categories:', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: activeSuggestions.map((cat) {
                  return ActionChip(
                    label: Text(cat, style: const TextStyle(fontSize: 11)),
                    onPressed: () {
                      controller.text = cat;
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final val = controller.text.trim();
              if (val.isNotEmpty) {
                onSelected(val);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  static void showAddTag({
    required BuildContext context,
    required List<String> currentTags,
    required Set<String> existingTags,
    required ValueChanged<List<String>> onTagsChanged,
  }) {
    TactileFeedback.click();
    final controller = TextEditingController();
    final availableSuggestions = existingTags
        .where((t) => !currentTags.map((e) => e.toLowerCase()).contains(t.toLowerCase()))
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Tag', style: TextStyle(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'e.g. swiftui, design, notes',
                prefixText: '#',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (val) {
                Navigator.pop(ctx);
                final tag = val.trim().replaceAll('#', '').toLowerCase();
                if (tag.isNotEmpty && !currentTags.contains(tag)) {
                  onTagsChanged([...currentTags, tag]);
                }
              },
            ),
            if (availableSuggestions.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Existing Tags:', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: availableSuggestions.map((tag) {
                  return ActionChip(
                    label: Text('#$tag', style: const TextStyle(fontSize: 11)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      onTagsChanged([...currentTags, tag]);
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final tag = controller.text.trim().replaceAll('#', '').toLowerCase();
              if (tag.isNotEmpty && !currentTags.contains(tag)) {
                onTagsChanged([...currentTags, tag]);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
