import 'package:dnd_session/dnd_session.dart';

/// Сессия мастера в локальной сети: игроки находят её поиском или подключаются по адресу.
///
/// ```dart
/// await source.start('Пещера');   // запустить и объявить в сети
/// source.playersStream            // игроки и их боевые данные при каждом изменении
/// source.setBattle(snapshot)     // очередь боя на устройствах игроков
/// source.initiatives             // инициатива, которую игроки ввели у себя
/// await source.stop();            // завершить: игроки отключаются
/// ```
class MasterSessionSource {
  final SessionHost _host;

  MasterSessionSource({SessionHost? host}) : _host = host ?? SessionHost(advertiser: BonjourSessionAdvertiser());

  bool get isRunning => _host.isRunning;

  String? get name => _host.name;

  List<SessionPlayer> get players => _host.players;

  Stream<List<SessionPlayer>> get playersStream => _host.playersStream;

  Future<void> start(String name) => _host.start(name: name);

  Future<void> stop() => _host.stop();

  Future<void> removePlayer(String id) => _host.removePlayer(id);

  /// Показывает игрокам идущий бой; `null` — боя нет.
  void setBattle(BattleSnapshot? battle) => _host.setBattle(battle);

  /// Урон (отрицательное [delta]) или лечение персонажа на устройстве игрока. `false` — игрок не на связи.
  bool changePlayerHits(String playerId, int delta) => _host.changeHits(playerId, delta);

  /// Приводит в чувство персонажа в нокауте. `false` — игрок не на связи.
  bool revivePlayer(String playerId) => _host.revive(playerId, by: 'Мастер');

  /// Эффекты на персонаже — игрок видит их у себя.
  void setPlayerStatuses(String playerId, List<StatusEffect> statuses) => _host.setStatuses(playerId, statuses);

  /// Просит игроков бросить инициативу.
  void requestInitiative(Iterable<String> playerIds) => _host.requestInitiative(playerIds);

  /// Результаты бросков инициативы, которые игроки ввели у себя.
  Stream<({String playerId, int value})> get initiatives => _host.initiatives;

  /// Адреса вида «192.168.1.5:4040» для подключения вручную, если поиск в сети у игрока не работает.
  Future<List<String>> addresses() async {
    final port = _host.port;
    if (port == null) return const [];
    return (await SessionHost.localAddresses()).map((e) => '$e:$port').toList();
  }
}
