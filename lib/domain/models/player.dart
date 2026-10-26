import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/armor_proficiency.dart';
import 'package:dnd_character_list/domain/models/background.dart';
import 'package:dnd_character_list/domain/models/balance.dart';
import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/domain/models/combat.dart';
import 'package:dnd_character_list/domain/models/classes/sorcerer.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/death_throws.dart';
import 'package:dnd_character_list/domain/models/feat.dart';
import 'package:dnd_character_list/domain/models/fighting_style.dart';
import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/language.dart';
import 'package:dnd_character_list/domain/models/peculiarity.dart';
import 'package:dnd_character_list/domain/models/personality.dart';
import 'package:dnd_character_list/domain/models/player_skill.dart';
import 'package:dnd_character_list/domain/models/races/race.dart';
import 'package:dnd_character_list/domain/models/save_throw.dart';
import 'package:dnd_character_list/domain/models/shield.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_stat.dart';
import 'package:dnd_character_list/domain/models/stat.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/domain/models/weapon_type.dart';

class Player {
  final Background background;
  final Race race;
  late final Stat strength;
  late final Stat dexterity;
  late final Stat constitution;
  late final Stat intelligence;
  late final Stat wisdom;
  late final Stat charisma;
  final List<Specialization> classes;
  late final List<Skill> chosenSkills;
  late final int currentHits;

  /// Оставшиеся ячейки заклинаний по уровням. Ячейки, созданные из единиц чародейства, могут превышать
  /// максимум до продолжительного отдыха.
  late final Map<SpellSlot, int> currentSpellSlots;
  final Armor? armor;
  final Shield? shield;
  final Weapon? mainWeapon;
  final Weapon? secondWeapon;
  final Weapon? mainRangeWeapon;
  final Weapon? secondRangeWeapon;
  final DeathThrows deathThrows;
  final Inventory inventory;
  late final Map<ClassExtras, int> currentExtras;
  final Personality personality;
  final List<Language> _additionalLanguages;
  final Map<SpellSlot, Spell> raceSpells;

  /// Инструменты, которыми владеет персонаж, например «Лютня» или «Набор для грима».
  final List<String> toolProficiencies;
  bool isDead;

  /// Нокаут: три успешных спасброска от смерти — 1 хит, но персонаж без сознания, пока его не приведут в чувство
  /// союзник, мастер или лечение. Как и текущие хиты, не сохраняется.
  final bool isKnockedOut;

  final List<Skill> _rawchosenSkills;
  final int _rawStrength;
  final int _rawDexterity;
  final int _rawConstitution;
  final int _rawIntelligence;
  final int _rawWisdom;
  final int _rawCharisma;

