import 'package:equatable/equatable.dart';
import 'block_type.dart';

/// Represents an individual content block within an editor note.
class NoteBlock extends Equatable {
  final String id;
  final BlockType type;
  final String content;
  final Map<String, dynamic> metadata;

  const NoteBlock({
    required this.id,
    required this.type,
    required this.content,
    this.metadata = const {},
  });

  NoteBlock copyWith({
    String? id,
    BlockType? type,
    String? content,
    Map<String, dynamic>? metadata,
  }) {
    return NoteBlock(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'content': content,
      'metadata': metadata,
    };
  }

  factory NoteBlock.fromJson(Map<String, dynamic> json) {
    return NoteBlock(
      id: json['id'] as String,
      type: BlockType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BlockType.paragraph,
      ),
      content: json['content'] as String? ?? '',
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  @override
  List<Object?> get props => [id, type, content, metadata];
}
