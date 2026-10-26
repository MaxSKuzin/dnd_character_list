import 'package:dnd_character_list/domain/models/races/race.dart';

/// Телосложение пиксельного аватара.
enum BodyType { male, female }

/// Верх: рубахи четырёх фасонов (под доспехом видны рукава) или платье — оно закрывает и низ.
enum TopStyle {
  longsleeve,
  vneck,
  shortsleeve,
  sleeveless,
  dress,
  longDress;

  /// Платья в LPC есть только для женского тела.
  bool get isFemaleOnly => this == dress || this == longDress;

  bool get isDress => isFemaleOnly;
}

/// Низ: штаны или юбка; длинная юбка есть только для женского тела.
enum BottomStyle {
  pants,
  skirt,
  longSkirt;

  bool get isFemaleOnly => this == longSkirt;
}

/// Обувь.
enum Footwear { boots, foldedBoots, shoes, sandals }

/// Цвет ткани и кожи одежды; палитра LPC `cloth` — имя в snake_case.
enum ClothColor {
  white,
  gray,
  charcoal,
  black,
  leather,
  walnut,
  brown,
  tan,
  maroon,
  red,
  orange,
  yellow,
  forest,
  green,
  teal,
  sky,
  blue,
  navy,
  purple,
  lavender,
  rose
}

/// Цвет кожи аватара. Имена совпадают с палитрами LPC (`assets/avatar/palettes.json`).
enum SkinTone { light, amber, olive, taupe, bronze, brown, black, red, cerise, plum, amethyst, lavender, blue }

/// Цвет волос аватара; палитра LPC — имя в snake_case.
enum HairColor {
  black,
  raven,
  darkBrown,
  chestnut,
  lightBrown,
  blonde,
  platinum,
  white,
  gray,
  ginger,
  red,
  purple,
  blue
}

/// Цвет глаз аватара; палитры LPC с теми же именами.
enum EyeColor { brown, blue, green, gray, purple, red, orange, yellow }

/// Облик персонажа для пиксельного аватара. Экипировка в нём не хранится — она берётся из надетого.
class Appearance {
  /// Сколько причёсок у каждого телосложения.
  static const hairstyleCount = 3;

  final BodyType body;

  /// Номер причёски от 0 до [hairstyleCount] − 1; причёска и есть «лицо» персонажа.
  final int hairstyle;
  final SkinTone skin;
  final HairColor hair;
  final EyeColor eyes;
  final TopStyle top;
  final ClothColor topColor;

  /// Низ не виден, если верх — платье.
  final BottomStyle bottom;
  final ClothColor bottomColor;
  final Footwear footwear;
  final ClothColor footwearColor;

  const Appearance({
    this.body = BodyType.male,
    this.hairstyle = 0,
    this.skin = SkinTone.light,
    this.hair = HairColor.darkBrown,
    this.eyes = EyeColor.brown,
    this.top = TopStyle.longsleeve,
    this.topColor = ClothColor.forest,
    this.bottom = BottomStyle.pants,
    this.bottomColor = ClothColor.brown,
    this.footwear = Footwear.boots,
    this.footwearColor = ClothColor.leather,
  });

  /// Облик по умолчанию для расы: тифлинги краснокожие с жёлтыми глазами.
  factory Appearance.forRace(Race race) => switch (race) {
        Race.tiefling || Race.tieflingFaerun || Race.dwarfTiefling => const Appearance(
            skin: SkinTone.red,
            hair: HairColor.black,
            eyes: EyeColor.yellow,
            topColor: ClothColor.maroon,
          ),
        Race.halfElf => const Appearance(hair: HairColor.chestnut, eyes: EyeColor.green),
      };

  /// Другое телосложение: женская одежда, которой нет у мужского тела, меняется на обычную.
  Appearance withBody(BodyType body) => Appearance(
        body: body,
        hairstyle: hairstyle,
        skin: skin,
        hair: hair,
        eyes: eyes,
        top: body == BodyType.male && top.isFemaleOnly ? TopStyle.longsleeve : top,
        topColor: topColor,
        bottom: body == BodyType.male && bottom.isFemaleOnly ? BottomStyle.skirt : bottom,
        bottomColor: bottomColor,
        footwear: footwear,
        footwearColor: footwearColor,
      );

  Appearance copyWith({
    int? hairstyle,
    SkinTone? skin,
    HairColor? hair,
    EyeColor? eyes,
    TopStyle? top,
    ClothColor? topColor,
    BottomStyle? bottom,
    ClothColor? bottomColor,
    Footwear? footwear,
    ClothColor? footwearColor,
  }) =>
      Appearance(
        body: body,
        hairstyle: hairstyle ?? this.hairstyle,
        skin: skin ?? this.skin,
        hair: hair ?? this.hair,
        eyes: eyes ?? this.eyes,
        top: top ?? this.top,
        topColor: topColor ?? this.topColor,
        bottom: bottom ?? this.bottom,
        bottomColor: bottomColor ?? this.bottomColor,
        footwear: footwear ?? this.footwear,
        footwearColor: footwearColor ?? this.footwearColor,
      );

  @override
  bool operator ==(Object other) =>
      other is Appearance &&
      other.body == body &&
      other.hairstyle == hairstyle &&
      other.skin == skin &&
      other.hair == hair &&
      other.eyes == eyes &&
      other.top == top &&
      other.topColor == topColor &&
      other.bottom == bottom &&
      other.bottomColor == bottomColor &&
      other.footwear == footwear &&
      other.footwearColor == footwearColor;

  @override
  int get hashCode => Object.hash(
        body,
        hairstyle,
        skin,
        hair,
        eyes,
        top,
        topColor,
        bottom,
        bottomColor,
        footwear,
        footwearColor,
      );

  Map<String, dynamic> toJson() => {
        'body': body.name,
        'hairstyle': hairstyle,
        'skin': skin.name,
        'hair': hair.name,
        'eyes': eyes.name,
        'top': top.name,
        'topColor': topColor.name,
        'bottom': bottom.name,
        'bottomColor': bottomColor.name,
        'footwear': footwear.name,
        'footwearColor': footwearColor.name,
      };

  factory Appearance.fromJson(Map<String, dynamic> json) => Appearance(
        body: BodyType.values.byName(json['body']),
        hairstyle: json['hairstyle'],
        skin: SkinTone.values.byName(json['skin']),
        hair: HairColor.values.byName(json['hair']),
        eyes: EyeColor.values.byName(json['eyes']),
        top: TopStyle.values.byName(json['top']),
        topColor: ClothColor.values.byName(json['topColor']),
        bottom: BottomStyle.values.byName(json['bottom']),
        bottomColor: ClothColor.values.byName(json['bottomColor']),
        footwear: Footwear.values.byName(json['footwear']),
        footwearColor: ClothColor.values.byName(json['footwearColor']),
      );
}