  Player({
    required List<Language> knownLanguages,
    required this.personality,
    required this.race,
    required int strength,
    required int dexterity,
    required int constitution,
    required int intelligence,
    required int wisdom,
    required int charisma,
    required this.classes,
    required List<Skill> chosenSkills,
    required this.armor,
    required this.shield,
    required this.mainWeapon,
    required this.secondWeapon,
    required this.mainRangeWeapon,
    required this.secondRangeWeapon,
    required this.inventory,
    required this.background,
    required this.raceSpells,
    this.toolProficiencies = const [],
    Map<ClassExtras, int>? classExtras,
    DeathThrows? deathThrows,
    int? hits,
    Map<SpellSlot, int>? spellSlots,
    this.isDead = false,
    this.isKnockedOut = false,
  })  : assert(classes.isNotEmpty),
        _additionalLanguages = knownLanguages,
        _rawStrength = strength,
        _rawDexterity = dexterity,
        _rawConstitution = constitution,
        _rawIntelligence = intelligence,
        _rawWisdom = wisdom,
        _rawCharisma = charisma,
        _rawchosenSkills = chosenSkills,
        deathThrows = deathThrows ??
            const DeathThrows(
              death: 0,
              life: 0,
            ) {
    this.chosenSkills = {
      ..._rawchosenSkills,
      ...background.skills,
      ...classes.expand((e) => e.grantedSkills),
      ...feats.expand((e) => e.skills),
    }.toList();
    this.strength = Stat(
      value: strength +
          (race.statBonuses[StatKind.strength] ?? 0) +
          classes.where((e) => e.statBonuses.containsKey(StatKind.strength)).fold(
                0,
                (p, e) => p + e.statBonuses[StatKind.strength]!,
              ),
      kind: StatKind.strength,
    );
    this.dexterity = Stat(
      value: dexterity +
          (race.statBonuses[StatKind.dexterity] ?? 0) +
          classes.where((e) => e.statBonuses.containsKey(StatKind.dexterity)).fold(
                0,
                (p, e) => p + e.statBonuses[StatKind.dexterity]!,
              ),
      kind: StatKind.dexterity,
    );
    this.constitution = Stat(
      value: constitution +
          (race.statBonuses[StatKind.constitution] ?? 0) +
          classes.where((e) => e.statBonuses.containsKey(StatKind.constitution)).fold(
                0,
                (p, e) => p + e.statBonuses[StatKind.constitution]!,
              ),
      kind: StatKind.constitution,
    );
    this.intelligence = Stat(
      value: intelligence +
          (race.statBonuses[StatKind.intelligence] ?? 0) +
          classes.where((e) => e.statBonuses.containsKey(StatKind.intelligence)).fold(
                0,
                (p, e) => p + e.statBonuses[StatKind.intelligence]!,
              ),
      kind: StatKind.intelligence,
    );
    this.wisdom = Stat(
      value: wisdom +
          (race.statBonuses[StatKind.wisdom] ?? 0) +
          classes.where((e) => e.statBonuses.containsKey(StatKind.wisdom)).fold(
                0,
                (p, e) => p + e.statBonuses[StatKind.wisdom]!,
              ),
      kind: StatKind.wisdom,
    );
    this.charisma = Stat(
      value: charisma +
          (race.statBonuses[StatKind.charisma] ?? 0) +
          classes.where((e) => e.statBonuses.containsKey(StatKind.charisma)).fold(
                0,
                (p, e) => p + e.statBonuses[StatKind.charisma]!,
              ),
      kind: StatKind.charisma,
    );
    currentHits = hits ?? maxHits;
    currentSpellSlots = spellSlots ?? spellCells;
    currentExtras = classExtras ?? maxExtras;
  }

  Map<ClassExtras, int> get maxExtras => classes.where((e) => e.classExtras.isNotEmpty).fold(
        <ClassExtras, int>{},
        (prev, e) {
          for (final extra in e.classExtras) {
            final count = e.getClassExtrasCount(this, extra);
            if (count > 0) {
              prev[extra] = count;
            }
          }
          return prev;
        },
      );

  Map<StatKind, Stat> get stats => {
        StatKind.strength: strength,
        StatKind.dexterity: dexterity,
        StatKind.constitution: constitution,
        StatKind.intelligence: intelligence,
        StatKind.wisdom: wisdom,
        StatKind.charisma: charisma,
      };

  int get maxHits =>
      classes.fold(0, (previous, spec) => previous + spec.hitPoints(this)) +
      feats.fold(0, (previous, e) => previous + e.feat.hitPointsPerLevel * level);

  /// Урон по персонажу в нокауте снова опускает его к смерти: нокаут снимается, спасброски начинаются заново.
  Player takeDamage(int value) {
    bool isDead = currentHits - value <= -maxHits;
    return copyWith(
      currentHits: () => max(0, currentHits - value),
      deathThrows: () => isDead ? const DeathThrows(death: 3, life: 0) : null,
      isDead: isDead,
      isKnockedOut: false,
    );
  }

  /// Лечение приводит в чувство и из нокаута.
  Player heal(int health) {
    return copyWith(
      currentHits: () => min(maxHits, currentHits + health),
      deathThrows: () => null,
      isDead: false,
      isKnockedOut: false,
    );
  }

  Player healFull() {
    return copyWith(
      currentHits: () => maxHits,
      deathThrows: () => null,
      isDead: false,
      isKnockedOut: false,
    );
  }

  /// Союзник или мастер привели персонажа в чувство: нокаут снимается, хиты остаются.
  Player wakeUp() => isKnockedOut ? copyWith(isKnockedOut: false) : this;

  String get hitDices => classes.map((e) => '${e.level}${e.hitDice.name}').join(', ');

  int get level => classes.fold(0, (previous, spec) => previous + spec.level);

