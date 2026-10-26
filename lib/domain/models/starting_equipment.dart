/// Стартовое снаряжение класса: каждая строка списка — выбор одного из вариантов,
/// например «а) рапира, б) длинный меч или в) любое простое оружие».
class StartingEquipmentChoice {
  final List<StartingEquipmentOption> options;

  const StartingEquipmentChoice({required this.options});

  Map<String, dynamic> toJson() => {'options': options.map((e) => e.toJson()).toList()};

  factory StartingEquipmentChoice.fromJson(Map<String, dynamic> json) => StartingEquipmentChoice(
        options: (json['options'] as List).map((e) => StartingEquipmentOption.fromJson(e)).toList(),
      );
}

class StartingEquipmentOption {
  /// Текст варианта как на сайте, например «Кожаный доспех и кинжал».
  final String text;
  final List<EquipmentRef> items;

  const StartingEquipmentOption({required this.text, required this.items});

  Map<String, dynamic> toJson() => {
        'text': text,
        'items': items.map((e) => e.toJson()).toList(),
      };

  factory StartingEquipmentOption.fromJson(Map<String, dynamic> json) => StartingEquipmentOption(
        text: json['text'],
        items: (json['items'] as List).map((e) => EquipmentRef.fromJson(e)).toList(),
      );
}

/// Ссылка на предмет из описания класса.
class EquipmentRef {
  /// Ссылка на предмет в нижнем регистре, например `/weapons/rapier` или `/items/diplomat's_pack`.
  final String? id;

  /// Текст как на сайте: «два ручных топора», «любое простое оружие».
  final String text;
  final int quantity;

  /// Предмет выбирается из категории: «любое простое оружие», «два воинских оружия».
  final bool isChoice;

  const EquipmentRef({
    required this.id,
    required this.text,
    this.quantity = 1,
    this.isChoice = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'quantity': quantity,
        'isChoice': isChoice,
      };

  factory EquipmentRef.fromJson(Map<String, dynamic> json) => EquipmentRef(
        id: json['id'],
        text: json['text'],
        quantity: json['quantity'],
        isChoice: json['isChoice'],
      );
}
