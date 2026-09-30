import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:quicknote_core/quicknote_core.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import 'core/localization/locale_cubit.dart';
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
        BlocProvider<LocaleCubit>(create: (_) => LocaleCubit()),
        BlocProvider<NotesDirectoryCubit>(
          create: (_) => NotesDirectoryCubit(repository)..loadNotes(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) {
              final isFa = locale.languageCode == 'fa';
              return MaterialApp(
                title: TextRegistry.get(TextKey.appName),
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                locale: locale,
                supportedLocales: const [
                  Locale('en'),
                  Locale('fa'),
                ],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                builder: (context, child) {
                  return Directionality(
                    textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
                    child: child ?? const SizedBox.shrink(),
                  );
                },
                home: AmbientGlassBackground(
                  child: ResponsiveHomeScreen(repository: repository),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
