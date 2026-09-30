import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quicknote_core/quicknote_core.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui_kit/app_emblem.dart';
import '../../../../core/ui_kit/glass_container.dart';
import '../../../directory/presentation/screens/notes_directory_screen.dart';
import '../../../directory/presentation/widgets/mobile_speed_dial_fab.dart';
import '../../../directory/presentation/widgets/spotlight_search_modal.dart';
import '../../../editor/presentation/screens/note_editor_screen.dart';
import '../../../security/presentation/widgets/note_security_modal.dart';
import '../../../settings/presentation/settings_modal.dart';
import '../widgets/empty_editor_placeholder.dart';
import '../widgets/sidebar_item.dart';

class ResponsiveHomeScreen extends StatefulWidget {
  final NotesRepository repository;

  const ResponsiveHomeScreen({super.key, required this.repository});

  @override
  State<ResponsiveHomeScreen> createState() => _ResponsiveHomeScreenState();
}

class _ResponsiveHomeScreenState extends State<ResponsiveHomeScreen> {
  Note? _activeNote;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): _handleCreateNewNote,
        const SingleActivator(LogicalKeyboardKey.keyN, meta: true): _handleCreateNewNote,
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () =>
            SpotlightSearchModal.show(context: context, onNoteSelected: (n) => setState(() => _activeNote = n), onNewNote: _handleCreateNewNote),
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () =>
            SpotlightSearchModal.show(context: context, onNoteSelected: (n) => setState(() => _activeNote = n), onNewNote: _handleCreateNewNote),
      },
      child: BlocBuilder<NotesDirectoryCubit, NotesDirectoryState>(
      builder: (context, state) {
        // Keep active note synchronized with latest state or reset if deleted
        if (_activeNote != null) {
          final matched = state.allNotes.where((n) => n.id == _activeNote!.id);
          if (matched.isNotEmpty) {
            _activeNote = matched.first;
          } else {
            _activeNote = state.allNotes.isNotEmpty ? state.allNotes.first : null;
          }
        }

        // On wide screens, auto-select first note if none selected
        if (_activeNote == null && state.allNotes.isNotEmpty && width >= 768) {
          _activeNote = state.allNotes.first;
        }

        if (width >= 1200) {
          return _buildDesktopLayout(context, state);
        } else if (width >= 768) {
          return _buildTabletLayout(context, state);
        } else {
          return _buildMobileLayout(context, state);
        }
      },
    ),
  );
}

  Widget _buildDesktopLayout(BuildContext context, NotesDirectoryState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          // Sidebar (240px)
          GlassContainer(
            borderRadius: BorderRadius.zero,
            width: 240,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            customBackground: isDark
                ? AppColors.darkSurfaceContainerLowest.withValues(alpha: 0.95)
                : AppColors.lightSurfaceContainerLow.withValues(alpha: 0.95),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const AppEmblem(size: 30),
                    const SizedBox(width: 10),
                    Text(TextRegistry.get(TextKey.appName), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 24),
                ResponsiveSidebarItem(
                  icon: Icons.notes,
                  label: TextRegistry.get(TextKey.allNotesTab),
                  count: state.allCount,
                  isSelected: state.selectedCategory == 'All',
                  onTap: () => context.read<NotesDirectoryCubit>().selectCategory('All'),
                ),
                ResponsiveSidebarItem(
                  icon: Icons.star_outline_rounded,
                  label: TextRegistry.get(TextKey.favoritesFilter),
                  count: state.favoritesCount,
                  isSelected: state.selectedCategory == 'Favorites',
                  onTap: () => context.read<NotesDirectoryCubit>().selectCategory('Favorites'),
                ),
                ResponsiveSidebarItem(
                  icon: Icons.push_pin_outlined,
                  label: TextRegistry.get(TextKey.pinnedFilter),
                  count: state.pinnedCount,
                  isSelected: state.selectedCategory == 'Pinned',
                  onTap: () => context.read<NotesDirectoryCubit>().selectCategory('Pinned'),
                ),
                ...state.availableCategories
                    .where((c) => c != 'All' && c != 'Pinned' && c != 'Favorites')
                    .map((cat) => ResponsiveSidebarItem(
                          icon: _iconForCategory(cat),
                          label: cat,
                          count: state.allNotes.where((n) => !n.isDeleted && n.category.toLowerCase() == cat.toLowerCase()).length,
                          isSelected: state.selectedCategory.toLowerCase() == cat.toLowerCase(),
                          onTap: () => context.read<NotesDirectoryCubit>().selectCategory(cat),
                        )),
                const Spacer(),
                ResponsiveSidebarItem(
                  icon: Icons.settings_outlined,
                  label: TextRegistry.get(TextKey.settingsTitle),
                  isSelected: false,
                  onTap: () => SettingsModal.show(context),
                ),
              ],
            ),
          ),
          // Directory Middle Pane
          SizedBox(
            width: 420,
            child: NotesDirectoryScreen(
              onNoteSelected: _selectNote,
              onNewNote: _handleCreateNewNote,
            ),
          ),
          const VerticalDivider(width: 1, thickness: 0.5),
          Expanded(child: _buildEditorStage(context)),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, NotesDirectoryState state) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          SizedBox(
            width: 360,
            child: NotesDirectoryScreen(
              onNoteSelected: _selectNote,
              onNewNote: _handleCreateNewNote,
            ),
          ),
          const VerticalDivider(width: 1, thickness: 0.5),
          Expanded(child: _buildEditorStage(context)),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, NotesDirectoryState state) {
    final isEditor = _activeNote != null;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, anim) {
        final isToEditor = child.key.toString().contains('editor');
        final offset = Tween<Offset>(
          begin: isToEditor ? const Offset(0.06, 0) : const Offset(-0.06, 0),
          end: Offset.zero,
        ).animate(anim);
        return FadeTransition(opacity: anim, child: SlideTransition(position: offset, child: child));
      },
      child: isEditor
          ? KeyedSubtree(
              key: ValueKey('editor-${_activeNote!.id}'),
              child: _buildEditorStage(context, onBack: _handleBack),
            )
          : KeyedSubtree(
              key: const ValueKey('directory'),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                floatingActionButton: MobileSpeedDialFab(
                  onNewTextNote: _handleCreateNewNote,
                  onNewChecklistNote: _handleCreateChecklistNote,
                  onNewAudioNote: _handleCreateAudioNote,
                ),
                body: NotesDirectoryScreen(
                  onNoteSelected: _selectNote,
                  onNewNote: _handleCreateNewNote,
                ),
              ),
            ),
    );
  }

  Widget _buildEditorStage(BuildContext context, {VoidCallback? onBack}) {
    if (_activeNote == null) return EmptyEditorPlaceholder(onCreateNote: _handleCreateNewNote);
    return BlocProvider(
      key: ValueKey(_activeNote!.id),
      create: (_) => NoteEditorCubit(note: _activeNote!, repository: widget.repository),
      child: NoteEditorScreen(
        onBack: onBack ?? () {},
        onDelete: () => _handleDeleteNote(_activeNote!.id),
      ),
    );
  }

  void _selectNote(Note note) {
    if (note.isLocked) {
      NoteSecurityModal.show(
        context,
        noteTitle: note.title,
        onAuthenticated: () {
          if (!mounted) return;
          setState(() => _activeNote = note);
        },
      );
    } else {
      setState(() => _activeNote = note);
    }
  }

  Future<void> _handleCreateNewNote() async {
    final note = await context.read<NotesDirectoryCubit>().createNewNote();
    if (!mounted) return;
    setState(() => _activeNote = note);
  }

  Future<void> _handleCreateChecklistNote() async {
    final note = await context.read<NotesDirectoryCubit>().createChecklistNote();
    if (!mounted) return;
    setState(() => _activeNote = note);
  }

  Future<void> _handleCreateAudioNote() async {
    final note = await context.read<NotesDirectoryCubit>().createVoiceMemoNote();
    if (!mounted) return;
    setState(() => _activeNote = note);
  }

  void _handleBack() {
    if (_activeNote != null) {
      final current = widget.repository.getNoteById(_activeNote!.id);
      if (current != null && current.isEffectivelyEmpty) {
        context.read<NotesDirectoryCubit>().deleteNote(current.id);
      }
    }
    setState(() => _activeNote = null);
  }

  Future<void> _handleDeleteNote(String id) async {
    final cubit = context.read<NotesDirectoryCubit>();
    await cubit.deleteNote(id);
    if (!mounted) return;
    final remaining = cubit.state.allNotes;
    setState(() => _activeNote = remaining.isNotEmpty ? remaining.first : null);
  }

  IconData _iconForCategory(String cat) {
    final c = cat.toLowerCase();
    if (c == 'architecture') return Icons.account_tree_outlined;
    if (c.contains('strategy') || c == 'ideas') return Icons.lightbulb_outline;
    if (c.contains('audio')) return Icons.mic_none_outlined;
    if (c == 'swiftui' || c == 'code') return Icons.terminal_outlined;
    if (c == 'work' || c == 'business') return Icons.work_outline;
    if (c == 'personal') return Icons.person_outline;
    return Icons.folder_outlined;
  }
}
