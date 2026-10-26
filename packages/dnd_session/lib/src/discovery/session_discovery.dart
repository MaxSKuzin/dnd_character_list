import 'dart:async';
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:dnd_session/src/protocol/session_message.dart';

/// Тип сервиса Bonjour/mDNS. На iOS он же указывается в `NSBonjourServices` в Info.plist обоих приложений.
const sessionServiceType = '_dndsession._tcp';

/// Найденная в сети сессия мастера или адрес, введённый вручную.
class SessionInfo {
  final String name;
  final String host;
  final int port;

  const SessionInfo({required this.name, required this.host, required this.port});

  Uri get uri => Uri(scheme: 'ws', host: host, port: port, path: '/session');

  /// «192.168.1.5:4040».
  String get address => '$host:$port';

  @override
  bool operator ==(Object other) =>
      other is SessionInfo && name == other.name && host == other.host && port == other.port;

  @override
  int get hashCode => Object.hash(name, host, port);

  @override
  String toString() => '$name ($address)';
}

/// Объявляет сессию мастера в локальной сети.
abstract interface class SessionAdvertiser {
  Future<void> start({required String name, required int port});

  Future<void> stop();
}

/// Ищет сессии мастера в локальной сети.
abstract interface class SessionDiscovery {
  /// Текущий список найденных сессий. Поиск идёт, пока есть подписчик.
  Stream<List<SessionInfo>> get sessions;
}

class BonjourSessionAdvertiser implements SessionAdvertiser {
  BonsoirBroadcast? _broadcast;

  @override
  Future<void> start({required String name, required int port}) async {
    await stop();
    final broadcast = BonsoirBroadcast(
      service: BonsoirService(
        name: name,
        type: sessionServiceType,
        port: port,
        attributes: {'v': '$sessionProtocolVersion'},
      ),
    );
    _broadcast = broadcast;
    await broadcast.initialize();
    await broadcast.start();
  }

  @override
  Future<void> stop() async {
    final broadcast = _broadcast;
    _broadcast = null;
    if (broadcast != null && !broadcast.isStopped) await broadcast.stop();
  }
}

class BonjourSessionDiscovery implements SessionDiscovery {
  @override
  Stream<List<SessionInfo>> get sessions {
    BonsoirDiscovery? discovery;
    StreamSubscription<BonsoirDiscoveryEvent>? subscription;
    final found = <String, SessionInfo>{};
    late final StreamController<List<SessionInfo>> controller;

    void emit() => controller.add(found.values.toList());

    controller = StreamController<List<SessionInfo>>(
      onListen: () async {
        controller.add(const []);
        final current = BonsoirDiscovery(type: sessionServiceType);
        discovery = current;
        try {
          await current.initialize();
          subscription = current.eventStream?.listen((event) {
            switch (event) {
              case BonsoirDiscoveryServiceFoundEvent(:final service):
                // Сервисы другой версии протокола не показываем: мастер всё равно отклонит подключение.
                if (service.attributes['v'] == '$sessionProtocolVersion') service.resolve(current.serviceResolver);
              case BonsoirDiscoveryServiceResolvedEvent(:final service) ||
                  BonsoirDiscoveryServiceUpdatedEvent(:final service):
                final host = _preferredAddress(service.hostAddresses) ?? service.hostname;
                if (host == null) return;
                found[service.name] = SessionInfo(name: service.name, host: host, port: service.port);
                emit();
              case BonsoirDiscoveryServiceLostEvent(:final service):
                if (found.remove(service.name) != null) emit();
              default:
            }
          });
          await current.start();
        } catch (error, stackTrace) {
          if (!controller.isClosed) controller.addError(error, stackTrace);
        }
      },
      onCancel: () async {
        await subscription?.cancel();
        final current = discovery;
        if (current != null && !current.isStopped) await current.stop();
      },
    );
    return controller.stream;
  }

  /// IPv4 удобнее: его можно показать игроку и вставить в адрес без скобок.
  static String? _preferredAddress(List<String> addresses) {
    final parsed = addresses.map(InternetAddress.tryParse).nonNulls;
    return (parsed.where((e) => e.type == InternetAddressType.IPv4).firstOrNull ??
            parsed.where((e) => !e.isLinkLocal).firstOrNull)
        ?.address;
  }
}
