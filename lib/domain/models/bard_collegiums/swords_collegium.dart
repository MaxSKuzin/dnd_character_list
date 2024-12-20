import 'package:dnd_character_list/domain/models/bard_collegiums/bard_collegium.dart';
import 'package:dnd_character_list/domain/models/classes/class_ability.dart';

class SwordsCollegium extends BardCollegium {
  final FightingStyle fightingStyle;

  SwordsCollegium({required this.fightingStyle}) : super();

  @override
  String get description =>
      '''Бардов Коллегии Мечей называют клинками, и они выступают на публике, выказывая свое мастерство обращения с оружием. Клинки выполняют такие трюки как шпагоглотание, метание и жонглирование кинжалами и демонстрационные бои. Хоть они и используют свое оружие для развлечения, они хорошо натренированные и умелые бойцы. Талант обращения с оружием вдохновляет многих клинков вести двойную жизнь.

Клинок может использовать цирковую труппу, чтобы прикрывать такие гнусные дела как убийства, ограбления и шантаж. Другие клинки сражают злодеев, воздают по справедливости тем, кто жесток и могущественен. Многие труппы рады принять талант клинка ради зрелищности, которую он добавит представлению, но мало кто полностью доверяет клинку в своих рядах.

Клинки часто забрасывают жизнь артистов просто потому, что сталкиваются с неприятностями, после которых трудно скрыть их тайную деятельность. Клинок, пойманный на воровстве или в качестве мстителя – слишком большая обуза для большинства трупп.

Со своими навыками обращения с оружием и магией, эти клинки либо работают силовиками на гильдии воров, либо начинают скитаться сами по себе как искатели приключений.''';

  @override
  List<ClassAbility> getAbilities(int level) {
    final abilities = <ClassAbility>[];
    if (level >= 3) {
      abilities.addAll(
        [
          ClassAbility(
            name: 'БОЕВОЙ СТИЛЬ',
            description: switch (fightingStyle) {
              FightingStyle.dueling =>
                'Дуэлянт. Пока вы держите рукопашное оружие в одной руке и не используете другого оружия, вы получаете бонус +2 к броскам урона этим оружием.',
              FightingStyle.twoWeaponFighting =>
                'Сражение двумя оружиями. Если вы сражаетесь двумя оружиями, вы можете добавить модификатор характеристики к урону от второй атаки.',
            },
          ),
          const ClassAbility(
            name: 'ДОПОЛНИТЕЛЬНЫЕ ВЛАДЕНИЯ',
            description:
                'Когда вы вступаете в Коллегию Мечей, вы получаете владение средними доспехами и скимитарами. Если вы владеете простым или воинским оружием ближнего боя, то можете использовать его в качестве фокусировки для ваших заклинаний барда.',
          ),
          const ClassAbility(
            name: 'РОСЧЕРК КЛИНКА',
            description: '''
Вы учитесь исполнять впечатляющие демонстрации боевого мастерства и проворства. Когда вы совершаете действие Атака в свой ход, ваша скорость ходьбы увеличивается на 10 футов до конца хода, а если атака оружием, которую вы совершаете частью этого действия, попадает по существу, вы можете использовать один из следующих вариантов «Росчерка клинка» по своему выбору. Вы можете использовать только один вариант «Росчерка клинка» за ход.

Оборонительный росчерк. Вы можете потратить одно свое «Вдохновение барда», чтобы оружие нанесло дополнительный урон по цели. Урон равен числу, выпавшему на кости бардовского вдохновения. Вы также добавляете это число к своему КД до начала своего следующего хода.

Режущий росчерк. Вы можете потратить одно свое «Вдохновение барда», чтобы оружие нанесло дополнительный урон по цели и по любому другому существу по вашему выбору, которое вы можете видеть в 5 футах от себя. Урон равен числу, выпавшему на кости бардовского вдохновения.

Мобильный росчерк. Вы можете потратить одно свое «Вдохновение барда», чтобы оружие нанесло дополнительный урон по цели. Урон равен числу, выпавшему на кости бардовского вдохновения. Вы также можете оттолкнуть цель на 5 футов от себя, плюс количество футов, выпавшее на кости бардовского вдохновения. После этого вы незамедлительно можете реакцией переместиться на расстояние не большее своей скорости в незанятое место в 5 футах от цели.''',
          ),
        ],
      );
    }
    if (level >= 6) {
      abilities.add(
        const ClassAbility(
          name: 'ДОПОЛНИТЕЛЬНАЯ АТАКА',
          description: 'Если вы в свой ход совершаете действие Атака, вы можете совершить две атаки вместо одной.',
        ),
      );
    }
    if (level >= 14) {
      abilities.add(
        const ClassAbility(
          name: 'МАСТЕРСКИЙ РОСЧЕРК',
          description:
              'Когда вы используете вариант «Росчерка клинка», вы можете совершить бросок к6 и использовать его вместо траты кости бардовского вдохновения.',
        ),
      );
    }
    return abilities;
  }

  @override
  String get name => 'КОЛЛЕГИЯ МЕЧЕЙ';

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'fightingStyle': fightingStyle.name,
      };

  static BardCollegium fromJson(Map<String, dynamic> json) {
    return SwordsCollegium(
      fightingStyle: FightingStyle.fromName(json['fightingStyle']),
    );
  }
}

enum FightingStyle {
  dueling,
  twoWeaponFighting;

  String get title => switch (this) {
        FightingStyle.dueling => 'Дуэлянт',
        FightingStyle.twoWeaponFighting => 'Сражение двумя оружиями',
      };

  String get name => switch (this) {
        FightingStyle.dueling => 'dueling',
        FightingStyle.twoWeaponFighting => 'twoWeaponFighting',
      };

  String get description => switch (this) {
        FightingStyle.dueling =>
          'Пока вы держите рукопашное оружие в одной руке и не используете другого оружия, вы получаете бонус +2 к броскам урона этим оружием.',
        FightingStyle.twoWeaponFighting =>
          'Если вы сражаетесь двумя оружиями, вы можете добавить модификатор характеристики к урону от второй атаки.',
      };

  static FightingStyle fromName(String name) => switch (name) {
        'dueling' => FightingStyle.dueling,
        'twoWeaponFighting' => FightingStyle.twoWeaponFighting,
        _ => throw ArgumentError('Unknown fighting style: $name'),
      };
}