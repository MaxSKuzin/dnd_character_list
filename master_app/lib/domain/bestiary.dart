import 'package:dnd_master/domain/models/monster.dart';

/// Типовые монстры для быстрого добавления в бой. Статблоки — «Бестиарий» (SRD 5e, правила 2014 года).
abstract final class Bestiary {
  static MonsterTemplate? byId(String id) => monsters.where((e) => e.id == id).firstOrNull;

  static const monsters = [goblin, hobgoblin, bugbear, kobold, bandit, orc, skeleton, zombie, wolf, giantRat];

  static const goblin = MonsterTemplate(
    id: 'goblin',
    name: 'Гоблин',
    kind: 'Маленький гуманоид (гоблиноид), нейтрально-злой',
    challenge: '1/4',
    experience: 50,
    armorClass: 15,
    armorNote: 'кожаный доспех, щит',
    hitDice: DiceFormula(2, 6),
    speed: 30,
    abilities: AbilityScores(8, 14, 10, 10, 8, 8),
    passivePerception: 9,
    traits: [
      MonsterFeature('Проворный побег', 'Может бонусным действием совершить Отход или Засаду в каждый свой ход.'),
    ],
    actions: [
      MonsterFeature(
        'Скимитар',
        'Рукопашная атака оружием: +4 к попаданию, 5 фт. Попадание: 5 (1к6 + 2) рубящего урона.',
      ),
      MonsterFeature(
        'Короткий лук',
        'Дальнобойная атака оружием: +4 к попаданию, 80/320 фт. Попадание: 5 (1к6 + 2) колющего урона.',
      ),
    ],
  );

  static const hobgoblin = MonsterTemplate(
    id: 'hobgoblin',
    name: 'Хобгоблин',
    kind: 'Средний гуманоид (гоблиноид), законно-злой',
    challenge: '1/2',
    experience: 100,
    armorClass: 18,
    armorNote: 'кольчуга, щит',
    hitDice: DiceFormula(2, 8, 2),
    speed: 30,
    abilities: AbilityScores(13, 12, 12, 10, 10, 9),
    passivePerception: 10,
    traits: [
      MonsterFeature(
        'Воинское превосходство',
        'Раз в ход причиняет дополнительно 7 (2к6) урона существу, которое он поразил атакой оружием, если в пределах '
            '5 фт. от цели есть его дееспособный союзник.',
      ),
    ],
    actions: [
      MonsterFeature(
        'Длинный меч',
        'Рукопашная атака оружием: +3 к попаданию, 5 фт. Попадание: 5 (1к8 + 1) рубящего урона, или 6 (1к10 + 1), '
            'если двумя руками.',
      ),
      MonsterFeature(
        'Длинный лук',
        'Дальнобойная атака оружием: +3 к попаданию, 150/600 фт. Попадание: 5 (1к8 + 1) колющего урона.',
      ),
    ],
  );

  static const bugbear = MonsterTemplate(
    id: 'bugbear',
    name: 'Багбир',
    kind: 'Средний гуманоид (гоблиноид), хаотично-злой',
    challenge: '1',
    experience: 200,
    armorClass: 16,
    armorNote: 'шкурный доспех, щит',
    hitDice: DiceFormula(5, 8, 5),
    speed: 30,
    abilities: AbilityScores(15, 14, 13, 8, 11, 9),
    passivePerception: 10,
    traits: [
      MonsterFeature('Громила', 'Атака рукопашным оружием причиняет одну дополнительную кость урона (уже учтено).'),
      MonsterFeature(
        'Внезапное нападение',
        'Если застаёт существо врасплох и попадает по нему в первом раунде, цель получает дополнительно 7 (2к6) урона.',
      ),
    ],
    actions: [
      MonsterFeature(
        'Моргенштерн',
        'Рукопашная атака оружием: +4 к попаданию, 5 фт. Попадание: 11 (2к8 + 2) колющего урона.',
      ),
      MonsterFeature(
        'Метательное копьё',
        'Рукопашная или дальнобойная атака оружием: +4 к попаданию, 5 фт. или 30/120 фт. Попадание: 9 (2к6 + 2) колющего '
            'урона в рукопашной или 5 (1к6 + 2) при броске.',
      ),
    ],
  );

