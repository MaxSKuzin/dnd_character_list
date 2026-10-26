import 'package:dnd_character_list/data/ttg/ttg_options_mapper.dart';
import 'package:dnd_character_list/domain/models/metamagic.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/ttg_fixtures.dart';

void main() {
  test('maps metamagic option', () {
    final option = TtgOptionsMapper().metamagic('/options/Careful_Spell', ttgFixture('option_careful_spell'));

    expect(option.link, '/options/careful_spell');
    expect(option.name, 'Аккуратное заклинание');
    expect(option.source, 'Книга игрока');
    expect(option.descriptionHtml, contains('единицу чародейства'));
    expect(Metamagic.fromJson(option.toJson()), option);
  });
}
