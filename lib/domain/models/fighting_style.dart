import 'package:dnd_character_list/domain/models/peculiarity.dart';

enum FightingStyle {
  dueling,
  twoWeaponFighting,
  protection,
  defence,
  bigWeapon,
  archery,

  // Стили из «Котла Таши» (TCE).
  blindFighting,
  interception,
  thrownWeaponFighting,
  unarmedFighting,
  superiorTechnique,
  druidicWarrior;

  /// Стили паладина: у него нет стрельбы, сражения двумя оружиями и части стилей TCE.
  static const paladinStyles = [dueling, protection, defence, bigWeapon, blindFighting, interception];

  /// Стили следопыта: «Воин-друид» есть только у него.
  static const rangerStyles = [
    archery,
    defence,
    dueling,
    twoWeaponFighting,
    blindFighting,
    druidicWarrior,
    thrownWeaponFighting
  ];

  /// Стили воина: все, кроме «Воина-друида».
  static List<FightingStyle> get fighterStyles => values.where((e) => e != druidicWarrior).toList();

  String get name => switch (this) {
        FightingStyle.dueling => 'dueling',
        FightingStyle.twoWeaponFighting => 'twoWeaponFighting',
        FightingStyle.protection => 'protection',
        FightingStyle.defence => 'defense',
        FightingStyle.bigWeapon => 'bigWeapon',
        FightingStyle.archery => 'archery',
        FightingStyle.blindFighting => 'blindFighting',
        FightingStyle.interception => 'interception',
        FightingStyle.thrownWeaponFighting => 'thrownWeaponFighting',
        FightingStyle.unarmedFighting => 'unarmedFighting',
        FightingStyle.superiorTechnique => 'superiorTechnique',
        FightingStyle.druidicWarrior => 'druidicWarrior',
      };

  String get title => switch (this) {
        FightingStyle.dueling => 'Дуэлянт',
        FightingStyle.twoWeaponFighting => 'Сражение двумя оружиями',
        FightingStyle.protection => 'Защита',
        FightingStyle.defence => 'Оборона',
        FightingStyle.bigWeapon => 'Сражение большим оружием',
        FightingStyle.archery => 'Стрельба',
        FightingStyle.blindFighting => 'Сражение вслепую',
        FightingStyle.interception => 'Перехват',
        FightingStyle.thrownWeaponFighting => 'Сражение метательным оружием',
        FightingStyle.unarmedFighting => 'Сражение голыми руками',
        FightingStyle.superiorTechnique => 'Превосходная техника',
        FightingStyle.druidicWarrior => 'Воин-друид',
      };

  String get description => switch (this) {
        FightingStyle.dueling =>
          '<b>Дуэлянт</b>. Пока вы держите рукопашное оружие в одной руке и не используете другого оружия, вы получаете бонус +2 к броскам урона этим оружием.',
        FightingStyle.twoWeaponFighting =>
          '<b>Сражение двумя оружиями</b>. Если вы сражаетесь двумя оружиями, вы можете добавить модификатор характеристики к урону от второй атаки.',
        FightingStyle.protection =>
          '<b>Защита</b>. Если существо, которое вы видите, атакует не вас, а другое существо, находящееся в пределах 5 футов от вас, вы можете реакцией создать помеху его броску атаки. Для этого вы должны использовать щит.',
        FightingStyle.defence => '<b>Оборона</b>. Пока вы носите доспехи, вы получаете бонус +1 к КД.',
        FightingStyle.bigWeapon =>
          '<b>Сражение большим оружием</b>. Если у вас выпало «1» или «2» на кости урона при атаке, которую вы совершали рукопашным оружием, удерживая его двумя руками, то вы можете перебросить эту кость, и должны использовать новый результат. Чтобы воспользоваться этим преимуществом, ваше оружие должно иметь свойство «двуручное» или «универсальное».',
        FightingStyle.archery =>
          '<b>Стрельба</b>. Вы получаете бонус +2 к броску атаки, когда атакуете дальнобойным оружием.',
        FightingStyle.blindFighting =>
          '<b>Сражение вслепую</b>. Вы получаете слепое зрение в пределах 10 футов: видите всё, что не находится за полным укрытием, даже если вы ослеплены или в темноте, и видите невидимых существ, если они не спрятались от вас.',
        FightingStyle.interception =>
          '<b>Перехват</b>. Когда видимое вами существо попадает атакой по цели в пределах 5 футов от вас (но не по вам), вы можете реакцией уменьшить урон на 1к10 + бонус мастерства. Нужно держать щит либо простое или воинское оружие.',
        FightingStyle.thrownWeaponFighting =>
          '<b>Сражение метательным оружием</b>. Частью атаки метательным оружием вы можете достать его из ножен. Ваши дальнобойные атаки метательным оружием получают +2 к урону.',
        FightingStyle.unarmedFighting =>
          '<b>Сражение голыми руками</b>. Ваши безоружные атаки наносят урон 1к6 + модификатор Силы, а если вы не держите ни оружия, ни щита — 1к8 + модификатор Силы. В начале каждого хода вы наносите 1к4 дробящего урона существу в вашем захвате.',
        FightingStyle.superiorTechnique =>
          '<b>Превосходная техника</b>. Вы изучаете один приём мастера боевых искусств и получаете одну кость превосходства к6 (в дополнение к другим), которая восстанавливается после короткого или продолжительного отдыха.',
        FightingStyle.druidicWarrior =>
          '<b>Воин-друид</b>. Вы узнаёте два заговора из списка друида на ваш выбор. Они считаются для вас заклинаниями следопыта, базовая характеристика — Мудрость. Получая уровень следопыта, можно заменить один из них другим заговором друида.',
      };

  static FightingStyle fromName(String name) => values.firstWhere(
        (e) => e.name == name,
        orElse: () => throw ArgumentError('Unknown fighting style: $name'),
      );
}

/// Умения «Боевой стиль» с выбранными стилями: «БОЕВОЙ СТИЛЬ: СТРЕЛЬБА», в начале описания — что даёт стиль, ниже —
/// текст умения с сайта. Стили по порядку достаются умениям «Боевой стиль» и «Дополнительный боевой стиль» чемпиона;
/// стиль, для которого умения нет (коллегия мечей барда), добавляется отдельной особенностью.
List<Peculiarity> withFightingStyles(List<Peculiarity> features, List<FightingStyle> styles) {
  const styleFeatures = {'БОЕВОЙ СТИЛЬ', 'ДОПОЛНИТЕЛЬНЫЙ БОЕВОЙ СТИЛЬ'};
  final remaining = [...styles];
  final result = [
    for (final feature in features)
      if (styleFeatures.contains(feature.name) && remaining.isNotEmpty)
        _withStyle(feature, remaining.removeAt(0))
      else
        feature,
  ];
  return [
    for (final style in remaining)
      Peculiarity(name: 'БОЕВОЙ СТИЛЬ: ${style.title.toUpperCase()}', description: style.description, isHtml: true),
    ...result,
  ];
}

Peculiarity _withStyle(Peculiarity feature, FightingStyle style) => Peculiarity(
      name: '${feature.name}: ${style.title.toUpperCase()}',
      description: feature.isHtml ? '<p>${style.description}</p><hr>${feature.description}' : style.description,
      isHtml: feature.isHtml,
    );