  ///Does not modify the original object!
  Player levelUp<T extends Specialization>(T spec) {
    if (classes.every((e) => e.classKind != spec.classKind)) {
      throw "Can't level up non-existing class";
    }
    final newClasses = classes
        .map(
          (e) => e.classKind == spec.classKind ? spec : e,
        )
        .toList();
    return copyWith(
      classes: newClasses,
      currentHits: () => null,
      currentSpellSlots: () => null,
      classExtras: () => null,
    );
  }

  ///Does not modify the original object!
  Player addClass<T extends Specialization>(T spec) {
    if (classes.any((e) => e.classKind == spec.classKind)) {
      throw "Can't duplicate existing class";
    }
    return copyWith(
      classes: [...classes, spec],
      currentHits: () => null,
      currentSpellSlots: () => null,
      classExtras: () => null,
    );
  }

  int get proficiencyBonus => (level - 1) ~/ 4 + 2;

  List<ChosenFeat> get feats => classes.expand((e) => e.feats).toList();

  /// Навыки с удвоенным бонусом мастерства («Компетентность»).
  /// Навыки, выбранные при создании и повышении уровня, без навыков предыстории и классовых.
  List<Skill> get rawChosenSkills => _rawchosenSkills;

  /// Плут пока отмечает компетентность повтором навыка: дважды выбранный навык
  /// или выбранный повторно навык предыстории.
  List<Skill> get expertiseSkills {
    final owned = [..._rawchosenSkills, ...background.skills];
    return {
      ...classes.expand((e) => e.expertise),
      ...owned.where((skill) => owned.where((e) => e == skill).length > 1),
    }.toList();
  }

  /// Бонус к проверкам характеристик без владения: половина бонуса мастерства у «Мастера на все руки».
  int get unskilledCheckBonus => classes.any((e) => e.hasJackOfAllTrades) ? proficiencyBonus ~/ 2 : 0;

  /// Инициатива — проверка Ловкости, поэтому к ней применяется и «Мастер на все руки».
  int get initiative =>
      dexterity.bonus + unskilledCheckBonus + feats.fold(0, (previous, e) => previous + e.feat.initiativeBonus);

  /// Скорость расы; черты и умения классов (движение без доспехов монаха) увеличивают её, без нужной Силы тяжёлый
  /// доспех уменьшает её на 10 футов.
  int get speed =>
      race.speed +
      feats.fold<int>(0, (previous, e) => previous + e.feat.speedBonus) +
      classes.fold<int>(0, (previous, e) => previous + e.speedBonus(this)) -
      (isArmorTooHeavy ? 10 : 0);

  int get _passiveBonus => feats.fold(0, (previous, e) => previous + e.feat.passiveBonus);

  int get passivePerception => 10 + Skill.perception.getBonus(this) + _passiveBonus;

  int get passiveInvestigation => 10 + Skill.investigation.getBonus(this) + _passiveBonus;

  Set<ArmorProficiency> get armorProficiencies => {
        ...classes.expand((e) => e.armorProficiencies),
        ...feats.map((e) => e.feat.armorProficiency).nonNulls,
      };

  bool get canCastSpells => classes.any((e) => e.spellKind != null);

  /// Владение спасбросками основного класса и черт. Спасброски, которыми наделяют умения классов
  /// («Алмазная душа»), добавляются только недостающие: каждое повторение в списке удваивает бонус.
  List<StatKind> get savingThrowProficiencies {
    final proficiencies = [
      ...classes.firstWhere((e) => e.isMain).chosenSaveThrows,
      ...feats.map((e) => e.savingThrow).nonNulls,
    ];
    return [
      ...proficiencies,
      ...classes.expand((e) => e.grantedSaveThrows).toSet().where((e) => !proficiencies.contains(e)),
    ];
  }

  List<PlayerSkill> get skills => Skill.values
      .map(
        (e) => PlayerSkill(
          isChosen: chosenSkills.contains(e),
          origin: e,
          bonus: e.getBonus(this),
        ),
      )
      .toList();

