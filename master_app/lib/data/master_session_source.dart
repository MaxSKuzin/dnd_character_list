import 'package:dnd_session/dnd_session.dart';

/// Сессия мастера в локальной сети: игроки находят её поиском или подключаются по адресу.
///
/// ```dart
/// await source.start('Пещера');   // запустить и объявить в сети
/// source.playersStream            // игроки и их боевые данные при каждом изменении
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

  /// Адреса вида «192.168.1.5:4040» для подключения вручную, если поиск в сети у игрока не работает.
  Future<List<String>> addresses() async {
    final port = _host.port;
    if (port == null) return const [];
    return (await SessionHost.localAddresses()).map((e) => '$e:$port').toList();
  }
}
