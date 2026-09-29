import 'package:equatable/equatable.dart';
import '../models/note.dart';

enum DirectoryTab { all, tags }

enum NoteSortOrder {
  updatedDesc,
  createdDesc,
  titleAsc,
}

class NotesDirectoryState extends Equatable {
  final List<Note> allNotes;
  final String searchQuery;
  final String selectedCategory; // 'All', 'Pinned', or any dynamic user category
  final String? selectedTag;
  final DirectoryTab activeTab;
  final bool isLoading;
  final NoteSortOrder sortOrder;

  const NotesDirectoryState({
    this.allNotes = const [],
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.selectedTag,
    this.activeTab = DirectoryTab.all,
    this.isLoading = false,
    this.sortOrder = NoteSortOrder.updatedDesc,
  });

  List<Note> get filteredNotes {
    final result = allNotes.where((note) {
      if (activeTab == DirectoryTab.tags) {
        // When in Tags tab, filter by selectedTag across all notes
        if (selectedTag != null && !note.tags.any((t) => t.toLowerCase() == selectedTag!.toLowerCase())) {
          return false;
        }
      } else {
        // Category filter in All Notes tab
        if (selectedCategory == 'Pinned' && !note.isPinned) {
          return false;
        } else if (selectedCategory != 'All' &&
            selectedCategory != 'Pinned' &&
            note.category.toLowerCase() != selectedCategory.toLowerCase()) {
          return false;
        }

        // Tag filter
        if (selectedTag != null && !note.tags.any((t) => t.toLowerCase() == selectedTag!.toLowerCase())) {
          return false;
        }
      }

      // Search query filter
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchTitle = note.title.toLowerCase().contains(q);
        final matchPreview = note.preview.toLowerCase().contains(q);
        final matchTags = note.tags.any((t) => t.toLowerCase().contains(q));
        final matchBlocks = note.blocks.any((b) => b.content.toLowerCase().contains(q));
        if (!matchTitle && !matchPreview && !matchTags && !matchBlocks) {
          return false;
        }
      }

      return true;
    }).toList();

    switch (sortOrder) {
      case NoteSortOrder.updatedDesc:
        result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case NoteSortOrder.createdDesc:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case NoteSortOrder.titleAsc:
        result.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
    }

    return result;
  }

  Set<String> get availableCategories {
    final cats = <String>{'All', 'Pinned'};
    for (final note in allNotes) {
      if (note.category.trim().isNotEmpty) {
        cats.add(note.category.trim());
      }
    }
    return cats;
  }

  Set<String> get availableTags {
    final tags = <String>{};
    for (final note in allNotes) {
      tags.addAll(note.tags);
    }
    return tags;
  }

  NotesDirectoryState copyWith({
    List<Note>? allNotes,
    String? searchQuery,
    String? selectedCategory,
    String? selectedTag,
    bool clearSelectedTag = false,
    DirectoryTab? activeTab,
    bool? isLoading,
    NoteSortOrder? sortOrder,
  }) {
    return NotesDirectoryState(
      allNotes: allNotes ?? this.allNotes,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedTag: clearSelectedTag ? null : (selectedTag ?? this.selectedTag),
      activeTab: activeTab ?? this.activeTab,
      isLoading: isLoading ?? this.isLoading,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [
        allNotes,
        searchQuery,
        selectedCategory,
        selectedTag,
        activeTab,
        isLoading,
        sortOrder,
      ];
}