  List<SaveThrow> get saveThrows {
    final proficiencies = savingThrowProficiencies;
    final throws = StatKind.values.map(
      (e) {
        var mainBonus = switch (e) {
          StatKind.strength => strength.bonus,
          StatKind.dexterity => dexterity.bonus,
          StatKind.constitution => constitution.bonus,
          StatKind.intelligence => intelligence.bonus,
          StatKind.wisdom => wisdom.bonus,
          StatKind.charisma => charisma.bonus,
        };

        final int chosenThrowsCount = proficiencies.where((el) => el == e).length;

        mainBonus += chosenThrowsCount * proficiencyBonus;

        return SaveThrow(
          bonus: mainBonus,
          origin: e,
          isChosen: chosenThrowsCount > 0,
        );
      },
    );
    return throws.toList();
  }

  int get protection => armorClass.value;

  int get additionalDamage {
    return classes.fold(0, (prev, e) => prev + e.additionalDamage(this));
  }

  /// Ячейки заклинаний по таблице заклинателя (уровни без ячеек не включаются).
  Map<SpellSlot, int> get spellCells {
    final magicLevel = classes.fold(
      0,
      (prev, e) => prev + (e.level * e.magicLevelMultiplier).toInt(),
    );
    if (magicLevel == 0) {
      return {};
    }
    return Map.fromEntries(spellSlotsTable[magicLevel]!.entries.where((e) => e.value > 0));
  }

  /// Уровни ячеек, которые есть у персонажа: по таблице или созданные из единиц чародейства.
  List<SpellSlot> get spellSlotLevels =>
      SpellSlot.values.where((e) => (spellCells[e] ?? 0) > 0 || (currentSpellSlots[e] ?? 0) > 0).toList();

  /// Ячейки, которыми можно наложить заклинание [level] уровня: того же уровня и выше, с остатком.
  List<SpellSlot> availableSpellSlots(SpellSlot level) =>
      spellSlotLevels.where((e) => e.index >= level.index && (currentSpellSlots[e] ?? 0) > 0).toList();

  List<SpellStat> get spellKinds => classes
      .where((e) => e.spellKind != null)
      .map(
        (e) => SpellStat(
          owner: e.name,
          stat: stats[e.spellKind]!,
          proficiencyBonus: proficiencyBonus,
        ),
      )
      .nonNulls
      .toList();

  Player spendSpellSlot(SpellSlot slot) {
    final current = currentSpellSlots[slot] ?? 0;
    if (current == 0) return this;
    return copyWith(currentSpellSlots: () => {...currentSpellSlots, slot: current - 1});
  }

  /// Возвращает потраченную ячейку, но не выше максимума по таблице.
  Player restoreSpellSlot(SpellSlot slot) {
    final current = currentSpellSlots[slot] ?? 0;
    if (current >= (spellCells[slot] ?? 0)) return this;
    return copyWith(currentSpellSlots: () => {...currentSpellSlots, slot: current + 1});
  }

  /// Продолжительный отдых что-то восстановит: хиты, ячейки заклинаний или ресурсы классов ниже максимума.
  /// Созданные из единиц чародейства ячейки сверх максимума не в счёт.
  bool get canRestOnLongRest =>
      currentHits < maxHits ||
      spellCells.entries.any((e) => (currentSpellSlots[e.key] ?? 0) < e.value) ||
      maxExtras.entries.any((e) => (currentExtras[e.key] ?? 0) < e.value);

  /// Продолжительный отдых: хиты, ячейки заклинаний и ресурсы классов восстанавливаются,
  /// созданные из единиц чародейства ячейки исчезают.
  Player longRest() => copyWith(
        currentHits: () => maxHits,
        deathThrows: () => null,
        isDead: false,
        isKnockedOut: false,
        currentSpellSlots: () => null,
        classExtras: () => null,
      );

  /// Ресурсы классов, которые восстанавливаются и коротким отдыхом (очки ци, вдохновение барда с 5 уровня).
  Set<ClassExtras> get shortRestExtras =>
      classes.expand((e) => e.shortRestExtras).where((e) => maxExtras.containsKey(e)).toSet();

  /// Короткий отдых что-то восстановит: хиты или ресурсы классов из [shortRestExtras] ниже максимума.
  bool get canRestOnShortRest =>
      currentHits < maxHits || shortRestExtras.any((e) => (currentExtras[e] ?? 0) < maxExtras[e]!);

  /// Короткий отдых: хиты, восстановленные костями хитов (их бросают вживую, вводится сумма),
  /// и ресурсы классов из [shortRestExtras].
  Player shortRest(int health) {
    final healed = health > 0 ? heal(health) : this;
    return healed.copyWith(
      classExtras: () => {...currentExtras, for (final extra in shortRestExtras) extra: maxExtras[extra]!},
    );
  }

