import 'dart:async';
import 'dart:convert';
import 'package:quicknote_storage/quicknote_storage.dart';
import '../models/note.dart';

abstract class NotesRepository {
  Future<void> init();
  List<Note> getAllNotes();
  Stream<List<Note>> get notesStream;
  Note? getNoteById(String id);
  Future<void> saveNote(Note note);
  Future<void> deleteNote(String id);
  Future<void> togglePin(String id);
  Future<void> clearAllNotes();
  void dispose();
}

class InProcessNotesRepository implements NotesRepository {
  final DeltaFlushPersister _persister;
  final Map<String, Note> _memoryCache = {};
  final StreamController<List<Note>> _notesStreamController = StreamController<List<Note>>.broadcast();
  static const String _indexKey = 'quicknote_all_note_ids';

  InProcessNotesRepository(this._persister);

  @override
  Stream<List<Note>> get notesStream => _notesStreamController.stream;

  @override
  Future<void> init() async {
    await _persister.init();
    final idsJson = _persister.read(_indexKey);
    if (idsJson != null) {
      try {
        final List<dynamic> ids = jsonDecode(idsJson);
        for (final id in ids) {
          final noteRaw = _persister.read('note_$id');
          if (noteRaw != null) {
            final note = Note.fromJson(jsonDecode(noteRaw));
            // Filter out old default/mock notes if present
            if (!_isMockNoteId(note.id)) {
              _memoryCache[note.id] = note;
            } else {
              _persister.remove('note_$id');
            }
          }
        }
      } catch (_) {}
    }

    _saveIndex();
  }

  bool _isMockNoteId(String id) {
    return id == 'note-arch-v24' ||
        id == 'note-board-brief' ||
        id == 'note-design-audit' ||
        id == 'note-swiftui-pipeline';
  }

  void _saveIndex() {
    _persister.put(_indexKey, jsonEncode(_memoryCache.keys.toList()));
    if (!_notesStreamController.isClosed) {
      _notesStreamController.add(getAllNotes());
    }
  }

  @override
  List<Note> getAllNotes() {
    return _memoryCache.values.toList()
      ..sort((a, b) {
        if (a.isPinned != b.isPinned) {
          return a.isPinned ? -1 : 1;
        }
        return b.updatedAt.compareTo(a.updatedAt);
      });
  }

  @override
  Note? getNoteById(String id) => _memoryCache[id];

  @override
  Future<void> saveNote(Note note) async {
    _memoryCache[note.id] = note;
    _persister.put('note_${note.id}', jsonEncode(note.toJson()));
    _saveIndex();
  }

  @override
  Future<void> deleteNote(String id) async {
    _memoryCache.remove(id);
    _persister.remove('note_$id');
    _saveIndex();
  }

  @override
  Future<void> togglePin(String id) async {
    final note = _memoryCache[id];
    if (note != null) {
      final updated = note.copyWith(isPinned: !note.isPinned, updatedAt: DateTime.now());
      await saveNote(updated);
    }
  }

  @override
  Future<void> clearAllNotes() async {
    final keys = List<String>.from(_memoryCache.keys);
    for (final id in keys) {
      _persister.remove('note_$id');
    }
    _memoryCache.clear();
    _saveIndex();
  }

  @override
  void dispose() {
    _notesStreamController.close();
  }
}
