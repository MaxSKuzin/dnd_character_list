import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/combat.dart';
import 'package:dnd_character_list/domain/models/gear.dart';
import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/shield.dart';
import 'package:dnd_character_list/domain/models/tools/tool.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/domain/models/weapon_type.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';

/// Подписи предметов для экранов снаряжения и инвентаря.
extension WeaponTexts on Weapon {
  /// «1к8 колющий» или «1к8 колющий (двумя руками 1к10)».
  String get damageText {
    final damageTypeName = damageType?.localizedName.toLowerCase();
    final versatile = type == WeaponType.universal && twoHandedDamage != null
        ? ' (двумя руками ${getRawDamageString(isTwoHanded: true)})'
        : '';
    return [getRawDamageString(), if (damageTypeName != null) damageTypeName].join(' ') + versatile;
  }

  /// Свойства как на сайте: «лёгкое, метательное (дис. 20/60), фехтовальное».
  String get propertiesText {
    final range = minRange != null && maxRange != null ? ' (дис. $minRange/$maxRange)' : '';
    return [
      if (isLight) 'лёгкое',
      if (isHeavy) 'тяжёлое',
      if (type == WeaponType.twoHanded) 'двуручное',
      if (type == WeaponType.universal && twoHandedDamage != null)
        'универсальное (${getRawDamageString(isTwoHanded: true)})',
      if (isFencing) 'фехтовальное',
      if (isThrown) 'метательное$range',
      if (isAmmunition) 'боеприпас$range',
      if (isReach) 'досягаемость',
      if (isLoading) 'перезарядка',
      if (isSpecial) 'особое',
    ].join(', ');
  }
}

extension ArmorTexts on Armor {
  /// «11 + Ловкость», «13 + Ловкость (макс. 2)», «16».
  String get protectionText => switch (dexterityLimit) {
        null => '$protection + Ловкость',
        0 => '$protection',
        final limit => '$protection + Ловкость (макс. $limit)',
      };
}

extension WeaponSlotLocalization on WeaponSlot {
  String get localizedName => switch (this) {
        WeaponSlot.mainHand => 'Основная рука',
        WeaponSlot.secondHand => 'Вторая рука',
        WeaponSlot.mainRange => 'Дальний бой',
        WeaponSlot.secondRange => 'Дальний бой, вторая рука',
      };

  /// Подпись слота с оружием: рукопашное оружие в слоте дальнего боя метают.
  String labelFor(Weapon? weapon) {
    final isThrown = weapon != null && weapon.kind.isMelee && weapon.isThrown;
    return switch (this) {
      WeaponSlot.mainRange when isThrown => 'Метательное',
      WeaponSlot.secondRange when isThrown => 'Метательное, вторая рука',
      _ => localizedName,
    };
  }
}

/// Название и краткое описание любого предмета инвентаря.
abstract final class ItemTexts {
  static String name(Object item) => switch (item) {
        Weapon item => item.name,
        Armor item => item.name,
        Shield item => item.name,
        Tool item => item.name,
        Gear item => item.name,
        EquipmentPack item => item.name,
        CustomInvetoryItem item => item.name,
        _ => item.toString(),
      };

  static String? subtitle(Object item) => switch (item) {
        Weapon item => [item.damageText, if (item.propertiesText.isNotEmpty) item.propertiesText].join(' · '),
        Armor item => '${item.kind.localizedName}, КД ${item.protectionText}',
        Shield item => 'КД +${item.defense}',
        Tool item => item.category.localizedName,
        Gear item => item.group,
        EquipmentPack item => item.contents.map((e) => e.text).join(', '),
        CustomInvetoryItem item => item.description.isEmpty ? null : item.description,
        _ => null,
      };
}
