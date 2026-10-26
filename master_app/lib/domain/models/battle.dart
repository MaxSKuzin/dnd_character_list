import 'dart:math';

import 'package:dnd_master/domain/models/encounter.dart';
import 'package:dnd_master/domain/models/monster.dart';
import 'package:dnd_session/dnd_session.dart';

/// Цветная метка, чтобы различать одинаковых монстров: как кольцо на подставке миниатюры или фишка на карте.
enum MonsterMarker { red, blue, green, yellow, purple, orange, white, black }

/// Монстр в бою — экземпляр шаблона со своими хитами.
class BattleMonster {
  final String id;
  final MonsterTemplate template;

  /// Номер среди монстров того же вида: «Гоблин 3».
  final int number;
  final MonsterMarker marker;

  /// Прозвище от мастера: «с луком», «вожак». `null` — без прозвища.
  final String? label;
  final int maxHits;
  final int currentHits;

  const BattleMonster({
    required this.id,
    required this.template,
    required this.number,
    required this.marker,
    this.label,
    required this.maxHits,
    required this.currentHits,
  });

  BattleMonster _copyWith({MonsterMarker? marker, String? Function()? label, int? currentHits}) => BattleMonster(
    id: id,
    template: template,
    number: number,
    marker: marker ?? this.marker,
    label: label == null ? this.label : label(),
    maxHits: maxHits,
    currentHits: currentHits ?? this.currentHits,
  );

  BattleMonster withHits(int hits) => _copyWith(currentHits: hits.clamp(0, maxHits));
}

/// Участник боя: игрок из сессии или монстр мастера.
sealed class Combatant {
  const Combatant();

  /// `playerId` игрока или `id` монстра — ключ инициативы.
  String get id;

  String get name;

  int get initiativeBonus;

  int get armorClass;

  int get currentHits;

  int get maxHits;

  /// Пропускает ли участник ход. Монстр с 0 хитов выбывает; игрок с 0 хитов ходит — бросает спасброски
  /// от смерти.
  bool get isOut;

  /// Эффекты от мастера: состояния и свои.
  List<StatusEffect> get statuses;
}

class PlayerCombatant extends Combatant {
  final SessionPlayer player;

  @override
  final List<StatusEffect> statuses;

  const PlayerCombatant(this.player, {this.statuses = const []});

  @override
  String get id => player.id;

  @override
  String get name => player.profile.name;

  @override
  int get initiativeBonus => player.profile.initiative;

  @override
  int get armorClass => player.profile.armorClass;

  @override
  int get currentHits => player.state.currentHits;

  @override
  int get maxHits => player.profile.maxHits;

  @override
  bool get isOut => player.state.isDead;
}

class MonsterCombatant extends Combatant {
  final BattleMonster monster;

  /// В бою несколько монстров этого вида — к имени добавляется номер.
  final bool numbered;

  @override
  final List<StatusEffect> statuses;

  const MonsterCombatant(this.monster, {required this.numbered, this.statuses = const []});

  @override
  String get id => monster.id;

  /// «Гоблин 2», с прозвищем — «Гоблин 2 «с луком»».
  @override
  String get name => monster.label == null ? publicName : '$publicName «${monster.label}»';

  /// Имя для игроков — без прозвища мастера («вожак» может быть спойлером).
  String get publicName => numbered ? '${monster.template.name} ${monster.number}' : monster.template.name;

  @override
  int get initiativeBonus => monster.template.initiative;

  @override
  int get armorClass => monster.template.armorClass;

  @override
  int get currentHits => monster.currentHits;

  @override
  int get maxHits => monster.maxHits;

  @override
  bool get isOut => monster.currentHits <= 0;
}

/// Бой одной боевой ситуации: монстры, инициатива и чей ход. Игроки берутся из сессии и участвуют во всех боях.
class Battle {
  /// `id` подготовленной ситуации или [freeId].
  final String id;
  final String name;
  final List<BattleMonster> monsters;

  /// Результат броска инициативы по `id` участника.
  final Map<String, int> initiative;

  /// Жребий на случай равных инициативы и бонуса: порядок таких участников случайный, но выбирается один раз,
  /// когда у участника появляется инициатива, и дальше не меняется.
  final Map<String, int> tiebreaks;

  /// 0 — бой ещё не начат.
  final int round;

  /// Чей ход. Хранится `id`, а не позиция: участники могут добавляться и выбывать посреди раунда.
  final String? currentId;

  /// Эффекты по `id` участника — игроков и монстров этого боя.
  final Map<String, List<StatusEffect>> statuses;

  /// Счётчик для `id` новых монстров.
  final int _nextMonsterId;

  /// Счётчик для `id` новых эффектов.
  final int _nextStatusId;

  /// Бой без подготовки: монстры добавляются по ходу.
  static const freeId = 'free';

  const Battle({
    required this.id,
    required this.name,
    this.monsters = const [],
    this.initiative = const {},
    this.tiebreaks = const {},
    this.round = 0,
    this.currentId,
    this.statuses = const {},
    int nextMonsterId = 0,
    int nextStatusId = 0,
  }) : _nextMonsterId = nextMonsterId,
       _nextStatusId = nextStatusId;

