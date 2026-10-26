import 'package:dnd_character_list/domain/models/appearance.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/armor_kind.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/races/race.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';

/// Замена цветов слоя: палитра [from] материала [material] → палитра [to] материала [toMaterial] (обычно того же).
/// Палитры — в `assets/avatar/palettes.json`.
class Recolor {
  final String material;
  final String from;
  final String toMaterial;
  final String to;

  const Recolor(this.material, this.from, this.to, {String? toMaterial}) : toMaterial = toMaterial ?? material;

  /// Кожа, рога и уши рисуются в палитре `light`.
  const Recolor.body(this.to)
      : material = 'body',
        from = 'light',
        toMaterial = 'body';

  const Recolor.hair(this.to)
      : material = 'hair',
        from = 'orange',
        toMaterial = 'hair';

  const Recolor.eyes(this.to)
      : material = 'eye',
        from = 'blue',
        toMaterial = 'eye';

  const Recolor.cloth(this.to)
      : material = 'cloth',
        from = 'white',
        toMaterial = 'cloth';

  const Recolor.metal(this.to)
      : material = 'metal',
        from = 'steel',
        toMaterial = 'metal';

  @override
  bool operator ==(Object other) =>
      other is Recolor &&
      other.material == material &&
      other.from == from &&
      other.toMaterial == toMaterial &&
      other.to == to;

  @override
  int get hashCode => Object.hash(material, from, toMaterial, to);

  @override
  String toString() => '$material.$from>$toMaterial.$to';
}

/// Слой аватара: кадр 64×64 из `assets/avatar/layers/<asset>.png`. Слои рисуются по возрастанию [z], как в LPC.
/// [mirrored] — кадр отражён по горизонтали: так оружие переходит в другую руку (тело в кадре симметрично).
class AvatarLayer {
  final String asset;
  final int z;
  final List<Recolor> recolors;
  final bool mirrored;

  const AvatarLayer(this.asset, this.z, [this.recolors = const [], this.mirrored = false]);

  @override
  bool operator ==(Object other) =>
      other is AvatarLayer &&
      other.asset == asset &&
      other.z == z &&
      other.mirrored == mirrored &&
      _listEquals(other.recolors, recolors);

  @override
  int get hashCode => Object.hash(asset, z, mirrored, Object.hashAll(recolors));

  @override
  String toString() => '$asset${mirrored ? '~' : ''}${recolors.isEmpty ? '' : '(${recolors.join(',')})'}';
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Что видно на аватаре: облик, раса и надетая экипировка.
class AvatarLook {
  final Appearance appearance;
  final Race race;
  final Armor? armor;
  final bool hasShield;
  final Weapon? weapon;

  /// Оружие во второй руке; у щита своя картинка, и вместе со вторым оружием его не бывает.
  final Weapon? offHandWeapon;

  const AvatarLook({
    required this.appearance,
    required this.race,
    this.armor,
    this.hasShield = false,
    this.weapon,
    this.offHandWeapon,
  });

  /// В руках — рукопашный комплект, без него — дальнобойный.
  factory AvatarLook.of(Player player) {
    final melee = player.mainWeapon != null;
    return AvatarLook(
      appearance: player.personality.appearance,
      race: player.race,
      armor: player.armor,
      hasShield: player.shield != null,
      weapon: melee ? player.mainWeapon : player.mainRangeWeapon,
      offHandWeapon: melee ? player.secondWeapon : player.secondRangeWeapon,
    );
  }

  /// Тот же облик и экипировка с другим [appearance] — для предпросмотра в редакторе.
  AvatarLook withAppearance(Appearance appearance) => AvatarLook(
        appearance: appearance,
        race: race,
        armor: armor,
        hasShield: hasShield,
        weapon: weapon,
        offHandWeapon: offHandWeapon,
      );

  /// Карликовый тифлинг рисуется сжатым по высоте.
  double get heightFactor => race.isSmall ? 0.8 : 1;

  List<AvatarLayer> get layers {
    final sex = appearance.body.name;
    final skin = Recolor.body(snakeCase(appearance.skin.name));
    final hair = Recolor.hair(snakeCase(appearance.hair.name));
    final layers = [
      AvatarLayer('body_$sex', 10, [skin]),
      AvatarLayer('head_$sex', 100, [skin, Recolor.eyes(appearance.eyes.name)]),
      AvatarLayer('face_$sex', 101, [skin, Recolor.eyes(appearance.eyes.name)]),
      ..._hairstyle(hair),
      ..._race(skin),
      ..._clothes(),
      if (armor case final armor?) ..._armor(armor),
      if (hasShield) AvatarLayer('shield_$sex', 110),
      if (weapon case final weapon?) ..._weapon(weapon),
      if (offHandWeapon case final weapon?) ..._weapon(weapon, mirrored: true),
    ];
    return layers..sort((a, b) => a.z.compareTo(b.z));
  }

  /// Одежда и обувь (палитры `cloth`). Платье рисуется вместо рубахи и закрывает низ; женской одежды
  /// у мужского тела нет — она меняется на обычную (`Appearance.withBody`).
  List<AvatarLayer> _clothes() {
    final sex = appearance.body.name;
    final clothes = appearance.withBody(appearance.body);
    final top = clothes.top;
    return [
      AvatarLayer('top_${snakeCase(top.name)}_$sex', top.isDress ? 30 : 35, [Recolor.cloth(clothes.topColor.name)]),
      // Длинная юбка закрывает и голенища сапог.
      if (!top.isDress)
        AvatarLayer(
          '${snakeCase(clothes.bottom.name)}_$sex',
          clothes.bottom == BottomStyle.longSkirt ? 26 : 20,
          [Recolor.cloth(clothes.bottomColor.name)],
        ),
      // Сапоги — поверх штанин, туфли и сандалии — под ними.
      AvatarLayer(
        '${snakeCase(clothes.footwear.name)}_$sex',
        const {Footwear.boots, Footwear.foldedBoots}.contains(clothes.footwear) ? 25 : 15,
        [Recolor.cloth(clothes.footwearColor.name)],
      ),
    ];
  }

