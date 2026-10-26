import 'package:dnd_session/src/models/condition.dart';

/// Участник боя глазами игроков: только имя и место в очереди. Хиты и статблоки монстров, прозвища от мастера
/// игрокам не передаются.
class BattleEntry {
  /// `playerId` игрока или `id` монстра.
  final String id;
  final String name;
  final bool isPlayer;
  final int? initiative;

  /// Цвет метки монстра (`MonsterMarker.name` мастера: `red`, `blue`…), чтобы найти его миниатюру на столе.
  final String? marker;

  /// Выбыл: монстр без хитов или мёртвый персонаж.
  final bool isOut;

  /// Персонаж в нокауте — союзники могут привести его в чувство.
  final bool isKnockedOut;

  /// Эффекты видны всем за столом: «Гоблин 1 — сбит с ног».
  final List<StatusEffect> statuses;

  const BattleEntry({
    required this.id,
    required this.name,
    required this.isPlayer,
    this.initiative,
    this.marker,
    this.isOut = false,
    this.isKnockedOut = false,
    this.statuses = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (isPlayer) 'player': true,
    'initiative': ?initiative,
    'marker': ?marker,
    if (isOut) 'out': true,
    if (isKnockedOut) 'ko': true,
    if (statuses.isNotEmpty) 'statuses': statuses.map((e) => e.toJson()).toList(),
  };

  factory BattleEntry.fromJson(Map<String, dynamic> json) => BattleEntry(
    id: json['id'],
    name: json['name'],
    isPlayer: json['player'] ?? false,
    initiative: json['initiative'],
    marker: json['marker'],
    isOut: json['out'] ?? false,
    isKnockedOut: json['ko'] ?? false,
    statuses: StatusEffect.listFromJson(json['statuses']),
  );
}

/// Идущий бой: очередь ходов, раунд и чей ход.
class BattleSnapshot {
  final int round;
  final String? currentId;

  /// Участники в порядке ходов.
  final List<BattleEntry> entries;

  const BattleSnapshot({required this.round, required this.currentId, required this.entries});

  BattleEntry? get current => entries.where((e) => e.id == currentId).firstOrNull;

  /// Следующий после текущего, кто не выбыл.
  BattleEntry? get next {
    final index = entries.indexWhere((e) => e.id == currentId);
    if (index < 0) return null;
    for (var i = 1; i < entries.length; i++) {
      final entry = entries[(index + i) % entries.length];
      if (!entry.isOut) return entry;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'round': round,
    'current': ?currentId,
    'entries': entries.map((e) => e.toJson()).toList(),
  };

  factory BattleSnapshot.fromJson(Map<String, dynamic> json) => BattleSnapshot(
    round: json['round'],
    currentId: json['current'],
    entries: (json['entries'] as List).map((e) => BattleEntry.fromJson(e)).toList(),
  );
}
