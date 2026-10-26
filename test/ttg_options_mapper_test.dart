import 'package:dnd_character_list/data/ttg/ttg_options_mapper.dart';
import 'package:dnd_character_list/domain/models/class_option.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/ttg_fixtures.dart';

void main() {
  test('maps metamagic option', () {
    final option = TtgOptionsMapper().option('/options/Careful_Spell', ttgFixture('option_careful_spell'));

    expect(option.link, '/options/careful_spell');
    expect(option.name, 'Аккуратное заклинание');
    expect(option.source, 'Книга игрока');
    expect(option.descriptionHtml, contains('единицу чародейства'));
    expect(Metamagic.fromJson(option.toJson()), option);
  });

  test('maps maneuver option', () {
    final option = TtgOptionsMapper().option('/options/riposte', ttgFixture('option_riposte'));

    expect(option.link, '/options/riposte');
    expect(option.name, 'Ответный удар');
    expect(option.descriptionHtml, contains('Кость превосходства'));
    expect(ClassOptionKind.maneuver.ttgFilter, 'MANEUVER');
  });
}
