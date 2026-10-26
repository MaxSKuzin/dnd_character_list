import 'package:dnd_character_list/domain/models/armor_proficiency.dart';
import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/domain/models/combat.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/peculiarity.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';

final class Thief extends Specialization {
  @override
  ClassKind get classKind => ClassKind.thief;

  @override
  List<ArmorProficiency> get armorProficiencies => const [ArmorProficiency.light];

  @override
  WeaponProficiency get weaponProficiency => const WeaponProficiency(
        simple: true,
        weapons: {'/weapons/crossbow,_hand', '/weapons/longsword', '/weapons/rapier', '/weapons/shortsword'},
      );

  @override
  final Map<StatKind, int> statBonuses;

  Thief._({
    required this.knownSpells,
    required super.level,
    required super.isMain,
    required this.baseAbilities,
    this.statBonuses = const {},
  });

  final List<Peculiarity> baseAbilities;

  @override
  List<Peculiarity> get abilities {
    final stealthDamage = (level + 1) ~/ 2;
    return [
      Peculiarity(
        name: 'СКРЫТАЯ АТАКА',
        description:
            '''Вы знаете, как точно наносить удар и использовать отвлечение врага. Один раз в ход вы можете причинить дополнительные <b>$stealthDamageк6</b> урона одному из существ, по которому вы попали атакой, совершённой с преимуществом. Атака должна использовать дальнобойное оружие или оружие со свойством «фехтовальное». Вам не нужно иметь преимущество при броске атаки, если другой враг цели находится в пределах 5 футов от неё. Этот враг не должен быть недееспособным, и у вас не должно быть помехи для броска атаки.''',
      ),
      ...baseAbilities,
    ];
  }

  @override
  String name = 'Плут';

  @override
  Dice hitDice = Dice.k8;

  @override
  int healthPerLevel = 5;

  @override
  int startHealth = 8;

  @override
  String classExtraDescription(ClassExtras extra) => '';

  @override
  StatKind? spellKind;

  @override
  final List<ClassExtras> classExtras = [];

  @override
  int getClassExtrasCount(Player player, ClassExtras extra) => 0;

  @override
  late List<StatKind> chosenSaveThrows = [
    StatKind.dexterity,
    StatKind.intelligence,
  ];

  @override
  final List<Spell> knownSpells;

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'knownSpells': knownSpells.map((e) => e.toJson()).toList(),
        'level': level,
        'isMain': isMain,
        'statBonuses': statBonuses.map((key, value) => MapEntry(key.toJson(), value)),
        'baseAbilities': baseAbilities.map((e) => e.toJson()).toList(),
        if (fightingStyle != null) 'fightingStyle': fightingStyle!.name,
      };

  static Thief fromJson(Map<String, dynamic> json) => Thief._(
        baseAbilities: (json['baseAbilities'] as List).map((e) => Peculiarity.fromJson(e)).toList(),
        knownSpells: (json['knownSpells'] as List).map((e) => Spell.fromJson(e)).toList(),
        level: json['level'],
        isMain: json['isMain'],
        statBonuses: (json['statBonuses'] as Map).map((key, value) => MapEntry(StatKind.fromJson(key), value)),
      );

  factory Thief.level1({
    required bool isMain,
  }) =>
      Thief._(
        knownSpells: [],
        level: 1,
        isMain: isMain,
        baseAbilities: [
          const Peculiarity(
            name: 'ВОРОВСКОЙ ЖАРГОН',
            description:
                '''Во время плутовского обучения вы выучили воровской жаргон, тайную смесь диалекта, жаргона и шифра, который позволяет скрывать сообщения в, казалось бы, обычном разговоре. Только другое существо, знающее воровской жаргон, понимает такие сообщения. Это занимает в четыре раза больше времени, нежели передача тех же слов прямым текстом.

Кроме того, вы понимаете набор секретных знаков и символов, используемый для передачи коротких и простых сообщений. Например, является ли область опасной или территорией гильдии воров, находится ли поблизости добыча, простодушны ли люди в округе, и предоставляют ли здесь безопасное убежище для воров в бегах.''',
          ),
        ],
      );

  factory Thief.level2({
    required bool isMain,
    required List<Peculiarity> abilities,
  }) =>
      Thief._(
        knownSpells: [],
        level: 1,
        isMain: isMain,
        baseAbilities: [
          ...abilities,
          const Peculiarity(
            name: 'ХИТРОЕ ДЕЙСТВИЕ',
            description:
                '''Ваше мышление и ловкость позволяют двигаться и действовать быстрее. Вы можете в каждом своем ходу боя совершать бонусное действие. Это действие может быть использовано только для <b>Рывка</b>, <b>Отхода</b> или <b>Засады</b>.''',
          ),
        ],
      );
}
