/// Особенность класса с ttg.club (раздел «Особенности классов», `/options`): вариант метамагии чародея
/// (https://5e14.ttg.club/options/careful_spell) или приём мастера боевых искусств (`/options/riposte`).
class ClassOption {
  /// Ссылка в нижнем регистре, например `/options/careful_spell`. По ней сравниваются варианты.
  final String link;
  final String name;
  final String? source;
  final String descriptionHtml;

  const ClassOption({
    required this.link,
    required this.name,
    required this.source,
    required this.descriptionHtml,
  });

  @override
  bool operator ==(Object other) => other is ClassOption && other.link == link;

  @override
  int get hashCode => link.hashCode;

  Map<String, dynamic> toJson() => {
        'link': link,
        'name': name,
        'source': source,
        'descriptionHtml': descriptionHtml,
      };

  factory ClassOption.fromJson(Map<String, dynamic> json) => ClassOption(
        link: json['link'],
        name: json['name'],
        source: json['source'],
        descriptionHtml: json['descriptionHtml'],
      );
}

typedef Metamagic = ClassOption;

typedef Maneuver = ClassOption;

/// Вид особенностей класса: значение фильтра `classOption` в `POST /options`.
enum ClassOptionKind {
  metamagic('METAMAGIC', 'Метамагия'),
  maneuver('MANEUVER', 'Приёмы');

  const ClassOptionKind(this.ttgFilter, this.title);

  final String ttgFilter;
  final String title;
}