  int get currentSorceryPoints => currentExtras[ClassExtras.sorceryPoints] ?? 0;

  int get maxSorceryPoints => maxExtras[ClassExtras.sorceryPoints] ?? 0;

  /// Тратит единицы чародейства, например на метамагию.
  Player spendSorceryPoints(int points) {
    if (points <= 0 || points > currentSorceryPoints) return this;
    return copyWith(
      classExtras: () => {...currentExtras, ClassExtras.sorceryPoints: currentSorceryPoints - points},
    );
  }

  /// «Источник магии»: ячейку можно превратить в единицы чародейства по её уровню,
  /// но единиц не может стать больше максимума.
  bool canConvertToSorceryPoints(SpellSlot slot) =>
      maxSorceryPoints > 0 &&
      (currentSpellSlots[slot] ?? 0) > 0 &&
      currentSorceryPoints + slot.level <= maxSorceryPoints;

  Player convertSpellSlotToSorceryPoints(SpellSlot slot) {
    if (!canConvertToSorceryPoints(slot)) return this;
    return copyWith(
      currentSpellSlots: () => {...currentSpellSlots, slot: currentSpellSlots[slot]! - 1},
      classExtras: () => {...currentExtras, ClassExtras.sorceryPoints: currentSorceryPoints + slot.level},
    );
  }

  /// «Источник магии»: ячейку 1–5 уровня можно создать за единицы чародейства.
  bool canCreateSpellSlot(SpellSlot slot) {
    final cost = Sorcerer.spellSlotCost[slot];
    return cost != null && maxSorceryPoints > 0 && currentSorceryPoints >= cost;
  }

  Player createSpellSlot(SpellSlot slot) {
    if (!canCreateSpellSlot(slot)) return this;
    return copyWith(
      currentSpellSlots: () => {...currentSpellSlots, slot: (currentSpellSlots[slot] ?? 0) + 1},
      classExtras: () => {
        ...currentExtras,
        ClassExtras.sorceryPoints: currentSorceryPoints - Sorcerer.spellSlotCost[slot]!,
      },
    );
  }

  Player changeDeadThrow({
    int? death,
    int? life,
  }) {
    if (death == deathThrows.death) {
      return copyWith(
        deathThrows: () => DeathThrows(
          death: max(0, deathThrows.death - 1),
          life: deathThrows.life,
        ),
      );
    }
    if (life == deathThrows.life) {
      return copyWith(
        deathThrows: () => DeathThrows(
          death: deathThrows.death,
          life: max(0, deathThrows.life - 1),
        ),
      );
    }
    // Третий успех: персонаж стабилизировался — 1 хит и нокаут (домашнее правило вместо 1к4 часов без сознания).
    if (life == 3) {
      return copyWith(currentHits: () => 1, deathThrows: () => null, isKnockedOut: true);
    }
    return copyWith(
      deathThrows: () => DeathThrows(
        death: death ?? deathThrows.death,
        life: life ?? deathThrows.life,
      ),
      isDead: death == 3,
    );
  }

  Player useExtra(ClassExtras extra) {
    if (currentExtras[extra] == null) {
      return this;
    }
    return copyWith(
      classExtras: () {
        final newExtras = Map<ClassExtras, int>.from(currentExtras);
        newExtras[extra] = max(0, newExtras[extra]! - 1);
        return newExtras;
      },
    );
  }

  Player restoreExtra(ClassExtras extra) {
    final maxExtra = maxExtras[extra];
    if (currentExtras[extra] == null || maxExtra == null) {
      return this;
    }
    return copyWith(
      classExtras: () {
        final newExtras = Map<ClassExtras, int>.from(currentExtras);
        newExtras[extra] = min(maxExtra, newExtras[extra]! + 1);
        return newExtras;
      },
    );
  }

  /// Заклинания классов вместе с заклинаниями, полученными от черт этих классов.
  Map<Specialization, List<Spell>> get spells => Map.fromEntries(
        classes
            .map((e) => MapEntry(e, [...e.knownSpells, ...e.feats.expand((feat) => feat.spells)]))
            .where((e) => e.value.isNotEmpty),
      );

