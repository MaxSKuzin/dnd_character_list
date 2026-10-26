import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/gear.dart';
import 'package:dnd_character_list/domain/models/shield.dart';
import 'package:dnd_character_list/domain/models/starting_equipment.dart';
import 'package:dnd_character_list/domain/models/tools/tool.dart';
import 'package:dnd_character_list/domain/models/tools/tool_category.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';

/// Предметы «Книги игрока» с ttg.club: оружие, доспехи, щиты, снаряжение, наборы и инструменты.
class EquipmentCatalog {
  final List<Weapon> weapons;
  final List<Armor> armors;
  final List<Shield> shields;
  final List<Gear> gear;
  final List<EquipmentPack> packs;
  final List<Tool> tools;

  const EquipmentCatalog({
    required this.weapons,
    required this.armors,
    required this.shields,
    required this.gear,
    required this.packs,
    required this.tools,
  });

  List<Object> get all => [...weapons, ...armors, ...shields, ...tools, ...packs, ...gear];

  List<Tool> toolsOf(ToolCategory category) => tools.where((e) => e.category == category).toList();

  static String nameOf(Object item) => switch (item) {
        Weapon item => item.name,
        Armor item => item.name,
        Shield item => item.name,
        Tool item => item.name,
        EquipmentPack item => item.name,
        Gear item => item.name,
        _ => item.toString(),
      };

  static String? _idOf(Object item) => switch (item) {
        Weapon item => item.id,
        Armor item => item.id,
        Gear item => item.id,
        EquipmentPack item => item.id,
        _ => null,
      };

  /// Группы снаряжения, из которых выбирают «магическую фокусировку» и подобное.
  static const focusGroups = {
    'магическая фокусировка': 'Магическая фокусировка',
    'фокусировка друидов': 'Фокусировка друидов',
    'священный символ': 'Священный символ',
  };

  /// Предметы, из которых выбирают по ссылке вида «любое простое рукопашное оружие».
  List<Object> choicesFor(EquipmentRef ref) {
    final text = ref.text.toLowerCase();
    final group = focusGroups.entries.firstWhereOrNull((e) => text.contains(e.key))?.value;
    if (group != null) return gear.where((e) => e.group == group).toList();
    if (text.contains('оружи')) {
      return weapons.where((weapon) {
        if (text.contains('прост') && !weapon.kind.isSimple) return false;
        if (text.contains('воинск') && weapon.kind.isSimple) return false;
        if (text.contains('рукопашн') && !weapon.kind.isMelee) return false;
        if (text.contains('дальнобойн') && !weapon.kind.isRanged) return false;
        return true;
      }).toList();
    }
    final category = switch (text) {
      _ when text.contains('музык') => ToolCategory.musicalInstrument,
      _ when text.contains('игров') => ToolCategory.playSet,
      _ when text.contains('ремесл') => ToolCategory.craftsmenTool,
      _ => null,
    };
    return category == null ? [] : toolsOf(category);
  }

  /// Находит предмет по ссылке из описания класса. Ссылки на сайте не всегда точны,
  /// поэтому сначала сравниваются названия, затем ссылки.
  Object? find(EquipmentRef ref) {
    final candidates = _candidatesFor(ref.id);
    final text = _normalize(ref.text);
    return candidates.firstWhereOrNull((e) => _normalize(nameOf(e)) == text) ??
        candidates.firstWhereOrNull((e) => ref.id != null && _idOf(e) == ref.id) ??
        _findBySimilarId(candidates, ref.id) ??
        _findByStems(candidates, ref.text);
  }

  List<Object> _candidatesFor(String? id) => switch (id) {
        null => all,
        _ when id.startsWith('/weapons/') => weapons,
        _ when id.startsWith('/armors/') => [...armors, ...shields],
        _ when id.startsWith('/items/') => [...packs, ...tools, ...gear],
        _ => all,
      };

  /// Опечатки в ссылках: `/weapons/javeline` вместо `/weapons/javelin`.
  Object? _findBySimilarId(List<Object> candidates, String? id) {
    if (id == null) return null;
    return candidates
        .map((e) => (e, _idOf(e)))
        .where((e) => e.$2 != null && _distance(e.$2!, id) <= 2)
        .sortedBy<num>((e) => _distance(e.$2!, id))
        .firstOrNull
        ?.$1;
  }

  /// Все слова ссылки совпадают по основе со словами названия: «метательных копья» и «Метательное копьё».
  Object? _findByStems(List<Object> candidates, String text) {
    final stems = _stems(text);
    if (stems.isEmpty) return null;
    return candidates.firstWhereOrNull((e) {
      final nameStems = _stems(nameOf(e));
      return stems.every((stem) => nameStems.any((e) => e.startsWith(stem) || stem.startsWith(e)));
    });
  }

  static const _stemLength = 4;
  static const _ignoredWords = {'любое', 'любой', 'любую', 'другой', 'набор', 'или', 'на', 'ваш', 'выбор'};

  static List<String> _stems(String text) => _normalize(text)
      .split(RegExp(r'[^a-zа-я]+'))
      .where((e) => e.length >= 3 && !_ignoredWords.contains(e) && int.tryParse(e) == null)
      .map((e) => e.substring(0, min(e.length, _stemLength)))
      .toList();

  static String _normalize(String text) => text.toLowerCase().replaceAll('ё', 'е').trim();

  static int _distance(String a, String b) {
    var previous = List.generate(b.length + 1, (i) => i);
    for (var i = 1; i <= a.length; i++) {
      final current = [i, ...List.filled(b.length, 0)];
      for (var j = 1; j <= b.length; j++) {
        current[j] = [
          previous[j] + 1,
          current[j - 1] + 1,
          previous[j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1),
        ].reduce(min);
      }
      previous = current;
    }
    return previous[b.length];
  }

  Map<String, dynamic> toJson() => {
        'weapons': weapons.map((e) => e.toJson()).toList(),
        'armors': armors.map((e) => e.toJson()).toList(),
        'shields': shields.map((e) => e.toJson()).toList(),
        'gear': gear.map((e) => e.toJson()).toList(),
        'packs': packs.map((e) => e.toJson()).toList(),
        'tools': tools.map((e) => e.toJson()).toList(),
      };

  factory EquipmentCatalog.fromJson(Map<String, dynamic> json) => EquipmentCatalog(
        weapons: (json['weapons'] as List).map((e) => Weapon.fromJson(e)).toList(),
        armors: (json['armors'] as List).map((e) => Armor.fromJson(e)).toList(),
        shields: (json['shields'] as List).map((e) => Shield.fromJson(e)).toList(),
        gear: (json['gear'] as List).map((e) => Gear.fromJson(e)).toList(),
        packs: (json['packs'] as List).map((e) => EquipmentPack.fromJson(e)).toList(),
        tools: (json['tools'] as List).map((e) => Tool.fromJson(e)).toList(),
      );
}
