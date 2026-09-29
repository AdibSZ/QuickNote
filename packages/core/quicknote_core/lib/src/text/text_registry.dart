import 'text_key.dart';

/// Centralized registry providing localized text.
/// Fulfills the system mandate: Zero hardcoded user strings.
class TextRegistry {
  static const Map<TextKey, String> _enStrings = {
    TextKey.appName: 'QuickNote',
    TextKey.directoryTitle: 'Directory',
    TextKey.notesCount: '{count} notes',
    TextKey.allNotesTab: 'All Notes',
    TextKey.tagsTab: 'Tags',
    TextKey.searchPlaceholder: 'Search notes, blocks, audio transcripts...',
    TextKey.pinnedFilter: 'Pinned',
    TextKey.architectureFilter: 'Architecture',
    TextKey.strategyFilter: 'Strategy 2025',
    TextKey.audioMemosFilter: 'Audio Memos',
    TextKey.swiftUiFilter: 'SwiftUI',
    TextKey.savedToDevice: 'Saved to Device',
    TextKey.holdToReorder: 'Hold to reorder',
    TextKey.noteArchitecture: 'Note Architecture',
    TextKey.editedToday: 'Edited Today at {time}',
    TextKey.wordsCount: '{count} words',
    TextKey.holdAndDragTooltip: 'Hold & Drag to reorder',
    TextKey.boldTooltip: 'Bold',
    TextKey.italicTooltip: 'Italic',
    TextKey.linkTooltip: 'Link',
    TextKey.heading2Tooltip: 'Heading 2',
    TextKey.inlineCodeTooltip: 'Inline Code',
    TextKey.aiPolishTooltip: 'AI Polish',
    TextKey.dictationMemoTitle: 'Dictation Memo #04',
    TextKey.playRecording: 'Play recording',
    TextKey.copyCode: 'Copy',
    TextKey.copiedCode: 'Copied!',
    TextKey.addBlock: 'Add Block',
    TextKey.recordVoice: 'Record Voice',
    TextKey.insertCodeBlock: 'Insert Code Block',
    TextKey.checklistTask: 'Checklist Task',
    TextKey.textFormatting: 'Text Formatting',
    TextKey.emptyNotesTitle: 'No notes found',
    TextKey.emptyNotesSubtitle: 'Create a new note or adjust your search filter.',
    TextKey.newNoteButton: 'New Note',
    TextKey.settingsTitle: 'Settings',
    TextKey.lightMode: 'Light Mode',
    TextKey.darkMode: 'Dark Mode',
    TextKey.systemMode: 'System',
    TextKey.deleteNote: 'Delete',
    TextKey.pinNote: 'Pin Note',
    TextKey.unpinNote: 'Unpin Note',
    TextKey.saveChanges: 'Save Changes',
  };

  static String get(TextKey key, {Map<String, String>? params}) {
    String text = _enStrings[key] ?? key.name;
    if (params != null && params.isNotEmpty) {
      params.forEach((placeholder, value) {
        text = text.replaceAll('{$placeholder}', value);
      });
    }
    return text;
  }
}
