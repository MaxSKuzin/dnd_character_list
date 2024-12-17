import 'package:dnd_character_list/domain/models/armor_kind.dart';

class Armor {
  final String name;
  final int protection;
  final int? dexterityLimit;
  final int weight;
  final ArmorKind kind;
  final bool stealthDisadvantage;

  const Armor._({
    required this.kind,
    required this.weight,
    required this.name,
    required this.protection,
    required this.dexterityLimit,
    this.stealthDisadvantage = false,
  });

  @override
  operator ==(Object other) {
    return other is Armor &&
        other.name == name &&
        other.protection == protection &&
        other.dexterityLimit == dexterityLimit &&
        other.kind == kind &&
        other.stealthDisadvantage == stealthDisadvantage &&
        other.weight == weight;
  }

  @override
  int get hashCode => Object.hashAll([
        name,
        protection,
        dexterityLimit,
        weight,
        kind,
        stealthDisadvantage,
      ]);

  Map<String, dynamic> toJson() => {
        'kind': kind.index,
        'weight': weight,
        'name': name,
        'protection': protection,
        'dexterityLimit': dexterityLimit,
        'stealthDisadvantage': stealthDisadvantage,
      };

  factory Armor.fromJson(Map<String, dynamic> json) => Armor._(
        kind: ArmorKind.values[json['kind']],
        weight: json['weight'],
        name: json['name'],
        protection: json['protection'],
        dexterityLimit: json['dexterityLimit'],
        stealthDisadvantage: json['stealthDisadvantage'],
      );

  //light armor
  factory Armor.quilted() => const Armor._(
        name: 'Стеганый',
        kind: ArmorKind.light,
        protection: 11,
        weight: 8,
        dexterityLimit: null,
        stealthDisadvantage: true,
      );

  factory Armor.leather() => const Armor._(
        name: 'Кожаный',
        kind: ArmorKind.light,
        protection: 11,
        weight: 10,
        dexterityLimit: null,
      );

  factory Armor.studdedLeather() => const Armor._(
        name: 'Проклёпанный кожаный',
        kind: ArmorKind.light,
        protection: 12,
        weight: 13,
        dexterityLimit: null,
      );

  // medium armor
  factory Armor.fur() => const Armor._(
        name: 'Шкурный',
        kind: ArmorKind.medium,
        protection: 12,
        weight: 12,
        dexterityLimit: 2,
      );

  factory Armor.mailShirt() => const Armor._(
        name: 'Кольчужная рубаха',
        kind: ArmorKind.medium,
        protection: 14,
        weight: 20,
        dexterityLimit: 2,
      );

  factory Armor.scaly() => const Armor._(
        name: 'Чешуйчатый',
        kind: ArmorKind.medium,
        protection: 14,
        weight: 45,
        dexterityLimit: 2,
        stealthDisadvantage: true,
      );

  factory Armor.cuirass() => const Armor._(
        name: 'Кираса',
        kind: ArmorKind.medium,
        protection: 14,
        weight: 20,
        dexterityLimit: 2,
      );

  factory Armor.halfArmor() => const Armor._(
        name: 'Полулаты',
        kind: ArmorKind.medium,
        protection: 15,
        weight: 40,
        dexterityLimit: 2,
        stealthDisadvantage: true,
      );

  // heavy armor
  factory Armor.ringed() => const Armor._(
        name: 'Колечный',
        kind: ArmorKind.heavy,
        protection: 14,
        weight: 55,
        dexterityLimit: 0,
        stealthDisadvantage: true,
      );

  factory Armor.chainmail() => const Armor._(
        name: 'Кольчуга',
        kind: ArmorKind.heavy,
        protection: 16,
        weight: 55,
        dexterityLimit: 0,
        stealthDisadvantage: true,
      );

  factory Armor.stacked() => const Armor._(
        name: 'Наборный',
        kind: ArmorKind.heavy,
        protection: 17,
        weight: 60,
        dexterityLimit: 0,
        stealthDisadvantage: true,
      );

  factory Armor.plate() => const Armor._(
        name: 'Латы',
        kind: ArmorKind.heavy,
        protection: 18,
        weight: 65,
        dexterityLimit: 0,
        stealthDisadvantage: true,
      );
}