  List<Peculiarity> get abilities => [
        ...race.peculiarities,
        if (background.featureName != null)
          Peculiarity(
            name: background.featureName!.toUpperCase(),
            description: background.featureHtml ?? '',
            isHtml: true,
          ),
        ...classes.fold(
          <Peculiarity>[],
          (prev, e) => [...prev, ...e.abilities],
        ),
        ...feats.map(
          (e) => Peculiarity(
              name: 'ЧЕРТА: ${e.feat.name.toUpperCase()}', description: e.feat.descriptionHtml, isHtml: true),
        ),
      ];

  bool get canUseTwoWeapons => classes.any((e) => e.canUseTwoWeapons);

  List<Language> get knownLanguages => {
        ...race.knownLanguages,
        ..._additionalLanguages,
        ...classes.expand((e) => e.grantedLanguages),
        ...feats.expand((e) => e.languages),
      }.toList();

  /// Берёт оружие в слот. Двуручное оружие освобождает вторую руку, рукопашное оружие
  /// во второй руке занимает место щита. После смены основного оружия оружие во второй руке
  /// снимается, если с новым основным сражаться двумя оружиями нельзя.
  Player equipWeapon(Weapon weapon, WeaponSlot slot) => _equipWeapon(weapon, slot)._dropInvalidOffHand();

  Player _dropInvalidOffHand() {
    var player = this;
    for (final slot in [WeaponSlot.secondHand, WeaponSlot.secondRange]) {
      final weapon = player.weaponIn(slot);
      if (weapon != null && player.cannotEquip(weapon, slot) != null) player = player.unequipWeapon(slot);
    }
    return player;
  }

  Player _equipWeapon(Weapon weapon, WeaponSlot slot) {
    final isTwoHanded = weapon.type == WeaponType.twoHanded;
    return switch (slot) {
      WeaponSlot.mainHand => copyWith(
          mainWeapon: () => weapon,
          secondWeapon: () => isTwoHanded ? null : secondWeapon,
          shield: () => isTwoHanded ? null : shield,
        ),
      WeaponSlot.secondHand => copyWith(secondWeapon: () => weapon, shield: () => null),
      WeaponSlot.mainRange => copyWith(
          mainRangeWeapon: () => weapon,
          secondRangeWeapon: () => isTwoHanded ? null : secondRangeWeapon,
        ),
      WeaponSlot.secondRange => copyWith(secondRangeWeapon: () => weapon),
    };
  }

  /// Берёт оружие в основную руку рукопашного или дальнобойного комплекта.
  Player equipMainWeapon(Weapon weapon) =>
      equipWeapon(weapon, weapon.kind.isMelee ? WeaponSlot.mainHand : WeaponSlot.mainRange);

  Player unequipWeapon(WeaponSlot slot) => switch (slot) {
        WeaponSlot.mainHand => copyWith(mainWeapon: () => secondWeapon, secondWeapon: () => null),
        WeaponSlot.secondHand => copyWith(secondWeapon: () => null),
        WeaponSlot.mainRange => copyWith(mainRangeWeapon: () => secondRangeWeapon, secondRangeWeapon: () => null),
        WeaponSlot.secondRange => copyWith(secondRangeWeapon: () => null),
      };

  /// Щит занимает вторую руку.
  Player equipShield(Shield shield) {
    return copyWith(
      shield: () => shield,
      secondWeapon: () => null,
    );
  }

  Player unequipShield() {
    return copyWith(
      shield: () => null,
    );
  }

  Player equipArmor(Armor armor) {
    return copyWith(
      armor: () => armor,
    );
  }

  Player unequipArmor() {
    return copyWith(
      armor: () => null,
    );
  }

  /// Снимает предмет, если его больше не осталось в инвентаре.
  Player _unequipMissing() {
    bool has(Object item) => inventory.items.any((e) => e.item == item);
    final weapons = {for (final slot in WeaponSlot.values) slot: weaponIn(slot)};
    var player = this;
    for (final slot in WeaponSlot.values.reversed) {
      final weapon = weapons[slot];
      if (weapon == null) continue;
      final count = inventory.items.firstWhereOrNull((e) => e.item == weapon)?.quantity ?? 0;
      final used = weapons.values.where((e) => e == weapon).length;
      if (count < used) player = player.unequipWeapon(slot);
    }
    if (armor != null && !has(armor!)) player = player.unequipArmor();
    if (shield != null && !has(shield!)) player = player.unequipShield();
    return player;
  }