  factory Battle.free() => const Battle(id: freeId, name: 'Свободный бой');

  /// Монстры ситуации со средними хитами из статблока.
  factory Battle.fromEncounter(Encounter encounter) {
    var battle = Battle(id: encounter.id, name: encounter.name);
    for (final group in encounter.monsters) {
      final template = group.template;
      if (template != null) battle = battle.addMonster(template, count: group.count);
    }
    return battle;
  }

  bool get isStarted => round > 0;

  Battle _copyWith({
    String? name,
    List<BattleMonster>? monsters,
    Map<String, int>? initiative,
    Map<String, int>? tiebreaks,
    int? round,
    String? Function()? currentId,
    Map<String, List<StatusEffect>>? statuses,
    int? nextMonsterId,
    int? nextStatusId,
  }) => Battle(
    id: id,
    name: name ?? this.name,
    monsters: monsters ?? this.monsters,
    initiative: initiative ?? this.initiative,
    tiebreaks: tiebreaks ?? this.tiebreaks,
    round: round ?? this.round,
    currentId: currentId == null ? this.currentId : currentId(),
    statuses: statuses ?? this.statuses,
    nextMonsterId: nextMonsterId ?? _nextMonsterId,
    nextStatusId: nextStatusId ?? _nextStatusId,
  );

  Battle rename(String name) => _copyWith(name: name);

  /// Участники по убыванию инициативы; при равенстве — по бонусу инициативы, при равном бонусе — по жребию
  /// ([tiebreaks]). Без брошенной инициативы — в конце: сначала игроки, потом монстры в порядке добавления.
  List<Combatant> order(List<SessionPlayer> players) {
    final combatants = [
      ...players.map((e) => PlayerCombatant(e, statuses: statuses[e.id] ?? const [])),
      ...monsters.map(
        (e) => MonsterCombatant(
          e,
          numbered: monsters.where((m) => m.template.id == e.template.id).length > 1,
          statuses: statuses[e.id] ?? const [],
        ),
      ),
    ];
    final position = {for (final (i, e) in combatants.indexed) e.id: i};
    combatants.sort((a, b) {
      final ia = initiative[a.id];
      final ib = initiative[b.id];
      if (ia != null && ib != null && ia != ib) return ib - ia;
      if (ia != null && ib == null) return -1;
      if (ia == null && ib != null) return 1;
      if (ia != null && a.initiativeBonus != b.initiativeBonus) return b.initiativeBonus - a.initiativeBonus;
      if (ia != null) {
        final byLot = (tiebreaks[b.id] ?? 0) - (tiebreaks[a.id] ?? 0);
        if (byLot != 0) return byLot;
      }
      return position[a.id]! - position[b.id]!;
    });
    return combatants;
  }

  Battle addMonster(MonsterTemplate template, {int count = 1}) {
    final last = monsters.where((e) => e.template.id == template.id).fold(0, (n, e) => max(n, e.number));
    return _copyWith(
      monsters: [
        ...monsters,
        for (var i = 0; i < count; i++)
          BattleMonster(
            id: 'm${_nextMonsterId + i}',
            template: template,
            number: last + i + 1,
            // Разные метки по порядку номеров: у первых восьми гоблинов цвета не повторяются.
            marker: MonsterMarker.values[(last + i) % MonsterMarker.values.length],
            maxHits: template.averageHits,
            currentHits: template.averageHits,
          ),
      ],
      nextMonsterId: _nextMonsterId + count,
    );
  }

  /// Убирает монстра. Если сейчас его ход, ход переходит к следующему.
  Battle removeMonster(String id, List<SessionPlayer> players) {
    final battle = currentId == id ? nextTurn(players) : this;
    return battle._copyWith(
      monsters: monsters.where((e) => e.id != id).toList(),
      initiative: {...initiative}..remove(id),
      tiebreaks: {...tiebreaks}..remove(id),
      statuses: {...battle.statuses}..remove(id),
      currentId: battle.currentId == id ? () => null : null,
    );
  }

  /// Урон — отрицательное [delta], лечение — положительное. Хиты в пределах от 0 до максимума.
  Battle changeMonsterHits(String id, int delta) =>
      _copyWith(monsters: monsters.map((e) => e.id == id ? e.withHits(e.currentHits + delta) : e).toList());

  /// Метка и прозвище монстра. Пустое прозвище убирает его.
  Battle markMonster(String id, {required MonsterMarker marker, required String? label}) {
    final trimmed = label?.trim();
    return _copyWith(
      monsters: monsters
          .map(
            (e) => e.id == id ? e._copyWith(marker: marker, label: () => trimmed?.isEmpty ?? true ? null : trimmed) : e,
          )
          .toList(),
    );
  }

