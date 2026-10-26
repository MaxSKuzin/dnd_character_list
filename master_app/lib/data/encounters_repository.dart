import 'dart:convert';

import 'package:dnd_master/domain/models/encounter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Подготовленные боевые ситуации в SharedPreferences (JSON). Без миграций: при смене формата старые
/// ситуации, которые не удалось разобрать, пропускаются.
class EncountersRepository {
  static const _key = 'encounters';

  final SharedPreferences _sp;

  EncountersRepository(this._sp);

  static Future<EncountersRepository> init() async => EncountersRepository(await SharedPreferences.getInstance());

  List<Encounter> load() {
    final raw = _sp.getStringList(_key) ?? const [];
    final encounters = <Encounter>[];
    for (final e in raw) {
      try {
        encounters.add(Encounter.fromJson(jsonDecode(e)));
      } catch (_) {}
    }
    return encounters;
  }

  Future<void> save(List<Encounter> encounters) =>
      _sp.setStringList(_key, encounters.map((e) => jsonEncode(e.toJson())).toList());
}