  static const kobold = MonsterTemplate(
    id: 'kobold',
    name: 'Кобольд',
    kind: 'Маленький гуманоид (кобольд), законно-злой',
    challenge: '1/8',
    experience: 25,
    armorClass: 12,
    hitDice: DiceFormula(2, 6, -2),
    speed: 30,
    abilities: AbilityScores(7, 15, 9, 8, 7, 8),
    passivePerception: 8,
    traits: [
      MonsterFeature(
        'Чувствительность к солнцу',
        'На солнце помеха на броски атаки и проверки Мудрости (Внимательность), полагающиеся на зрение.',
      ),
      MonsterFeature(
        'Тактика стаи',
        'Преимущество на атаку, если в пределах 5 фт. от цели есть его дееспособный союзник.',
      ),
    ],
    actions: [
      MonsterFeature(
        'Кинжал',
        'Рукопашная атака оружием: +4 к попаданию, 5 фт. Попадание: 4 (1к4 + 2) колющего урона.',
      ),
      MonsterFeature(
        'Праща',
        'Дальнобойная атака оружием: +4 к попаданию, 30/120 фт. Попадание: 4 (1к4 + 2) дробящего урона.',
      ),
    ],
  );

  static const bandit = MonsterTemplate(
    id: 'bandit',
    name: 'Бандит',
    kind: 'Средний гуманоид (любая раса), любое не-законное мировоззрение',
    challenge: '1/8',
    experience: 25,
    armorClass: 12,
    armorNote: 'кожаный доспех',
    hitDice: DiceFormula(2, 8, 2),
    speed: 30,
    abilities: AbilityScores(11, 12, 12, 10, 10, 10),
    passivePerception: 10,
    actions: [
      MonsterFeature(
        'Скимитар',
        'Рукопашная атака оружием: +3 к попаданию, 5 фт. Попадание: 4 (1к6 + 1) рубящего урона.',
      ),
      MonsterFeature(
        'Лёгкий арбалет',
        'Дальнобойная атака оружием: +3 к попаданию, 80/320 фт. Попадание: 5 (1к8 + 1) колющего урона.',
      ),
    ],
  );

  static const orc = MonsterTemplate(
    id: 'orc',
    name: 'Орк',
    kind: 'Средний гуманоид (орк), хаотично-злой',
    challenge: '1/2',
    experience: 100,
    armorClass: 13,
    armorNote: 'шкурный доспех',
    hitDice: DiceFormula(2, 8, 6),
    speed: 30,
    abilities: AbilityScores(16, 12, 16, 7, 11, 10),
    passivePerception: 10,
    traits: [
      MonsterFeature(
        'Агрессивный',
        'Бонусным действием перемещается на расстояние до своей скорости к видимому враждебному существу.',
      ),
    ],
    actions: [
      MonsterFeature(
        'Секира',
        'Рукопашная атака оружием: +5 к попаданию, 5 фт. Попадание: 9 (1к12 + 3) рубящего урона.',
      ),
      MonsterFeature(
        'Метательное копьё',
        'Рукопашная или дальнобойная атака оружием: +5 к попаданию, 5 фт. или 30/120 фт. Попадание: 6 (1к6 + 3) колющего урона.',
      ),
    ],
  );

