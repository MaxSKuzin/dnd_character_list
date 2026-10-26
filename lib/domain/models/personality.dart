class Personality {
  final String name;
  final int age;
  final int height;
  final int weight;
  final String story;
  final String eyesColor;
  final String hairColor;
  final String skinColor;

  /// Выбранная строка каждой таблицы персонализации предыстории по заголовку таблицы,
  /// например «Черта характера» → «Я безнадёжный романтик».
  final Map<String, String> traits;

  Personality({
    required this.eyesColor,
    required this.hairColor,
    required this.skinColor,
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.story,
    this.traits = const {},
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'height': height,
        'weight': weight,
        'story': story,
        'eyesColor': eyesColor,
        'hairColor': hairColor,
        'skinColor': skinColor,
        'traits': traits,
      };

  factory Personality.fromJson(Map<String, dynamic> json) => Personality(
        eyesColor: json['eyesColor'],
        hairColor: json['hairColor'],
        skinColor: json['skinColor'],
        name: json['name'],
        age: json['age'],
        height: json['height'],
        weight: json['weight'],
        story: json['story'],
        traits: (json['traits'] as Map).cast<String, String>(),
      );
}
