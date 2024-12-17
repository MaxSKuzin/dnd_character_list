import 'dart:convert';

import 'package:dnd_character_list/domain/models/player.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@preResolve
@singleton
class SpSource {
  static const _playersKey = 'players';

  final SharedPreferences _sharedPreferences;

  SpSource._(this._sharedPreferences);

  @factoryMethod
  static Future<SpSource> init() async {
    final sp = await SharedPreferences.getInstance();
    return SpSource._(sp);
  }

  Future<void> savePlayer(Player player) async {
    final savedPlayers = _sharedPreferences.getStringList(_playersKey) ?? [];
    savedPlayers.add(jsonEncode(player.toJson()));
    await _sharedPreferences.setStringList(_playersKey, savedPlayers);
  }

  List<Player> getSavedPlayers() {
    final rawPlayers = _sharedPreferences.getStringList(_playersKey) ?? [];
    return rawPlayers.map((e) => Player.fromJson(jsonDecode(e))).toList();
  }

  Future<void> removePlayer(Player player) async {
    final savedPlayers = _sharedPreferences.getStringList(_playersKey) ?? [];
    savedPlayers.remove(jsonEncode(player.toJson()));
    await _sharedPreferences.setStringList(_playersKey, savedPlayers);
  }
}
