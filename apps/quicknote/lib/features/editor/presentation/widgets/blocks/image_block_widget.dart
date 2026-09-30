import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/ui_kit/tactile_feedback.dart';
import 'image_lightbox_modal.dart';

class ImageBlockWidget extends StatefulWidget {
  final NoteBlock block;
  final ValueChanged<String> onCaptionChanged;
  final VoidCallback onDelete;

  const ImageBlockWidget({
    super.key,
    required this.block,
    required this.onCaptionChanged,
    required this.onDelete,
  });

  @override
  State<ImageBlockWidget> createState() => _ImageBlockWidgetState();
}

class _ImageBlockWidgetState extends State<ImageBlockWidget> {
  late TextEditingController _captionCtrl;

  @override
  void initState() {
    super.initState();
    final caption = widget.block.metadata['caption'] as String? ?? '';
    _captionCtrl = TextEditingController(text: caption);
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  Widget _buildImageWidget(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, fit: BoxFit.cover, height: 220, width: double.infinity);
    } else if (kIsWeb) {
      return Image.network(path, fit: BoxFit.cover, height: 220, width: double.infinity);
    } else {
      return Image.file(File(path), fit: BoxFit.cover, height: 220, width: double.infinity);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final path = widget.block.content;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceContainerLow : AppColors.lightSurfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkHairlineBorder : AppColors.lightHairlineBorder,
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  TactileFeedback.light();
                  ImageLightboxModal.show(
                    context,
                    imagePath: path,
                    caption: _captionCtrl.text,
                  );
                },
                child: Hero(
                  tag: 'img-${widget.block.id}',
                  child: _buildImageWidget(path),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 16, color: Colors.white),
                    onPressed: () {
                      TactileFeedback.light();
                      widget.onDelete();
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.zoom_in, color: Colors.white, size: 13),
                      SizedBox(width: 4),
                      Text('Tap to zoom', style: TextStyle(color: Colors.white, fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: _captionCtrl,
              onChanged: (val) {
                widget.block.metadata['caption'] = val;
                widget.onCaptionChanged(val);
              },
              style: AppTypography.caption(onSurfaceVar, size: 12),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: 'Add an image caption...',
                hintStyle: AppTypography.caption(onSurfaceVar.withValues(alpha: 0.4), size: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
