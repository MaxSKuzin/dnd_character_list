import 'package:dnd_master/data/encounters_repository.dart';
import 'package:dnd_master/domain/models/encounter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Подготовленные боевые ситуации. Каждое изменение сразу сохраняется.
class EncountersCubit extends Cubit<List<Encounter>> {
  final EncountersRepository _repository;

  EncountersCubit(this._repository) : super(_repository.load());

  /// Новая или изменённая ситуация (по `id`).
  Future<void> save(Encounter encounter) async {
    final exists = state.any((e) => e.id == encounter.id);
    final encounters = exists ? state.map((e) => e.id == encounter.id ? encounter : e).toList() : [...state, encounter];
    emit(encounters);
    await _repository.save(encounters);
  }

  Future<void> remove(String id) async {
    final encounters = state.where((e) => e.id != id).toList();
    emit(encounters);
    await _repository.save(encounters);
  }

  static String newId() => DateTime.now().microsecondsSinceEpoch.toRadixString(36);
}
