import 'package:dnd_master/data/encounters_repository.dart';
import 'package:dnd_master/data/master_session_source.dart';
import 'package:dnd_master/domain/bloc/battle_cubit.dart';
import 'package:dnd_master/domain/bloc/encounters_cubit.dart';
import 'package:dnd_master/presentation/start_session_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final encounters = await EncountersRepository.init();
  runApp(MasterApp(source: MasterSessionSource(), encounters: encounters));
}

class MasterApp extends StatelessWidget {
  final MasterSessionSource source;
  final EncountersRepository encounters;

  const MasterApp({super.key, required this.source, required this.encounters});

  @override
  Widget build(BuildContext context) {
    // Кубиты над MaterialApp, чтобы были доступны на всех экранах и в модальных окнах.
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => EncountersCubit(encounters)),
        BlocProvider(create: (_) => BattleCubit(source)),
      ],
      child: MaterialApp(
        title: 'DnD Мастер',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 29, 31, 48),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: StartSessionScreen(source: source),
      ),
    );
  }
}
