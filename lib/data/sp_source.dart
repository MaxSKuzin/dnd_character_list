import 'dart:convert';

import 'package:dnd_character_list/domain/models/player.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

@preResolve
@singleton
class SpSource {
  final BehaviorSubject<List<Player>> _playersSubject = BehaviorSubject.seeded([]);
  Stream<List<Player>> get playersStream => _playersSubject;

  static const _playersKey = 'players';

  final SharedPreferences _sharedPreferences;

  SpSource._(this._sharedPreferences);

  @factoryMethod
  static Future<SpSource> init() async {
    final sp = await SharedPreferences.getInstance();
    return SpSource._(sp);
  }

  Future<void> savePlayer(Player player) async {
    final rawSavedPlayers = _sharedPreferences.getStringList(_playersKey) ?? [];
    var savedPlayers = rawSavedPlayers.map((e) => Player.fromJson(jsonDecode(e))).toList();
    final mainClass = player.classes.firstWhere((e) => e.isMain);
    final name = player.personality.name;
    savedPlayers = savedPlayers
        .map((e) =>
            e.personality.name == name && e.classes.firstWhere((e) => e.isMain).runtimeType == mainClass.runtimeType
                ? player
                : e)
        .toList();
    if (savedPlayers.isEmpty) {
      savedPlayers.add(player);
    }
    await _sharedPreferences.setStringList(
      _playersKey,
      savedPlayers.map((e) => jsonEncode(e.toJson())).toList(),
    );
    _playersSubject.add(getSavedPlayers());
  }

  void loadPlayers() {
    _playersSubject.add(getSavedPlayers());
  }

  List<Player> getSavedPlayers() {
    final rawPlayers = _sharedPreferences.getStringList(_playersKey) ?? [];

    return rawPlayers.map((e) => Player.fromJson(jsonDecode(e))).toList();
  }

  Future<void> removePlayer(Player player) async {
    final savedPlayers = _sharedPreferences.getStringList(_playersKey) ?? [];
    savedPlayers.remove(jsonEncode(player.toJson()));
    await _sharedPreferences.setStringList(_playersKey, savedPlayers);
    _playersSubject.add(getSavedPlayers());
  }
}
