import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'screens/root_shell.dart';
import 'state/profile_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  try {
    await FlutterDisplayMode.setHighRefreshRate();
  } catch (e) {
    debugPrint('Failed to set high refresh rate: $e');
  }
  runApp(const SudokuApp());
}

class SudokuApp extends StatefulWidget {
  const SudokuApp({super.key});

  @override
  State<SudokuApp> createState() => _SudokuAppState();
}

class _SudokuAppState extends State<SudokuApp> {
  final ProfileState _profile = ProfileState();

  @override
  Widget build(BuildContext context) {
    return ProfileScope(
      profile: _profile,
      child: AnimatedBuilder(
        animation: _profile,
        builder: (context, _) {
          return MaterialApp(
            title: 'Sudoku',
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(),
            darkTheme: buildAppDarkTheme(),
            themeMode: _profile.darkMode ? ThemeMode.dark : ThemeMode.light,
            home: const RootShell(),
          );
        },
      ),
    );
  }
}
