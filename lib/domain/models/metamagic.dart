/// Вариант метамагии чародея с ttg.club, например https://5e14.ttg.club/options/careful_spell.
class Metamagic {
  /// Ссылка в нижнем регистре, например `/options/careful_spell`. По ней сравниваются варианты.
  final String link;
  final String name;
  final String? source;
  final String descriptionHtml;

  const Metamagic({
    required this.link,
    required this.name,
    required this.source,
    required this.descriptionHtml,
  });

  @override
  bool operator ==(Object other) => other is Metamagic && other.link == link;

  @override
  int get hashCode => link.hashCode;

  Map<String, dynamic> toJson() => {
        'link': link,
        'name': name,
        'source': source,
        'descriptionHtml': descriptionHtml,
      };

  factory Metamagic.fromJson(Map<String, dynamic> json) => Metamagic(
        link: json['link'],
        name: json['name'],
        source: json['source'],
        descriptionHtml: json['descriptionHtml'],
      );
}