  List<AvatarLayer> _hairstyle(Recolor hair) => switch ((appearance.body, appearance.hairstyle)) {
        (BodyType.male, 0) => [
            AvatarLayer('hair_plain', 120, [hair])
          ],
        (BodyType.male, 1) => [
            AvatarLayer('hair_spiked', 120, [hair])
          ],
        (BodyType.male, _) => [
            AvatarLayer('hair_long_messy', 120, [hair]),
            AvatarLayer('beard', 110, [hair])
          ],
        (BodyType.female, 0) => [
            AvatarLayer('hair_bob', 120, [hair])
          ],
        (BodyType.female, 1) => [
            AvatarLayer('hair_braid', 120, [hair])
          ],
        (BodyType.female, _) => [
            AvatarLayer('hair_curly_long', 120, [hair])
          ],
      };

  List<AvatarLayer> _race(Recolor skin) => switch (race) {
        // Хвост нарисован в палитре волос `red` и перекрашивается в цвет кожи.
        Race.tiefling || Race.tieflingFaerun || Race.dwarfTiefling => [
            const AvatarLayer('horns', 126, [Recolor.body('black')]),
            AvatarLayer('tail', 5, [Recolor('hair', 'red', skin.to, toMaterial: 'body')]),
          ],
        Race.halfElf => [
            AvatarLayer('ears_elven', 126, [skin])
          ],
      };

  List<AvatarLayer> _armor(Armor armor) {
    final sex = appearance.body.name;
    AvatarLayer leather(String color, [String belt = 'brass']) =>
        AvatarLayer('leather_$sex', 60, [Recolor('cloth', 'leather', color), Recolor.metal(belt)]);
    AvatarLayer chainmail(String metal) => AvatarLayer('chainmail_$sex', 50, [Recolor.metal(metal)]);
    AvatarLayer plate(String part, int z, [String metal = 'steel']) =>
        AvatarLayer('${part}_$sex', z, [Recolor.metal(metal)]);
    final torso = plate('plate', 60);
    final arms = plate('plate_arms', 60);
    final legs = plate('plate_legs', 21);
    final feet = plate('plate_feet', 26);
    return switch (armor.id?.replaceFirst('/armors/', '')) {
      'padded_armor' => [leather('tan')],
      'leather_armor' => [leather('leather')],
      'studded_leather_armor' => [leather('walnut', 'iron')],
      'hide_armor' => [leather('brown', 'bronze')],
      'chain_shirt' => [chainmail('iron')],
      'scale_mail_armor' => [plate('legion', 60, 'brass')],
      'breastplate' => [torso],
      'half_plate_armor' => [torso, arms],
      'ring_mail_armor' => [chainmail('bronze')],
      'chain_mail' => [chainmail('steel'), feet],
      'splint_armor' => [plate('legion', 60), arms, legs],
      'plate_armor' => [torso, arms, legs, feet],
      _ => switch (armor.kind) {
          ArmorKind.light => [leather('leather')],
          ArmorKind.medium => [chainmail('iron')],
          ArmorKind.heavy => [torso, arms, legs, feet],
        },
    };
  }

  /// Оружие PHB по ссылке ttg.club; своё оружие — меч или лук. Кнута, сети и духовой трубки в LPC нет.
  List<AvatarLayer> _weapon(Weapon weapon, {bool mirrored = false}) {
    final sprite = switch (weapon.id?.replaceFirst('/weapons/', '')) {
      'dagger' || 'sickle' || 'dart' => 'dagger',
      'shortsword' => 'sword',
      'longsword' || 'greatsword' => 'longsword',
      'rapier' => 'rapier',
      'scimitar' => 'saber',
      'mace' ||
      'morningstar' ||
      'light_hammer' ||
      'warhammer' ||
      'war_pick' ||
      'club' ||
      'greatclub' ||
      'maul' =>
        'mace',
      'flail' => 'flail',
      'handaxe' || 'battleaxe' || 'greataxe' => 'axe',
      // Длинное копьё и трезубец LPC не помещаются в кадр 64×64.
      'spear' || 'javelin' || 'pike' || 'lance' || 'trident' => 'spear',
      'halberd' || 'glaive' => 'halberd',
      'quarterstaff' => 'staff',
      'shortbow' => 'bow',
      'longbow' => 'longbow',
      'crossbow,_light' || 'crossbow,_hand' || 'crossbow,_heavy' => 'crossbow',
      'sling' => 'sling',
      'whip' || 'net' || 'blowgun' => null,
      _ => weapon.kind.isMelee ? 'sword' : 'bow',
    };
    if (sprite == null) return const [];
    return [
      AvatarLayer('${sprite}_fg', 140, const [], mirrored),
      // Часть оружия за телом: у луков — за всем персонажем, как в LPC. У остального оружия её не видно.
      if (const {'bow', 'longbow'}.contains(sprite))
        AvatarLayer('${sprite}_bg', -1, const [], mirrored)
      else if (const {'axe', 'halberd', 'spear'}.contains(sprite))
        AvatarLayer('${sprite}_bg', 9, const [], mirrored),
    ];
  }
}

/// Имя enum в snake_case — так называются палитры LPC и слои: `darkBrown` → `dark_brown`.
String snakeCase(String name) => name.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]!.toLowerCase()}');
