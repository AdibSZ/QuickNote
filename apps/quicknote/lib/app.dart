import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quicknote_core/quicknote_core.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/ui_kit/ambient_glass_background.dart';
import 'features/responsive/presentation/screens/responsive_home_screen.dart';

class QuickNoteApp extends StatelessWidget {
  final NotesRepository repository;

  const QuickNoteApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<NotesDirectoryCubit>(
          create: (_) => NotesDirectoryCubit(repository)..loadNotes(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: TextRegistry.get(TextKey.appName),
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: AmbientGlassBackground(
              child: ResponsiveHomeScreen(repository: repository),
            ),
          );
        },
      ),
    );
  }
}
