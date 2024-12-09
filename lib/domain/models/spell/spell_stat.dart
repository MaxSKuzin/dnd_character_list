import 'package:dnd_character_list/domain/models/stat.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';

class SpellStat {
  final int saveThrow;
  final int attackBonus;
  final StatKind statKind;
  final String owner;

  SpellStat({
    required Stat stat,
    required int proficiencyBonus,
    required this.owner,
  })  : statKind = stat.kind,
        saveThrow = 8 + stat.bonus + proficiencyBonus,
        attackBonus = stat.bonus + proficiencyBonus;

  @override
  bool operator ==(Object other) {
    if (other is SpellStat) {
      return saveThrow == other.saveThrow &&
          attackBonus == other.attackBonus &&
          statKind == other.statKind &&
          owner == other.owner;
    }
    return false;
  }

  @override
  int get hashCode => Object.hashAll([saveThrow, attackBonus, statKind, owner]);
}
