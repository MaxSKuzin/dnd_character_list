import 'package:dnd_character_list/domain/models/spell/spell.dart';

/// Замена известного заклинания другим: при повышении уровня барда (любое заклинание 1 уровня и выше)
/// или по «Бардовской разносторонности» (заговор).
class SpellReplacement {
  final Spell replaced;
  final Spell learned;

  const SpellReplacement({required this.replaced, required this.learned});

  /// Применяет замену к списку известных заклинаний, сохраняя порядок.
  List<Spell> applyTo(List<Spell> spells) => spells.map((e) => e == replaced ? learned : e).toList();
}
