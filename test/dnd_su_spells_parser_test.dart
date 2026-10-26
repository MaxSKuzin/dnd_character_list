import 'package:dnd_character_list/data/dnd_su/dnd_su_spells_parser.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';
import 'package:flutter_test/flutter_test.dart';

// Фрагменты реальных ответов dnd.su.
const _index = r'''<script>window.LIST = {"cards":[{"title":"Поиск фамильяра","title_en":"Find familiar","link":"\/spells\/248-find-familiar\/","level":"1","school":"Вызов","filter_level":[1],"filter_class":[21],"filter_class_tce":[],"filter_concentration":["1"],"filter_ritual":["2"],"filter_components":"1|1|1|","filter_casttime":["hour"]},{"title":"Аура живучести","title_en":"Aura of vitality","link":"\/spells\/3-aura-of-vitality\/","level":"3","school":"Воплощение","filter_level":[3],"filter_class":[16],"filter_class_tce":[13,22],"filter_concentration":["2"],"filter_ritual":["1"],"filter_components":"1|0|0|","filter_casttime":["action"]}],"order":{},"category":"spells"};</script>''';

const _details = '''
<h2 class="card-title" itemprop="name"><span data-copy="Смятение [Confusion]">Смятение [Confusion]</span><span class='source-plaque' title="Player's Handbook">PH14</span></h2>
<div class="card__body new-article" itemprop="articleBody"><ul class="params card__article-body"><li class="size-type-alignment">4 уровень, очарование</li><li><strong>Время накладывания:</strong> 1 действие</li><li><strong>Дистанция:</strong> 90 футов</li><li><strong>Компоненты:</strong> В, С, М (три ореховые скорлупки)</li><li><strong>Длительность:</strong> Концентрация, вплоть до 1 минуты</li><li><strong>Классы:</strong> бард, волшебник, друид, чародей</li><li class="subsection desc"><div itemprop="description"><p>Это заклинание атакует.</p>
<p><strong><em>На больших уровнях.</em></strong> Радиус увеличивается.</p>
</div></li></ul></div>
''';

void main() {
  final parser = DndSuSpellsParser();

  test('parses spells list', () {
    final spells = parser.parseIndex(_index);

    expect(spells, hasLength(2));
    final familiar = spells.first;
    expect(familiar.id, 248);
    expect(familiar.name, 'Поиск фамильяра');
    expect(familiar.nameEn, 'Find familiar');
    expect(familiar.slot, SpellSlot.level1);
    expect(familiar.isRitual, isTrue);
    expect(familiar.isConcentration, isFalse);
    expect(familiar.components, SpellComponent.values);
    expect(familiar.castTimeType, SpellTime.hour);
    expect(familiar.allowedSpecializations, [ClassKind.wizard]);

    final aura = spells.last;
    expect(aura.isConcentration, isTrue);
    expect(aura.components, [SpellComponent.verbal]);
    expect(aura.isAvailableFor(ClassKind.cliric), isFalse);
    expect(aura.isAvailableFor(ClassKind.cliric, includeTce: true), isTrue);
  });

  test('parses spell page', () {
    final details = parser.parseDetails(_details);

    expect(details.levelAndSchool, '4 уровень, очарование');
    expect(details.castTime, '1 действие');
    expect(details.distance, '90 футов');
    expect(details.components, 'В, С, М (три ореховые скорлупки)');
    expect(details.duration, 'Концентрация, вплоть до 1 минуты');
    expect(details.classes, 'бард, волшебник, друид, чародей');
    expect(details.subclasses, isNull);
    expect(details.source, "Player's Handbook");
    expect(details.descriptionHtml, startsWith('<p>Это заклинание атакует.</p>'));
    expect(details.descriptionHtml, contains('<strong><em>На больших уровнях.</em></strong>'));
  });

  test('spell survives json roundtrip', () {
    final spell = parser.parseIndex(_index).first.copyWith(details: parser.parseDetails(_details));

    final restored = Spell.fromJson(spell.toJson());

    expect(restored, spell);
    expect(restored.toJson(), spell.toJson());
  });

  test('search ignores case, ё and matches english name', () {
    final spell = parser.parseIndex(_index).first;

    expect(spell.matchesQuery('ФАМИЛ'), isTrue);
    expect(spell.matchesQuery('familiar'), isTrue);
    expect(spell.matchesQuery('огонь'), isFalse);
  });
}
