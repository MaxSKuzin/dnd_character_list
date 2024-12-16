import 'package:dnd_character_list/presentation/extensions/theme_extensions.dart';
import 'package:dnd_character_list/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final _appRouter = AppRouter();

  @override
  void dispose() {
    _appRouter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        extensions: [
          CustomColors(
            cardColor: const Color.fromARGB(255, 29, 31, 48),
          ),
        ],
        // fontFamily: 'Inkulinati',
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            side: const BorderSide(
              color: Colors.white,
            ),
            backgroundColor: const Color.fromARGB(255, 29, 31, 48),
            foregroundColor: Colors.white,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(
              color: Colors.white,
            ),
            foregroundColor: Colors.white,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 29, 31, 48),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routerConfig: _appRouter.config(),
    );
  }
}
