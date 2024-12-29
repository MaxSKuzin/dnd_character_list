import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/fighting_style.dart';
import 'package:dnd_character_list/domain/models/peculiarity.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';

final class Paladin extends Specialization {
  @override
  ClassKind get classKind => ClassKind.paladin;

  @override
  final Map<StatKind, int> statBonuses;

  @override
  final FightingStyle? fightingStyle;

  Paladin._({
    required this.fightingStyle,
    required this.knownSpells,
    required super.level,
    required super.isMain,
    required this.baseAbilities,
    this.statBonuses = const {},
  });

  final List<Peculiarity> baseAbilities;

  @override
  List<Peculiarity> get abilities => [
        ...baseAbilities,
        if (fightingStyle != null)
          Peculiarity(
            name: 'БОЕВОЙ СТИЛЬ',
            description: fightingStyle!.description,
          ),
      ];

  @override
  String name = 'Паладин';

  @override
  Dice hitDice = Dice.k10;

  @override
  int healthPerLevel = 6;

  @override
  int startHealth = 10;

  @override
  late String classExtraDescription = '''
Присутствие сильного зла воспринимается вашими чувствами как неприятный запах, а могущественное добро звучит как небесная музыка в ваших ушах. Вы можете действием открыть своё сознание для обнаружения таких сил. Вы до конца своего следующего хода знаете местоположение всех Исчадий, Небожителей и Нежити в пределах 60 футов, не имеющих полного укрытия. Вы знаете вид (Исчадие, Небожитель, Нежить) любого существа, чьё присутствие вы чувствуете, но не можете определить, кто это конкретно (например, вампир граф Страд фон Зарович). В этом же радиусе вы также обнаруживаете присутствие мест и предметов, которые были освящены или осквернены.

Когда вы заканчиваете продолжительный отдых, вы восстанавливаете все потраченные использования.
''';

  @override
  StatKind spellKind = StatKind.charisma;

  @override
  final ClassExtras? classExtra = ClassExtras.godFeeling;

  @override
  int getClassExtrasCount(Player player) => 1 + player.charisma.bonus;

  @override
  late List<StatKind> chosenSaveThrows = [
    StatKind.wisdom,
    StatKind.charisma,
  ];

  @override
  final List<Spell> knownSpells;

  @override
  bool get canUseTwoWeapons {
    return fightingStyle == FightingStyle.twoWeaponFighting;
  }

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

  static Paladin fromJson(Map<String, dynamic> json) => Paladin._(
        baseAbilities: (json['baseAbilities'] as List).map((e) => Peculiarity.fromJson(e)).toList(),
        knownSpells: (json['knownSpells'] as List).map((e) => Spell.fromJson(e)).toList(),
        level: json['level'],
        isMain: json['isMain'],
        statBonuses: (json['statBonuses'] as Map).map((key, value) => MapEntry(StatKind.fromJson(key), value)),
        fightingStyle: json['fightingStyle'] == null ? null : FightingStyle.fromName(json['fightingStyle']),
      );

  factory Paladin.level1({
    required bool isMain,
  }) =>
      Paladin._(
        fightingStyle: null,
        knownSpells: [],
        level: 1,
        isMain: isMain,
        baseAbilities: [
          const Peculiarity(
            name: 'НАЛОЖЕНИЕ РУК',
            description:
                '''Ваше благословенное касание может лечить раны. У вас есть запас целительной силы, который восстанавливается после продолжительного отдыха. При помощи этого запаса вы можете восстанавливать количество хитов, равное уровню паладина, умноженному на 5.

Вы можете действием коснуться существа и, зачерпнув силу из запаса, восстановить количество хитов этого существа на любое число, вплоть до максимума, оставшегося в вашем запасе.

В качестве альтернативы, вы можете потратить 5 хитов из вашего запаса хитов для излечения цели от одной болезни или одного действующего на неё яда. Вы можете устранить несколько эффектов болезни и ядов одним использованием «Наложения рук», тратя хиты отдельно для каждого эффекта.

Это умение не оказывает никакого эффекта на Нежить и Конструктов.''',
          ),
        ],
      );

  factory Paladin.level2({
    required bool isMain,
    required List<Spell> knownSpells,
    required FightingStyle fightingStyle,
    required List<Peculiarity> abilities,
  }) =>
      Paladin._(
        fightingStyle: fightingStyle,
        baseAbilities: [
          ...abilities,
          const Peculiarity(
            manaRequired: SpellSlot.level1,
            name: 'БОЖЕСТВЕННАЯ КАРА',
            description:
                '''Если вы попадаете по существу рукопашной атакой оружием, вы можете потратить одну ячейку заклинаний любого своего класса для причинения цели урона излучением, который добавится к урону от оружия. Если цель — Нежить или Исчадие, урон увеличивается на 1к8.''',
          ),
        ],
        knownSpells: knownSpells,
        level: 2,
        isMain: isMain,
      );
}
