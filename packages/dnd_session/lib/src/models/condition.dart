/// Состояние из приложения A «Книги игрока» — заготовка для [StatusEffect]. Истощение с уровнями пока не
/// поддерживается (можно поставить своим эффектом).
enum Condition {
  blinded,
  charmed,
  deafened,
  frightened,
  grappled,
  incapacitated,
  invisible,
  paralyzed,
  petrified,
  poisoned,
  prone,
  restrained,
  stunned,
  unconscious;

  String get title => switch (this) {
    Condition.blinded => 'Ослеплён',
    Condition.charmed => 'Очарован',
    Condition.deafened => 'Оглох',
    Condition.frightened => 'Испуган',
    Condition.grappled => 'Схвачен',
    Condition.incapacitated => 'Недееспособен',
    Condition.invisible => 'Невидим',
    Condition.paralyzed => 'Парализован',
    Condition.petrified => 'Окаменел',
    Condition.poisoned => 'Отравлен',
    Condition.prone => 'Сбит с ног',
    Condition.restrained => 'Опутан',
    Condition.stunned => 'Ошеломлён',
    Condition.unconscious => 'Без сознания',
  };

  /// Краткое правило — чтобы игрок и мастер не искали его в книге посреди боя.
  String get description => switch (this) {
    Condition.blinded =>
      'Не видит и автоматически проваливает проверки, требующие зрения. Броски атаки по нему — с преимуществом, '
          'его броски атаки — с помехой.',
    Condition.charmed =>
      'Не может атаковать очарователя или делать его целью вредных умений и заклинаний. Очарователь совершает '
          'с преимуществом проверки при социальном взаимодействии с ним.',
    Condition.deafened => 'Не слышит и автоматически проваливает проверки, требующие слуха.',
    Condition.frightened =>
      'Помеха на проверки характеристик и броски атаки, пока источник страха в пределах видимости. Не может '
          'добровольно приблизиться к источнику страха.',
    Condition.grappled =>
      'Скорость 0, бонусы к скорости не действуют. Состояние заканчивается, если схвативший недееспособен '
          'или цель вывели из его досягаемости.',
    Condition.incapacitated => 'Не может совершать действия и реакции.',
    Condition.invisible =>
      'Его невозможно увидеть без магии или особого чувства; для укрытия он считается сильно заслонённым. '
          'Броски атаки по нему — с помехой, его броски атаки — с преимуществом.',
    Condition.paralyzed =>
      'Недееспособен, не может перемещаться и говорить. Автоматически проваливает спасброски Силы и Ловкости. '
          'Броски атаки по нему — с преимуществом; попадание атакующего в пределах 5 футов — критическое.',
    Condition.petrified =>
      'Превращён в камень вместе с немагическими предметами, вес увеличивается в 10 раз, не стареет. '
          'Недееспособен, не может перемещаться и говорить, не осознаёт окружение. Броски атаки по нему — '
          'с преимуществом, автоматически проваливает спасброски Силы и Ловкости. Сопротивление всем видам урона, '
          'иммунитет к ядам и болезням (уже действующие приостанавливаются).',
    Condition.poisoned => 'Помеха на броски атаки и проверки характеристик.',
    Condition.prone =>
      'Может только ползти, пока не встанет (это стоит половину скорости). Помеха на броски атаки. Атаки по нему '
          'в пределах 5 футов — с преимуществом, с большего расстояния — с помехой.',
    Condition.restrained =>
      'Скорость 0, бонусы к скорости не действуют. Броски атаки по нему — с преимуществом, его броски атаки — '
          'с помехой. Помеха на спасброски Ловкости.',
    Condition.stunned =>
      'Недееспособен, не может перемещаться, говорит запинаясь. Автоматически проваливает спасброски Силы '
          'и Ловкости. Броски атаки по нему — с преимуществом.',
    Condition.unconscious =>
      'Недееспособен, не может перемещаться и говорить, не осознаёт окружение. Роняет всё, что держит, и падает '
          'ничком. Автоматически проваливает спасброски Силы и Ловкости. Броски атаки по нему — с преимуществом; '
          'попадание атакующего в пределах 5 футов — критическое.',
  };

  /// Имена — `name`, неизвестные (из другой версии приложения) пропускаются.
  static List<Condition> fromNames(Iterable names) =>
      names.map((e) => Condition.values.where((c) => c.name == e).firstOrNull).nonNulls.toList();
}

/// Эффект на участнике боя: стандартное [Condition] или своё от мастера («Удивлён — ты отказываешься биться»).
/// [turns] — сколько ещё ходов этого участника действует; `null` — пока мастер не снимет.
class StatusEffect {
  /// Уникален среди эффектов участника — чтобы снять или изменить именно этот.
  final String id;
  final Condition? condition;
  final String? customTitle;
  final String? customDescription;
  final int? turns;

  const StatusEffect.condition(this.condition, {required this.id, this.turns})
    : customTitle = null,
      customDescription = null;

  const StatusEffect.custom({required this.id, required String title, String description = '', this.turns})
    : condition = null,
      customTitle = title,
      customDescription = description;

  const StatusEffect._(this.id, this.condition, this.customTitle, this.customDescription, this.turns);

  String get title => condition?.title ?? customTitle ?? '';

  String get description => condition?.description ?? customDescription ?? '';

  /// «Удивлён · 2 хода».
  String get label => turns == null ? title : '$title · ${turnsLabel(turns!)}';

  /// Ещё один ход прошёл. `null` — эффект закончился.
  StatusEffect? afterTurn() {
    final turns = this.turns;
    if (turns == null) return this;
    if (turns <= 1) return null;
    return StatusEffect._(id, condition, customTitle, customDescription, turns - 1);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'condition': ?condition?.name,
    'title': ?customTitle,
    if (customDescription?.isNotEmpty ?? false) 'description': customDescription,
    'turns': ?turns,
  };

  /// `null` — состояние из другой версии приложения без своего названия.
  static StatusEffect? fromJson(Map<String, dynamic> json) {
    final condition = Condition.fromNames([?json['condition']]).firstOrNull;
    final title = json['title'] as String?;
    if (condition == null && title == null) return null;
    return StatusEffect._(json['id'], condition, title, json['description'], json['turns']);
  }

  static List<StatusEffect> listFromJson(List? json) => (json ?? const []).map((e) => fromJson(e)).nonNulls.toList();

  @override
  bool operator ==(Object other) =>
      other is StatusEffect &&
      id == other.id &&
      condition == other.condition &&
      customTitle == other.customTitle &&
      customDescription == other.customDescription &&
      turns == other.turns;

  @override
  int get hashCode => Object.hash(id, condition, customTitle, customDescription, turns);
}

/// «1 ход», «2 хода», «5 ходов».
String turnsLabel(int turns) {
  final mod10 = turns % 10;
  final mod100 = turns % 100;
  final word = mod10 == 1 && mod100 != 11
      ? 'ход'
      : (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) ? 'хода' : 'ходов');
  return '$turns $word';
}
