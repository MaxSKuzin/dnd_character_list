import 'package:collection/collection.dart';

/// Положение фотографии в круге аватара: масштаб и сдвиг относительно стороны круга. Исходная фотография
/// заполняет круг (как `BoxFit.cover`), затем увеличивается в [scale] раз от левого верхнего угла и сдвигается
/// на ([dx], [dy]) сторон круга — как матрица `InteractiveViewer`, поэтому подходит для круга любого размера.
class AvatarFrame {
  final double scale;
  final double dx;
  final double dy;

  const AvatarFrame({this.scale = 1, this.dx = 0, this.dy = 0});

  static const initial = AvatarFrame();

  @override
  bool operator ==(Object other) => other is AvatarFrame && other.scale == scale && other.dx == dx && other.dy == dy;

  @override
  int get hashCode => Object.hash(scale, dx, dy);

  Map<String, dynamic> toJson() => {'scale': scale, 'dx': dx, 'dy': dy};

  factory AvatarFrame.fromJson(Map<String, dynamic> json) => AvatarFrame(
        scale: (json['scale'] as num).toDouble(),
        dx: (json['dx'] as num).toDouble(),
        dy: (json['dy'] as num).toDouble(),
      );
}

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

  /// Имя файла аватара в папке приложения (`AvatarStore`); `null` — аватара нет. Аватар есть только
  /// на этом устройстве и не уходит мастеру.
  final String? avatar;

  /// Положение фотографии в круге аватара.
  final AvatarFrame avatarFrame;

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
    this.avatar,
    this.avatarFrame = AvatarFrame.initial,
  });

  Personality copyWith({String? Function()? avatar, AvatarFrame? avatarFrame}) => Personality(
        eyesColor: eyesColor,
        hairColor: hairColor,
        skinColor: skinColor,
        name: name,
        age: age,
        height: height,
        weight: weight,
        story: story,
        traits: traits,
        avatar: avatar != null ? avatar() : this.avatar,
        avatarFrame: avatarFrame ?? this.avatarFrame,
      );

  @override
  bool operator ==(Object other) =>
      other is Personality &&
      other.name == name &&
      other.age == age &&
      other.height == height &&
      other.weight == weight &&
      other.story == story &&
      other.eyesColor == eyesColor &&
      other.hairColor == hairColor &&
      other.skinColor == skinColor &&
      const MapEquality<String, String>().equals(other.traits, traits) &&
      other.avatar == avatar &&
      other.avatarFrame == avatarFrame;

  @override
  int get hashCode => Object.hash(
        name,
        age,
        height,
        weight,
        story,
        eyesColor,
        hairColor,
        skinColor,
        const MapEquality<String, String>().hash(traits),
        avatar,
        avatarFrame,
      );

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
        'avatar': avatar,
        'avatarFrame': avatarFrame.toJson(),
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
        avatar: json['avatar'],
        avatarFrame: AvatarFrame.fromJson(json['avatarFrame']),
      );
}