  static const skeleton = MonsterTemplate(
    id: 'skeleton',
    name: 'Скелет',
    kind: 'Средняя нежить, законно-злая',
    challenge: '1/4',
    experience: 50,
    armorClass: 13,
    armorNote: 'обрывки доспеха',
    hitDice: DiceFormula(2, 8, 4),
    speed: 30,
    abilities: AbilityScores(10, 14, 15, 6, 8, 5),
    passivePerception: 9,
    traits: [
      MonsterFeature('Уязвимость', 'Дробящий урон.'),
      MonsterFeature('Иммунитет', 'Урон ядом; состояния «истощённый» и «отравленный».'),
    ],
    actions: [
      MonsterFeature(
        'Короткий меч',
        'Рукопашная атака оружием: +4 к попаданию, 5 фт. Попадание: 5 (1к6 + 2) колющего урона.',
      ),
      MonsterFeature(
        'Короткий лук',
        'Дальнобойная атака оружием: +4 к попаданию, 80/320 фт. Попадание: 5 (1к6 + 2) колющего урона.',
      ),
    ],
  );

  static const zombie = MonsterTemplate(
    id: 'zombie',
    name: 'Зомби',
    kind: 'Средняя нежить, нейтрально-злая',
    challenge: '1/4',
    experience: 50,
    armorClass: 8,
    hitDice: DiceFormula(3, 8, 9),
    speed: 20,
    abilities: AbilityScores(13, 6, 16, 3, 6, 5),
    passivePerception: 8,
    traits: [
      MonsterFeature(
        'Стойкость нежити',
        'Если урон опускает хиты до 0, спасбросок Телосложения со Сл 5 + полученный урон: при успехе остаётся с 1 хитом. '
            'Не действует на излучение и критические попадания.',
      ),
      MonsterFeature('Иммунитет', 'Урон ядом; состояние «отравленный».'),
    ],
    actions: [
      MonsterFeature(
        'Размашистый удар',
        'Рукопашная атака оружием: +3 к попаданию, 5 фт. Попадание: 4 (1к6 + 1) дробящего урона.',
      ),
    ],
  );

  static const wolf = MonsterTemplate(
    id: 'wolf',
    name: 'Волк',
    kind: 'Средний зверь, без мировоззрения',
    challenge: '1/4',
    experience: 50,
    armorClass: 13,
    armorNote: 'природный доспех',
    hitDice: DiceFormula(2, 8, 2),
    speed: 40,
    abilities: AbilityScores(12, 15, 12, 3, 12, 6),
    passivePerception: 13,
    traits: [
      MonsterFeature(
        'Тонкий слух и острый нюх',
        'Преимущество на проверки Мудрости (Внимательность), полагающиеся на слух и обоняние.',
      ),
      MonsterFeature(
        'Тактика стаи',
        'Преимущество на атаку, если в пределах 5 фт. от цели есть его дееспособный союзник.',
      ),
    ],
    actions: [
      MonsterFeature(
        'Укус',
        'Рукопашная атака оружием: +4 к попаданию, 5 фт. Попадание: 7 (2к4 + 2) колющего урона. Цель-существо должна '
            'преуспеть в спасброске Силы со Сл 11, иначе падает ничком.',
      ),
    ],
  );

  static const giantRat = MonsterTemplate(
    id: 'giant_rat',
    name: 'Гигантская крыса',
    kind: 'Маленький зверь, без мировоззрения',
    challenge: '1/8',
    experience: 25,
    armorClass: 12,
    hitDice: DiceFormula(2, 6),
    speed: 30,
    abilities: AbilityScores(7, 15, 11, 2, 10, 4),
    passivePerception: 10,
    traits: [
      MonsterFeature('Тонкий нюх', 'Преимущество на проверки Мудрости (Внимательность), полагающиеся на обоняние.'),
      MonsterFeature(
        'Тактика стаи',
        'Преимущество на атаку, если в пределах 5 фт. от цели есть её дееспособный союзник.',
      ),
    ],
    actions: [
      MonsterFeature('Укус', 'Рукопашная атака оружием: +4 к попаданию, 5 фт. Попадание: 4 (1к4 + 2) колющего урона.'),
    ],
  );
}
