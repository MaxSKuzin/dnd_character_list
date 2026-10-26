import 'package:dnd_master/domain/models/battle.dart';
import 'package:flutter/material.dart';

extension MonsterMarkerColors on MonsterMarker {
  Color get color => switch (this) {
    MonsterMarker.red => Colors.red,
    MonsterMarker.blue => Colors.blue,
    MonsterMarker.green => Colors.green,
    MonsterMarker.yellow => Colors.yellow,
    MonsterMarker.purple => Colors.purple,
    MonsterMarker.orange => Colors.orange,
    MonsterMarker.white => Colors.white,
    MonsterMarker.black => Colors.black,
  };

  /// Цвет числа на метке.
  Color get foreground => switch (this) {
    MonsterMarker.yellow || MonsterMarker.white || MonsterMarker.orange => Colors.black,
    _ => Colors.white,
  };

  String get localizedName => switch (this) {
    MonsterMarker.red => 'Красный',
    MonsterMarker.blue => 'Синий',
    MonsterMarker.green => 'Зелёный',
    MonsterMarker.yellow => 'Жёлтый',
    MonsterMarker.purple => 'Фиолетовый',
    MonsterMarker.orange => 'Оранжевый',
    MonsterMarker.white => 'Белый',
    MonsterMarker.black => 'Чёрный',
  };
}

/// Круглая метка монстра с его номером.
class MonsterMarkerBadge extends StatelessWidget {
  final MonsterMarker marker;
  final int number;
  final double size;

  const MonsterMarkerBadge({super.key, required this.marker, required this.number, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: marker.color,
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Text(
        '$number',
        style: TextStyle(color: marker.foreground, fontSize: size * 0.55, fontWeight: FontWeight.bold),
      ),
    );
  }
}