  Player spendBalance(Balance balance) {
    return copyWith(
      inventory: inventory.spendBalance(balance),
    );
  }

  Player addBalance(Balance balance) {
    return copyWith(
      inventory: inventory.addBalance(balance),
    );
  }

  Player removeItem(InventoryItem item) {
    return copyWith(
      inventory: inventory.removeItem(item),
    )._unequipMissing();
  }

  Player setItemQuantity(InventoryItem item, int quantity) {
    return copyWith(
      inventory: inventory.setItemQuantity(item, quantity),
    )._unequipMissing();
  }

  Player addItemQuantity(InventoryItem item) {
    return copyWith(
      inventory: inventory.addItemQuantity(item),
    );
  }

  Player addItem(InventoryItem item) {
    return copyWith(
      inventory: inventory.addItem(item),
    );
  }

  List<FightingStyle> get fightingStyles => classes.fold(
        <FightingStyle>[],
        (prev, e) => [
          ...prev,
          if (e.fightingStyle != null) e.fightingStyle!,
        ],
      );

  @override
  bool operator ==(Object other) {
    if (other is! Player) {
      return false;
    }

    bool isEqual = true;
    isEqual &= strength == other.strength;
    isEqual &= dexterity == other.dexterity;
    isEqual &= constitution == other.constitution;
    isEqual &= intelligence == other.intelligence;
    isEqual &= wisdom == other.wisdom;
    isEqual &= charisma == other.charisma;
    isEqual &= classes.equals(other.classes);
    isEqual &= chosenSkills.equals(other.chosenSkills);
    isEqual &= currentHits == other.currentHits;
    isEqual &= isDead == other.isDead;
    isEqual &= isKnockedOut == other.isKnockedOut;
    isEqual &= armor == other.armor;
    isEqual &= shield == other.shield;
    isEqual &= mainWeapon == other.mainWeapon;
    isEqual &= secondWeapon == other.secondWeapon;
    isEqual &= mainRangeWeapon == other.mainRangeWeapon;
    isEqual &= secondRangeWeapon == other.secondRangeWeapon;
    isEqual &= const MapEquality<SpellSlot, int>().equals(currentSpellSlots, other.currentSpellSlots);
    isEqual &= deathThrows == other.deathThrows;
    isEqual &= race == other.race;
    isEqual &= inventory == other.inventory;
    currentExtras.forEach((key, value) {
      if (other.currentExtras[key] != value) {
        isEqual = false;
      }
    });

    return isEqual;
  }

  @override
  int get hashCode => Object.hashAll([
        strength,
        dexterity,
        constitution,
        intelligence,
        wisdom,
        charisma,
        classes,
        chosenSkills,
        currentHits,
        isDead,
        isKnockedOut,
        armor,
        shield,
        mainWeapon,
        secondWeapon,
        mainRangeWeapon,
        secondRangeWeapon,
        const MapEquality<SpellSlot, int>().hash(currentSpellSlots),
        deathThrows,
        currentExtras,
        race,
        inventory,
      ]);

