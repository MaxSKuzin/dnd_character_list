import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/domain/models/death_throws.dart';
import 'package:dnd_character_list/domain/models/player_skill.dart';
import 'package:dnd_character_list/domain/models/save_throw.dart';
import 'package:dnd_character_list/domain/models/shield.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/specialization.dart';
import 'package:dnd_character_list/domain/models/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell_stat.dart';
import 'package:dnd_character_list/domain/models/stat.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';

class Player {
  final Stat strength;
  final Stat dexterity;
  final Stat constitution;
  final Stat intelligence;
  final Stat wisdom;
  final Stat charisma;
  final List<Specialization> classes;
  final List<Skill> chosenSkills;
  late final int currentHits;
  late final int currentMana;
  final Armor? armor;
  final Shield? shield;
  final List<Weapon> weapons;
  final DeathThrows deathThrows;
  late final Map<ClassExtras, int> currentExtras;
  bool isDead;

  Player({
    required strength,
    required dexterity,
    required constitution,
    required intelligence,
    required wisdom,
    required charisma,
    required this.classes,
    required this.chosenSkills,
    required this.armor,
    required this.shield,
    required this.weapons,
    Map<ClassExtras, int>? classExtras,
    DeathThrows? deathThrows,
    int? hits,
    int? mana,
    this.isDead = false,
  })  : assert(classes.isNotEmpty),
        strength = Stat(value: strength, kind: StatKind.strength),
        dexterity = Stat(value: dexterity, kind: StatKind.dexterity),
        constitution = Stat(value: constitution, kind: StatKind.constitution),
        intelligence = Stat(value: intelligence, kind: StatKind.intelligence),
        wisdom = Stat(value: wisdom, kind: StatKind.wisdom),
        deathThrows = deathThrows ??
            const DeathThrows(
              death: 0,
              life: 0,
            ),
        charisma = Stat(value: charisma, kind: StatKind.charisma) {
    currentHits = hits ?? maxHits;
    currentMana = mana ?? maxMana;
    currentExtras = classExtras ?? maxExtras;
  }

  Map<ClassExtras, int> get maxExtras => classes.where((e) => e.classExtra != null).fold(
        <ClassExtras, int>{},
        (prev, e) {
          final count = e.getClassExtrasCount(this);
          if (count > 0) {
            prev[e.classExtra!] = count;
          }
          return prev;
        },
      );

  List<Stat> get stats => [
        strength,
        dexterity,
        constitution,
        intelligence,
        wisdom,
        charisma,
      ];

  int get maxHits => classes.fold(0, (previous, spec) => previous + spec.hitPoints(this));

  Player takeDamage(int value) {
    bool isDead = currentHits - value <= -maxHits;
    return _copyWith(
      currentHits: () => max(0, currentHits - value),
      deathThrows: () => isDead ? const DeathThrows(death: 3, life: 0) : null,
      isDead: isDead,
    );
  }

  Player heal(int health) {
    return _copyWith(
      currentHits: () => min(maxHits, currentHits + health),
      deathThrows: () => null,
      isDead: false,
    );
  }

  Player healFull() {
    return _copyWith(
      currentHits: () => maxHits,
      deathThrows: () => null,
      isDead: false,
    );
  }

  String get hitDices => classes.map((e) => '${e.level}${e.hitDice.name}').join(', ');

  int get level => classes.fold(0, (previous, spec) => previous + spec.level);

  ///Does not modify the original object!
  Player levelUp<T extends Specialization>() {
    final newClasses = classes
        .map(
          (e) => e is T && e.runtimeType != Specialization ? e.levelUp() : e,
        )
        .toList();
    return _copyWith(
      classes: newClasses,
      currentHits: () => null,
      currentMana: () => null,
      classExtras: () => null,
    );
  }

  ///Does not modify the original object!
  Player addClass<T extends Specialization>(T spec) {
    if (classes.where((e) => e is T && e.runtimeType != Specialization).isNotEmpty) {
      throw "Can't duplicate existing class";
    }
    return _copyWith(
      classes: [...classes, spec],
      currentHits: () => null,
      currentMana: () => null,
      classExtras: () => null,
    );
  }

