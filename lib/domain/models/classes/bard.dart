import 'package:dnd_character_list/domain/models/bard_collegiums/bard_collegium.dart';
import 'package:dnd_character_list/domain/models/bard_collegiums/swords_collegium.dart';
import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/peculiarity.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';

final class Bard extends Specialization {
  @override
  ClassKind get classKind => ClassKind.bard;

  @override
  final Map<StatKind, int> statBonuses;

  final List<StatKind> doubledSaveThrows;

  final BardCollegium? collegium;

  Bard._({
    required this.knownSpells,
    required super.level,
    required super.isMain,
    required this.inspirationDice,
    required this.collegium,
    required this.baseAbilities,
    this.statBonuses = const {},
    this.doubledSaveThrows = const [],
  });

  final List<Peculiarity> baseAbilities;

  @override
  List<Peculiarity> get abilities => [
        ...baseAbilities,
        ...collegium?.getAbilities(level) ?? [],
      ];
  @override
  String name = 'Бард';

  @override
  Dice hitDice = Dice.k8;

  @override
  int healthPerLevel = 5;

  @override
  int startHealth = 8;

  Dice inspirationDice;

  @override
  late String classExtraDescription = '''
Своими словами или музыкой вы можете вдохновлять других. Для этого вы должны бонусным действием выбрать одно существо, отличное от вас, в пределах 60 футов, которое может вас слышать. Это существо получает кость бардовского вдохновения — ${inspirationDice.name}.

В течение следующих 10 минут это существо может один раз бросить эту кость и добавить результат к проверке характеристики, броску атаки или спасброску, который оно совершает. Существо может принять решение о броске кости вдохновения уже после броска к20, но должно сделать это прежде, чем Мастер объявит результат броска. Как только кость бардовского вдохновения брошена, она исчезает. Существо может иметь только одну такую кость одновременно.

Потраченные использования этого умения восстанавливаются после продолжительного отдыха.
''';

  @override
  StatKind spellKind = StatKind.charisma;

  @override
  final ClassExtras classExtra = ClassExtras.inspiration;

  @override
  int getClassExtrasCount(Player player) => player.charisma.bonus;

  @override
  late List<StatKind> chosenSaveThrows = [
    StatKind.dexterity,
    StatKind.charisma,
    ...doubledSaveThrows,
  ];

  @override
  final List<Spell> knownSpells;

  @override
  bool get canUseTwoWeapons {
    if (collegium is SwordsCollegium) {
      return (collegium as SwordsCollegium).fightingStyle == FightingStyle.twoWeaponFighting;
    }
    return false;
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'knownSpells': knownSpells.map((e) => e.toJson()).toList(),
        'level': level,
        'isMain': isMain,
        'inspirationDice': inspirationDice.toJson(),
        'statBonuses': statBonuses.map((key, value) => MapEntry(key.toJson(), value)),
        'doubledSaveThrows': doubledSaveThrows.map((e) => e.toJson()).toList(),
        'collegium': collegium?.toJson(),
        'baseAbilities': baseAbilities.map((e) => e.toJson()).toList(),
      };

  static Bard fromJson(Map<String, dynamic> json) => Bard._(
        baseAbilities: (json['baseAbilities'] as List).map((e) => Peculiarity.fromJson(e)).toList(),
        collegium: json['collegium'] == null ? null : BardCollegium.fromJson(json['collegium']),
        knownSpells: (json['knownSpells'] as List).map((e) => Spell.fromJson(e)).toList(),
        level: json['level'],
        isMain: json['isMain'],
        inspirationDice: Dice.fromJson(json['inspirationDice']),
        doubledSaveThrows: (json['doubledSaveThrows'] as List).map((e) => StatKind.fromJson(e)).toList(),
        statBonuses: (json['statBonuses'] as Map).map((key, value) => MapEntry(StatKind.fromJson(key), value)),
      );

  factory Bard.level1({
    required bool isMain,
    required List<Spell> knownSpells,
  }) =>
      Bard._(
        knownSpells: knownSpells,
        level: 1,
        isMain: isMain,
        inspirationDice: Dice.k6,
        collegium: null,
        baseAbilities: [],
      );