  Player copyWith({
    int? strength,
    int? dexterity,
    int? constitution,
    int? intelligence,
    int? wisdom,
    int? charisma,
    List<Specialization>? classes,
    List<Skill>? chosenSkills,
    int? Function()? currentHits,
    bool? isDead,
    bool? isKnockedOut,
    Armor? Function()? armor,
    Shield? Function()? shield,
    Map<SpellSlot, int>? Function()? currentSpellSlots,
    DeathThrows? Function()? deathThrows,
    Map<ClassExtras, int>? Function()? classExtras,
    Weapon? Function()? mainWeapon,
    Weapon? Function()? secondWeapon,
    Weapon? Function()? mainRangeWeapon,
    Weapon? Function()? secondRangeWeapon,
    Inventory? inventory,
    Map<SpellSlot, Spell>? raceSpells,
    List<String>? toolProficiencies,
  }) =>
      Player(
        inventory: inventory ?? this.inventory,
        personality: personality,
        strength: strength ?? _rawStrength,
        dexterity: dexterity ?? _rawDexterity,
        constitution: constitution ?? _rawConstitution,
        intelligence: intelligence ?? _rawIntelligence,
        wisdom: wisdom ?? _rawWisdom,
        charisma: charisma ?? _rawCharisma,
        classes: classes ?? this.classes,
        chosenSkills: chosenSkills ?? _rawchosenSkills,
        hits: currentHits != null ? currentHits() : this.currentHits,
        isDead: isDead ?? this.isDead,
        isKnockedOut: isKnockedOut ?? this.isKnockedOut,
        armor: armor != null ? armor() : this.armor,
        shield: shield != null ? shield() : this.shield,
        spellSlots: currentSpellSlots != null ? currentSpellSlots() : this.currentSpellSlots,
        deathThrows: deathThrows != null ? deathThrows() : this.deathThrows,
        classExtras: classExtras != null ? classExtras() : currentExtras,
        mainWeapon: mainWeapon != null ? mainWeapon() : this.mainWeapon,
        secondWeapon: secondWeapon != null ? secondWeapon() : this.secondWeapon,
        mainRangeWeapon: mainRangeWeapon != null ? mainRangeWeapon() : this.mainRangeWeapon,
        secondRangeWeapon: secondRangeWeapon != null ? secondRangeWeapon() : this.secondRangeWeapon,
        raceSpells: raceSpells ?? this.raceSpells,
        toolProficiencies: toolProficiencies ?? this.toolProficiencies,
        race: race,
        background: background,
        knownLanguages: _additionalLanguages,
      );

  Map<String, dynamic> toJson() => {
        'classes': classes.map((e) => e.toJson()).toList(),
        'personality': personality.toJson(),
        'armor': armor?.toJson(),
        'charisma': _rawCharisma,
        'constitution': _rawConstitution,
        'dexterity': _rawDexterity,
        'intelligence': _rawIntelligence,
        'strength': _rawStrength,
        'wisdom': _rawWisdom,
        'chosenSkills': _rawchosenSkills.map((e) => e.name).toList(),
        'race': race.index,
        'mainWeapon': mainWeapon?.toJson(),
        'secondWeapon': secondWeapon?.toJson(),
        'mainRangeWeapon': mainRangeWeapon?.toJson(),
        'secondRangeWeapon': secondRangeWeapon?.toJson(),
        'shield': shield?.toJson(),
        'inventory': inventory.toJson(),
        'background': background.toJson(),
        'toolProficiencies': toolProficiencies,
        'knownLanguages': _additionalLanguages.map((e) => e.name).toList(),
        'raceSpells': raceSpells.map(
          (key, value) => MapEntry(
            key.name,
            value.toJson(),
          ),
        ),
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        inventory: Inventory.fromJson(json['inventory']),
        classes: (json['classes'] as List).map((e) => Specialization.fromJson(e)).toList(),
        personality: Personality.fromJson(json['personality']),
        armor: json['armor'] != null ? Armor.fromJson(json['armor']) : null,
        charisma: json['charisma'],
        constitution: json['constitution'],
        dexterity: json['dexterity'],
        intelligence: json['intelligence'],
        strength: json['strength'],
        wisdom: json['wisdom'],
        chosenSkills: (json['chosenSkills'] as List).map((e) => Skill.values.byName(e)).toList(),
        race: Race.values[json['race']],
        mainWeapon: json['mainWeapon'] != null ? Weapon.fromJson(json['mainWeapon']) : null,
        secondWeapon: json['secondWeapon'] != null ? Weapon.fromJson(json['secondWeapon']) : null,
        mainRangeWeapon: json['mainRangeWeapon'] != null ? Weapon.fromJson(json['mainRangeWeapon']) : null,
        secondRangeWeapon: json['secondRangeWeapon'] != null ? Weapon.fromJson(json['secondRangeWeapon']) : null,
        shield: json['shield'] != null ? Shield.fromJson(json['shield']) : null,
        background: Background.fromJson(json['background']),
        toolProficiencies: (json['toolProficiencies'] as List).cast<String>(),
        knownLanguages: (json['knownLanguages'] as List).map((e) => Language.values.byName(e)).toList(),
        raceSpells: json['raceSpells'] != null
            ? (json['raceSpells'] as Map).map(
                (key, value) => MapEntry(SpellSlot.values.byName(key), Spell.fromJson(value)),
              )
            : {},
      );
}
