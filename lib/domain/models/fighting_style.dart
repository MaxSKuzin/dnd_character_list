enum FightingStyle {
  dueling,
  twoWeaponFighting,
  protection,
  defence,
  bigWeapon;

  String get name => switch (this) {
        FightingStyle.dueling => 'dueling',
        FightingStyle.twoWeaponFighting => 'twoWeaponFighting',
        FightingStyle.protection => 'protection',
        FightingStyle.defence => 'defense',
        FightingStyle.bigWeapon => 'bigWeapon',
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
      };

  static FightingStyle fromName(String name) => switch (name) {
        'dueling' => FightingStyle.dueling,
        'twoWeaponFighting' => FightingStyle.twoWeaponFighting,
        _ => throw ArgumentError('Unknown fighting style: $name'),
      };
}
