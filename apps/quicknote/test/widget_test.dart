import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quicknote/app.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import 'package:quicknote_storage/quicknote_storage.dart';

void main() {
  testWidgets('QuickNote app boots empty, allows creating and editing notes', (WidgetTester tester) async {
    final persister = DeltaFlushPersister(primaryMemory: InMemoryStorageDriver());
    final repository = InProcessNotesRepository(persister);
    await repository.init();

    await tester.pumpWidget(QuickNoteApp(repository: repository));
    await tester.pumpAndSettle();

    // App header & empty state renders
    expect(find.text('QuickNote'), findsWidgets);
    expect(find.text('No notes found'), findsWidgets);

    // Click "New Note"
    final newNoteBtn = find.text('New Note');
    expect(newNoteBtn, findsWidgets);
    await tester.tap(newNoteBtn.first);
    await tester.pumpAndSettle();

    // Now in editor: Title is editable
    expect(find.byType(TextField), findsWidgets);

    // Tap and edit title
    final titleField = find.byType(TextField).first;
    await tester.enterText(titleField, 'My Personal Note');
    await tester.pumpAndSettle();

    expect(find.text('My Personal Note'), findsWidgets);

    // Tap Add Block in docked bar
    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle();

    // Tap Checklist in docked bar
    await tester.tap(find.byIcon(Icons.check_box_outlined).last);
    await tester.pumpAndSettle();

    expect(find.text('Task description...'), findsWidgets);
  });
}
