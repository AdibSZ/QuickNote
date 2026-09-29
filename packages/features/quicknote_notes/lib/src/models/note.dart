import 'package:equatable/equatable.dart';
import 'block_type.dart';
import 'note_block.dart';

/// Represents a Note containing metadata and modular content blocks.
class Note extends Equatable {
  final String id;
  final String title;
  final String preview;
  final String category;
  final List<String> tags;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? color;
  final bool isFavorite;
  final bool isLocked;
  final bool isDeleted;
  final List<NoteBlock> blocks;

  const Note({
    required this.id,
    required this.title,
    required this.preview,
    required this.category,
    this.tags = const [],
    this.isPinned = false,
    this.color,
    this.isFavorite = false,
    this.isLocked = false,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.blocks = const [],
  });

  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# $title\n');
    if (category.isNotEmpty) buffer.writeln('**Category:** $category  ');
    if (tags.isNotEmpty) buffer.writeln('**Tags:** ${tags.map((t) => '#$t').join(' ')}\n');
    for (final block in blocks) {
      switch (block.type) {
        case BlockType.title:
          break;
        case BlockType.heading2:
          buffer.writeln('## ${block.content}\n');
          break;
        case BlockType.paragraph:
          buffer.writeln('${block.content}\n');
          break;
        case BlockType.checklist:
          final isChecked = block.metadata['isChecked'] == true;
          buffer.writeln('- [${isChecked ? 'x' : ' '}] ${block.content}');
          break;
        case BlockType.callout:
          final icon = block.metadata['icon'] as String? ?? '💡';
          buffer.writeln('> $icon **${block.content}**\n');
          break;
        case BlockType.quote:
          buffer.writeln('> *${block.content}*\n');
          break;
        case BlockType.divider:
          buffer.writeln('---\n');
          break;
        case BlockType.codeBlock:
          final lang = block.metadata['language'] ?? '';
          buffer.writeln('```$lang\n${block.content}\n```\n');
          break;
        case BlockType.audioMemo:
          buffer.writeln('> 🎙️ **${block.content}** (${block.metadata['duration'] ?? ''})');
          if (block.metadata['transcript'] != null) {
            buffer.writeln('> "${block.metadata['transcript']}"');
          }
          buffer.writeln();
          break;
        case BlockType.diagram:
          buffer.writeln('```\n[SQLite WAL] -> [CRDT Core] -> [Cloud]\n```\n*${block.content}*\n');
          break;
      }
    }
    return buffer.toString().trim();
  }

  String toPlainText() {
    final buffer = StringBuffer();
    if (title.isNotEmpty) buffer.writeln(title);
    for (final block in blocks) {
      if (block.type == BlockType.title) continue;
      if (block.content.trim().isNotEmpty) {
        buffer.writeln(block.content.trim());
      }
    }
    return buffer.toString().trim();
  }

  int get wordCount {
    int count = 0;
    for (final block in blocks) {
      final words = block.content.trim().split(RegExp(r'\s+'));
      if (words.isNotEmpty && words.first.isNotEmpty) {
        count += words.length;
      }
    }
    return count;
  }

  bool get isEffectivelyEmpty {
    final hasTitle = title.trim().isNotEmpty && title.trim() != 'Untitled Note';
    final hasContent = blocks
        .where((b) => b.type != BlockType.title)
        .any((b) => b.content.trim().isNotEmpty);
    final hasAudio = blocks.any((b) => b.type == BlockType.audioMemo);
    return !hasTitle && !hasContent && !hasAudio;
  }

  Note copyWith({
    String? id,
    String? title,
    String? preview,
    String? category,
    List<String>? tags,
    bool? isPinned,
    String? color,
    bool? isFavorite,
    bool? isLocked,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<NoteBlock>? blocks,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      preview: preview ?? this.preview,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      color: color ?? this.color,
      isFavorite: isFavorite ?? this.isFavorite,
      isLocked: isLocked ?? this.isLocked,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      blocks: blocks ?? this.blocks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'preview': preview,
      'category': category,
      'tags': tags,
      'isPinned': isPinned,
      'color': color,
      'isFavorite': isFavorite,
      'isLocked': isLocked,
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'blocks': blocks.map((b) => b.toJson()).toList(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      preview: json['preview'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      tags: List<String>.from(json['tags'] as List? ?? []),
      isPinned: json['isPinned'] as bool? ?? false,
      color: json['color'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isLocked: json['isLocked'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      blocks: (json['blocks'] as List? ?? [])
          .map((e) => NoteBlock.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        preview,
        category,
        tags,
        isPinned,
        color,
        isFavorite,
        isLocked,
        isDeleted,
        createdAt,
        updatedAt,
        blocks,
      ];
}
