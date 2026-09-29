import 'package:flutter/material.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import 'package:quicknote_storage/quicknote_storage.dart';
import 'app.dart';
import 'core/storage/shared_preferences_storage_driver.dart';

void main() async {
  // Fulfill sub-100ms bootstrap mandate: minimal synchronous operations on main thread.
  WidgetsFlutterBinding.ensureInitialized();

  // Instant in-memory driver backed by non-blocking delta flush disk storage.
  final memoryDriver = InMemoryStorageDriver();
  final diskDriver = SharedPreferencesStorageDriver();

  final persister = DeltaFlushPersister(
    primaryMemory: memoryDriver,
    underlyingDisk: diskDriver,
  );

  final repository = InProcessNotesRepository(persister);
  await repository.init();

  runApp(QuickNoteApp(repository: repository));
}