  /// Результат броска инициативы. [random] нужен для жребия при равенстве — участник тянет его один раз.
  Battle setInitiative(String id, int value, Random random) => _copyWith(
    initiative: {...initiative, id: value},
    tiebreaks: tiebreaks.containsKey(id) ? null : {...tiebreaks, id: _lot(random)},
  );

  /// Бросает к20 + бонус инициативы за монстров без инициативы. Это единственный бросок приложения: игроки
  /// бросают кубики сами, мастер вводит результат ([setInitiative]), урон тоже вводится вручную.
  Battle rollMonsterInitiative(Random random) {
    var battle = this;
    for (final monster in monsters) {
      if (initiative.containsKey(monster.id)) continue;
      battle = battle.setInitiative(monster.id, random.nextInt(20) + 1 + monster.template.initiative, random);
    }
    return battle;
  }

  static int _lot(Random random) => random.nextInt(1 << 30) + 1;

  /// Первый раунд, ход первого в очереди.
  Battle start(List<SessionPlayer> players) {
    final first = order(players).where((e) => !e.isOut).firstOrNull;
    return _copyWith(round: 1, currentId: () => first?.id);
  }

  /// Эффект на участнике: стандартное состояние ([condition]) или своё ([title], [description]).
  /// [turns] — сколько его ходов действует, `null` — пока мастер не снимет.
  Battle addStatus(String combatantId, {Condition? condition, String? title, String description = '', int? turns}) {
    final id = 's$_nextStatusId';
    final status = condition != null
        ? StatusEffect.condition(condition, id: id, turns: turns)
        : StatusEffect.custom(id: id, title: title ?? '', description: description, turns: turns);
    return _copyWith(
      statuses: {
        ...statuses,
        combatantId: [...?statuses[combatantId], status],
      },
      nextStatusId: _nextStatusId + 1,
    );
  }

  Battle removeStatus(String combatantId, String statusId) {
    final left = [...?statuses[combatantId]]..removeWhere((e) => e.id == statusId);
    return _copyWith(statuses: {...statuses, combatantId: left}..removeWhere((_, value) => value.isEmpty));
  }

  /// Ход [combatantId] закончился: его эффектам с длительностью остаётся на ход меньше, истёкшие снимаются.
  Map<String, List<StatusEffect>> _afterTurnOf(String? combatantId) {
    final current = statuses[combatantId];
    if (combatantId == null || current == null) return statuses;
    final left = current.map((e) => e.afterTurn()).nonNulls.toList();
    return {...statuses, combatantId: left}..removeWhere((_, value) => value.isEmpty);
  }

  /// Ход следующего участника, выбывшие пропускаются. После последнего — новый раунд. У того, чей ход
  /// закончился, эффекты с длительностью уменьшаются на ход.
  Battle nextTurn(List<SessionPlayer> players) {
    if (!isStarted) return start(players);
    final queue = order(players);
    if (queue.every((e) => e.isOut)) return this;
    var index = queue.indexWhere((e) => e.id == currentId);
    var round = this.round;
    do {
      index++;
      if (index >= queue.length) {
        index = 0;
        round++;
      }
    } while (queue[index].isOut);
    return _copyWith(round: round, currentId: () => queue[index].id, statuses: _afterTurnOf(currentId));
  }

  /// Возврат хода, если мастер ошибся. Дальше начала первого раунда не уходит. Длительность эффектов не
  /// возвращается — истёкший эффект мастер ставит заново.
  Battle previousTurn(List<SessionPlayer> players) {
    if (!isStarted) return this;
    final queue = order(players);
    if (queue.every((e) => e.isOut)) return this;
    var index = queue.indexWhere((e) => e.id == currentId);
    if (index < 0) return this;
    var round = this.round;
    do {
      index--;
      if (index < 0) {
        if (round == 1) return this;
        index = queue.length - 1;
        round--;
      }
    } while (queue[index].isOut);
    return _copyWith(round: round, currentId: () => queue[index].id);
  }

  /// Бой для игроков: очередь и чей ход, без хитов и статблоков монстров. `null` — бой не начат.
  BattleSnapshot? snapshot(List<SessionPlayer> players) {
    if (!isStarted) return null;
    return BattleSnapshot(
      round: round,
      currentId: currentId,
      entries: [
        for (final combatant in order(players))
          switch (combatant) {
            PlayerCombatant() => BattleEntry(
              id: combatant.id,
              name: combatant.name,
              isPlayer: true,
              initiative: initiative[combatant.id],
              isOut: combatant.isOut,
              isKnockedOut: combatant.player.state.isKnockedOut,
              statuses: combatant.statuses,
            ),
            MonsterCombatant(:final monster) => BattleEntry(
              id: combatant.id,
              name: combatant.publicName,
              isPlayer: false,
              initiative: initiative[combatant.id],
              marker: monster.marker.name,
              isOut: combatant.isOut,
              statuses: combatant.statuses,
            ),
          },
      ],
    );
  }

  /// Конец боя: инициатива и раунды сбрасываются, монстры и их хиты остаются.
  Battle finish() => _copyWith(initiative: const {}, tiebreaks: const {}, round: 0, currentId: () => null);
}
