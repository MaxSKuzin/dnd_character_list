import 'package:dnd_master/data/master_session_source.dart';
import 'package:dnd_master/presentation/start_session_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MasterApp(source: MasterSessionSource()));
}

class MasterApp extends StatelessWidget {
  final MasterSessionSource source;

  const MasterApp({super.key, required this.source});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DnD Мастер',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 29, 31, 48),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: StartSessionScreen(source: source),
    );
  }
}