  int get proficiencyBonus => (level - 1) ~/ 4 + 2;

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
    final mainClass = classes.firstWhere((e) => e.isMain);
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

        final int chosenThrowsCount = mainClass.chosenSaveThrows.where((el) => el == e).length;

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

  int get protection {
    var maxProtection = 0;
    for (var spec in classes) {
      maxProtection = max(maxProtection, spec.getProtection(this));
    }
    if (shield != null) {
      maxProtection += shield!.defense;
    }
    return maxProtection;
  }

  int get additionalDamage {
    return classes.fold(0, (prev, e) => prev + e.additionalDamage(this));
  }

  int get maxMana {
    final magicLevel = classes.fold(
      0,
      (prev, e) => prev + (e.level * e.magicLevelMultiplier).toInt(),
    );
    if (magicLevel == 0) {
      return 0;
    }
    final spellCells = spellSlotsTable[magicLevel]!;
    return spellCells.entries.fold(
      0,
      (prev, entry) => prev + entry.key.mana * entry.value,
    );
  }

  List<SpellStat> get spellKinds => classes
      .where((e) => e.spellKind != null)
      .map(
        (e) => SpellStat(
          owner: e.name,
          stat: stats.firstWhere((element) => element.kind == e.spellKind),
          proficiencyBonus: proficiencyBonus,
        ),
      )
      .whereNotNull()
      .toList();

  Player spendMana(int value) {
    return _copyWith(
      currentMana: () => max(0, currentMana - value),
    );
  }

  Player recoverMana(int value) {
    return _copyWith(
      currentMana: () => min(maxMana, currentMana + value),
    );
  }

  Player changeDeadThrow({
    int? death,
    int? life,
  }) {
    if (death == deathThrows.death) {
      return _copyWith(
        deathThrows: () => DeathThrows(
          death: max(0, deathThrows.death - 1),
          life: deathThrows.life,
        ),
      );
    }
    if (life == deathThrows.life) {
      return _copyWith(
        deathThrows: () => DeathThrows(
          death: deathThrows.death,
          life: max(0, deathThrows.life - 1),
        ),
      );
    }
    return _copyWith(
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
    return _copyWith(
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
    return _copyWith(
      classExtras: () {
        final newExtras = Map<ClassExtras, int>.from(currentExtras);
        newExtras[extra] = min(maxExtra, newExtras[extra]! + 1);
        return newExtras;
      },
    );
  }

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
    isEqual &= armor == other.armor;
    isEqual &= shield == other.shield;
    isEqual &= weapons.equals(other.weapons);
    isEqual &= currentMana == other.currentMana;
    isEqual &= deathThrows == other.deathThrows;
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
        armor,
        shield,
        weapons,
        currentMana,
        deathThrows,
        currentExtras,
      ]);

  Player _copyWith({
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
    Armor? Function()? armor,
    Shield? Function()? shield,
    List<Weapon>? weapons,
    int? Function()? currentMana,
    DeathThrows? Function()? deathThrows,
    Map<ClassExtras, int>? Function()? classExtras,
  }) =>
      Player(
        strength: strength ?? this.strength.value,
        dexterity: dexterity ?? this.dexterity.value,
        constitution: constitution ?? this.constitution.value,
        intelligence: intelligence ?? this.intelligence.value,
        wisdom: wisdom ?? this.wisdom.value,
        charisma: charisma ?? this.charisma.value,
        classes: classes ?? this.classes,
        chosenSkills: chosenSkills ?? this.chosenSkills,
        hits: currentHits != null ? currentHits() : this.currentHits,
        isDead: isDead ?? this.isDead,
        armor: armor != null ? armor() : this.armor,
        shield: shield != null ? shield() : this.shield,
        weapons: weapons ?? this.weapons,
        mana: currentMana != null ? currentMana() : this.currentMana,
        deathThrows: deathThrows != null ? deathThrows() : this.deathThrows,
        classExtras: classExtras != null ? classExtras() : currentExtras,
      );
}