  factory Bard.level2({
    required bool isMain,
    required List<Spell> knownSpells,
  }) =>
      Bard._(
        collegium: null,
        baseAbilities: [
          const Peculiarity(
            name: 'МАСТЕР НА ВСЕ РУКИ',
            description:
                '''Вы можете добавлять половину бонуса мастерства, округлённую в меньшую сторону, ко всем проверкам характеристики, куда этот бонус еще не включён.''',
          ),
          const Peculiarity(
            name: 'ПЕСНЬ ОТДЫХА',
            description: '''
Вы с помощью успокаивающей музыки или речей можете помочь своим раненым союзникам восстановить их силы во время короткого отдыха. Если вы или любые союзные существа, способные слышать ваше исполнение, восстанавливаете хиты в конце короткого отдыха, используя Кости Хитов, каждое потратившее Кость Хитов существо восстанавливает дополнительно 1к6 хитов.

Количество дополнительно восстанавливаемых хитов растёт с вашим уровнем в этом классе: 1к8 на 9-м уровне, 1к10 на 13 уровне и 1к12 на 17 уровне.
''',
          ),
        ],
        knownSpells: knownSpells,
        level: 2,
        isMain: isMain,
        inspirationDice: Dice.k6,
      );

  factory Bard.level3({
    required bool isMain,
    required List<Spell> knownSpells,
    required List<Peculiarity> abilities,
    required BardCollegium collegium,
  }) =>
      Bard._(
        collegium: collegium,
        baseAbilities: abilities,
        knownSpells: knownSpells,
        level: 3,
        isMain: isMain,
        inspirationDice: Dice.k6,
      );

  factory Bard.level4({
    required bool isMain,
    required List<Spell> knownSpells,
    required List<Peculiarity> abilities,
    required BardCollegium collegium,
    required Map<StatKind, int> statBonuses,
  }) =>
      Bard._(
        statBonuses: statBonuses,
        collegium: collegium,
        baseAbilities: abilities,
        knownSpells: knownSpells,
        level: 4,
        isMain: isMain,
        inspirationDice: Dice.k6,
      );

  factory Bard.level5({
    required bool isMain,
    required List<Spell> knownSpells,
    required List<Peculiarity> abilities,
    required BardCollegium collegium,
    required Map<StatKind, int> statBonuses,
  }) =>
      Bard._(
        statBonuses: statBonuses,
        collegium: collegium,
        baseAbilities: [
          ...abilities,
          const Peculiarity(
            name: 'ИСТОЧНИК ВДОХНОВЕНИЯ',
            description:
                'Вы восстанавливаете истраченные вдохновения барда и после короткого, и после продолжительного отдыха.',
          ),
        ],
        knownSpells: knownSpells,
        level: 5,
        isMain: isMain,
        inspirationDice: Dice.k6,
      );

  factory Bard.level6({
    required bool isMain,
    required List<Spell> knownSpells,
    required List<Peculiarity> abilities,
    required BardCollegium collegium,
    required Map<StatKind, int> statBonuses,
  }) =>
      Bard._(
        statBonuses: statBonuses,
        collegium: collegium,
        baseAbilities: [
          ...abilities,
          const Peculiarity(
            name: 'КОНТРОЧАРОВАНИЕ',
            description:
                '''Вы получаете возможность использовать звуки или слова силы для разрушения воздействующих на разум эффектов. Вы можете действием начать исполнение, которое продлится до конца вашего следующего хода. В течение этого времени вы и все дружественные существа в пределах 30 футов от вас совершают спасброски от запугивания и очарования с преимуществом. Чтобы получить это преимущество, существа должны слышать вас. Исполнение заканчивается преждевременно, если вы оказываетесь недееспособны, теряете способность говорить, или прекращаете исполнение добровольно (на это не требуется действие).''',
          ),
        ],
        knownSpells: knownSpells,
        level: 6,
        isMain: isMain,
        inspirationDice: Dice.k6,
      );

  factory Bard.level7({
    required bool isMain,
    required List<Spell> knownSpells,
    required List<Peculiarity> abilities,
    required BardCollegium collegium,
    required Map<StatKind, int> statBonuses,
  }) =>
      Bard._(
        statBonuses: statBonuses,
        collegium: collegium,
        baseAbilities: abilities,
        knownSpells: knownSpells,
        level: 7,
        isMain: isMain,
        inspirationDice: Dice.k6,
      );

  factory Bard.level8({
    required bool isMain,
    required List<Spell> knownSpells,
    required List<Peculiarity> abilities,
    required BardCollegium collegium,
    required Map<StatKind, int> statBonuses,
  }) =>
      Bard._(
        statBonuses: statBonuses,
        collegium: collegium,
        baseAbilities: abilities,
        knownSpells: knownSpells,
        level: 8,
        isMain: isMain,
        inspirationDice: Dice.k6,
      );

  factory Bard.level9({
    required bool isMain,
    required List<Spell> knownSpells,
    required List<Peculiarity> abilities,
    required BardCollegium collegium,
    required Map<StatKind, int> statBonuses,
  }) =>
      Bard._(
        statBonuses: statBonuses,
        collegium: collegium,
        baseAbilities: abilities,
        knownSpells: knownSpells,
        level: 9,
        isMain: isMain,
        inspirationDice: Dice.k6,
      );
}
