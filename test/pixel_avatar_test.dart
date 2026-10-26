import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dnd_character_list/data/avatar_store.dart';
import 'package:dnd_character_list/data/sp_source.dart';
import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/appearance.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/armor_kind.dart';
import 'package:dnd_character_list/domain/models/damage_type.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/races/race.dart';
import 'package:dnd_character_list/domain/models/shield.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/domain/models/weapon_kind.dart';
import 'package:dnd_character_list/domain/models/weapon_type.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/common/widgets/pixel_avatar/appearance_editor.dart';
import 'package:dnd_character_list/presentation/common/widgets/pixel_avatar/avatar_layers.dart';
import 'package:dnd_character_list/presentation/common/widgets/pixel_avatar/avatar_renderer.dart';
import 'package:dnd_character_list/presentation/common/widgets/pixel_avatar/pixel_avatar.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:dnd_character_list/presentation/personality_screen/personality_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fixtures.dart';

Armor _armor(String id, [ArmorKind kind = ArmorKind.light]) =>
    Armor(id: '/armors/$id', name: id, kind: kind, protection: 11, dexterityLimit: null, weight: 10);

Weapon _weapon(String? id, {WeaponKind kind = WeaponKind.simpleMelee}) => Weapon(
      id: id == null ? null : '/weapons/$id',
      name: id ?? 'Своё',
      damage: Dice.k6,
      damageType: DamageType.chopping,
      kind: kind,
      type: WeaponType.oneHanded,
    );

/// Все ссылки на доспехи и оружие PHB с ttg.club.
const _armorIds = [
  'padded_armor', 'leather_armor', 'studded_leather_armor', 'hide_armor', 'chain_shirt', 'scale_mail_armor', //
  'breastplate', 'half_plate_armor', 'ring_mail_armor', 'chain_mail', 'splint_armor', 'plate_armor',
];
const _weaponIds = [
  'quarterstaff', 'mace', 'club', 'dagger', 'spear', 'light_hammer', 'javelin', 'greatclub', 'handaxe', 'sickle', //
  'crossbow,_light', 'dart', 'shortbow', 'sling', 'halberd', 'war_pick', 'warhammer', 'battleaxe', 'glaive',
  'greatsword', 'lance', 'longsword', 'whip', 'shortsword', 'maul', 'morningstar', 'pike', 'rapier', 'greataxe',
  'scimitar', 'trident', 'flail', 'crossbow,_hand', 'crossbow,_heavy', 'longbow', 'blowgun', 'net',
];

List<String> _assets(AvatarLook look) => look.layers.map((e) => e.asset).toList();

void main() {
  test('appearance is saved with the character', () {
    final player = playerFixture();
    const appearance = Appearance(
      body: BodyType.female,
      hairstyle: 2,
      skin: SkinTone.amethyst,
      hair: HairColor.darkBrown,
      eyes: EyeColor.red,
      top: TopStyle.longDress,
      topColor: ClothColor.navy,
      bottom: BottomStyle.longSkirt,
      bottomColor: ClothColor.black,
      footwear: Footwear.sandals,
      footwearColor: ClothColor.walnut,
    );
    final changed = player.copyWith(personality: player.personality.copyWith(appearance: appearance));

    expect(Player.fromJson(changed.toJson()).personality.appearance, appearance);
    expect(changed, isNot(player));
  });

  test('race defaults: tieflings are red with yellow eyes', () {
    expect(Appearance.forRace(Race.tiefling).skin, SkinTone.red);
    expect(Appearance.forRace(Race.dwarfTiefling).eyes, EyeColor.yellow);
    expect(Appearance.forRace(Race.halfElf).skin, SkinTone.light);
  });

  test('race features: horns and tail for tieflings, ears for half-elves, short dwarf tiefling', () {
    const appearance = Appearance();
    const tiefling = AvatarLook(appearance: appearance, race: Race.tieflingFaerun);
    const halfElf = AvatarLook(appearance: appearance, race: Race.halfElf);
    const dwarf = AvatarLook(appearance: appearance, race: Race.dwarfTiefling);

    expect(_assets(tiefling), containsAll(['horns', 'tail']));
    expect(_assets(tiefling), isNot(contains('ears_elven')));
    expect(_assets(halfElf), contains('ears_elven'));
    expect(_assets(halfElf), isNot(contains('horns')));
    expect(tiefling.heightFactor, 1);
    expect(dwarf.heightFactor, lessThan(1));
    // Хвост перекрашивается в цвет кожи.
    final tail = tiefling.layers.firstWhere((e) => e.asset == 'tail');
    expect(tail.recolors.single.to, 'light');
  });

  test('hairstyle is the face: three per body, the third male one has a beard', () {
    List<String> hair(BodyType body, int index) => _assets(
          AvatarLook(appearance: Appearance(body: body, hairstyle: index), race: Race.halfElf),
        ).where((e) => e.startsWith('hair_') || e == 'beard').toList();

    final male = [for (var i = 0; i < Appearance.hairstyleCount; i++) hair(BodyType.male, i)];
    final female = [for (var i = 0; i < Appearance.hairstyleCount; i++) hair(BodyType.female, i)];
    expect({...male.map((e) => e.join())}, hasLength(3));
    expect({...female.map((e) => e.join())}, hasLength(3));
    expect(male[2], contains('beard'));
    expect(_assets(const AvatarLook(appearance: Appearance(body: BodyType.female), race: Race.halfElf)),
        containsAll(['body_female', 'head_female', 'top_longsleeve_female']));
  });

  test('clothes: top, bottom and footwear with their colors', () {
    final layers = const AvatarLook(
      appearance: Appearance(
        body: BodyType.female,
        top: TopStyle.vneck,
        topColor: ClothColor.teal,
        bottom: BottomStyle.longSkirt,
        bottomColor: ClothColor.black,
        footwear: Footwear.shoes,
        footwearColor: ClothColor.charcoal,
      ),
      race: Race.halfElf,
    ).layers;
    AvatarLayer layer(String asset) => layers.firstWhere((e) => e.asset == asset);

    expect(layer('top_vneck_female').recolors, [const Recolor.cloth('teal')]);
    expect(layer('long_skirt_female').recolors, [const Recolor.cloth('black')]);
    expect(layer('shoes_female').recolors, [const Recolor.cloth('charcoal')]);
    // Туфли — под юбкой, сапоги — поверх штанин.
    expect(layer('shoes_female').z, lessThan(layer('long_skirt_female').z));
    final boots = const AvatarLook(
      appearance: Appearance(body: BodyType.female, bottom: BottomStyle.longSkirt),
      race: Race.halfElf,
    ).layers;
    expect(boots.indexWhere((e) => e.asset == 'boots_female'),
        lessThan(boots.indexWhere((e) => e.asset == 'long_skirt_female')));
    expect(Appearance.forRace(Race.tiefling).topColor, ClothColor.maroon);
  });

  test('a dress hides the bottom; male body has no dresses and long skirts', () {
    const dressed = Appearance(body: BodyType.female, top: TopStyle.dress, bottom: BottomStyle.longSkirt);
    final female = _assets(const AvatarLook(appearance: dressed, race: Race.halfElf));
    expect(female, contains('top_dress_female'));
    expect(female.where((e) => e.contains('skirt') || e.startsWith('pants')), isEmpty);

    final male = dressed.withBody(BodyType.male);
    expect(male.top, TopStyle.longsleeve);
    expect(male.bottom, BottomStyle.skirt);
    // Облик с женской одеждой на мужском теле рисуется так же, как после смены телосложения.
    expect(
      _assets(AvatarLook(appearance: Appearance(top: dressed.top, bottom: dressed.bottom), race: Race.halfElf)),
      containsAll(['top_longsleeve_male', 'skirt_male']),
    );
    expect(dressed.withBody(BodyType.female), dressed);
  });

  test('worn equipment is drawn: armor, shield and the melee weapon first', () {
    final player = playerFixture().copyWith(
      armor: () => _armor('plate_armor', ArmorKind.heavy),
      shield: () => const Shield(name: 'Щит', defense: 2, weight: 6),
      mainWeapon: () => _weapon('longsword'),
      mainRangeWeapon: () => _weapon('longbow', kind: WeaponKind.martialRanged),
    );
    final assets = _assets(AvatarLook.of(player));

    expect(assets, containsAll(['plate_male', 'plate_arms_male', 'plate_legs_male', 'plate_feet_male']));
    expect(assets, contains('shield_male'));
    expect(assets, contains('longsword_fg'));
    expect(assets, isNot(contains('longbow_fg')));

    final ranged = _assets(AvatarLook.of(player.copyWith(mainWeapon: () => null)));
    expect(ranged, containsAll(['longbow_fg', 'longbow_bg']));
  });

  test('two weapons: the off-hand one is mirrored into the left hand', () {
    final player = playerFixture().copyWith(
      mainWeapon: () => _weapon('shortsword'),
      secondWeapon: () => _weapon('handaxe'),
      mainRangeWeapon: () => _weapon('crossbow,_hand', kind: WeaponKind.martialRanged),
      secondRangeWeapon: () => _weapon('crossbow,_hand', kind: WeaponKind.martialRanged),
    );
    String layers(AvatarLook look) => look.layers.where((e) => e.z == 140 || e.z == 9).join(' ');

    expect(layers(AvatarLook.of(player)), 'axe_bg~ sword_fg axe_fg~');
    // Без рукопашного оружия — дальнобойный комплект.
    final ranged = AvatarLook.of(player.copyWith(mainWeapon: () => null, secondWeapon: () => null));
    expect(layers(ranged), 'crossbow_fg crossbow_fg~');
  });

  test('armor and weapon fallbacks', () {
    List<String> look({Armor? armor, Weapon? weapon}) =>
        _assets(AvatarLook(appearance: const Appearance(), race: Race.tiefling, armor: armor, weapon: weapon));

    expect(look(armor: _armor('chain_shirt')), contains('chainmail_male'));
    expect(look(armor: _armor('chain_mail')), containsAll(['chainmail_male', 'plate_feet_male']));
    // Свой доспех — по виду.
    const custom = Armor(name: 'Свой', kind: ArmorKind.heavy, protection: 18, dexterityLimit: 0, weight: 65);
    expect(look(armor: custom), contains('plate_legs_male'));
    // Кнута в LPC нет; своё оружие — меч или лук.
    expect(look(weapon: _weapon('whip')).where((e) => e.endsWith('_fg')), isEmpty);
    expect(look(weapon: _weapon('pike')), containsAll(['spear_fg', 'spear_bg']));
    expect(look(weapon: _weapon(null)), contains('sword_fg'));
    expect(look(weapon: _weapon(null, kind: WeaponKind.simpleRanged)), contains('bow_fg'));
  });

  test('layers are drawn bottom to top', () {
    final look = AvatarLook(
      appearance: const Appearance(body: BodyType.female, hairstyle: 1),
      race: Race.tiefling,
      armor: _armor('leather_armor'),
      weapon: _weapon('shortbow', kind: WeaponKind.simpleRanged),
    );
    final z = look.layers.map((e) => e.z).toList();
    expect(z, [...z]..sort());
    expect(look.layers.first.asset, 'bow_bg');
  });

  test('every layer and palette exists for all races, faces, PHB armor and weapons', () {
    final palettes = AvatarPalettes.fromJson(jsonDecode(File('assets/avatar/palettes.json').readAsStringSync()));
    final looks = [
      for (final race in Race.values)
        for (final body in BodyType.values)
          for (final top in TopStyle.values)
            for (var hairstyle = 0; hairstyle < Appearance.hairstyleCount; hairstyle++)
              for (final armor in [null, ..._armorIds])
                AvatarLook(
                  appearance: Appearance(body: body, top: top, hairstyle: hairstyle),
                  race: race,
                  armor: armor == null ? null : _armor(armor),
                  hasShield: true,
                  weapon: _weapon(_weaponIds[hairstyle * 7 % _weaponIds.length]),
                ),
      for (final body in BodyType.values)
        for (final id in _weaponIds)
          AvatarLook(appearance: Appearance(body: body), race: Race.halfElf, weapon: _weapon(id)),
      for (final skin in SkinTone.values)
        for (final hair in HairColor.values)
          AvatarLook(appearance: Appearance(skin: skin, hair: hair), race: Race.tiefling),
      for (final eyes in EyeColor.values) AvatarLook(appearance: Appearance(eyes: eyes), race: Race.halfElf),
      for (final body in BodyType.values)
        for (final bottom in BottomStyle.values)
          for (final footwear in Footwear.values)
            AvatarLook(appearance: Appearance(body: body, bottom: bottom, footwear: footwear), race: Race.halfElf),
      for (final color in ClothColor.values)
        AvatarLook(
          appearance: Appearance(topColor: color, bottomColor: color, footwearColor: color),
          race: Race.halfElf,
        ),
    ];
    final layers = {for (final look in looks) ...look.layers};

    for (final layer in layers) {
      expect(File('assets/avatar/layers/${layer.asset}.png').existsSync(), isTrue, reason: layer.asset);
      for (final recolor in layer.recolors) {
        final from = palettes.colors(recolor.material, recolor.from);
        expect(palettes.colors(recolor.toMaterial, recolor.to), hasLength(from.length), reason: '$recolor');
      }
    }
    // Каждый слой из assets используется: лишние файлы не попадают в приложение.
    final files = Directory('assets/avatar/layers').listSync().map((e) => e.uri.pathSegments.last.split('.').first);
    expect(files.toSet(), layers.map((e) => e.asset).toSet());
  });

  test('compose recolors close colors and puts upper layers on top', () {
    Uint8List frame(Map<int, List<int>> pixels) {
      final out = Uint8List(avatarFrameSide * avatarFrameSide * 4);
      pixels.forEach((index, rgba) => out.setRange(index * 4, index * 4 + 4, rgba));
      return out;
    }

    final skin = frame({
      0: [204, 134, 101, 255],
      1: [10, 20, 30, 255],
      2: [100, 100, 100, 255]
    });
    final hair = frame({
      2: [255, 0, 0, 255],
      3: [0, 0, 255, 128]
    });
    final out = composeAvatar([
      // Цвет кожи с отклонением на 3 единицы всё равно заменяется.
      (skin, [(0xCF8968, 0x112233)]),
      (hair, const []),
    ]);

    expect(out.sublist(0, 4), [0x11, 0x22, 0x33, 255]);
    expect(out.sublist(4, 8), [10, 20, 30, 255]);
    expect(out.sublist(8, 12), [255, 0, 0, 255]);
    expect(out.sublist(12, 16), [0, 0, 255, 128]);
    expect(out.sublist(16, 20), [0, 0, 0, 0]);
    expect(premultiply(out).sublist(12, 16), [0, 0, 128, 128]);
  });

  test('mirrorFrame flips each row', () {
    final frame = Uint8List(avatarFrameSide * avatarFrameSide * 4);
    frame.setRange(0, 4, [1, 2, 3, 255]);
    final mirrored = mirrorFrame(frame);
    const last = (avatarFrameSide - 1) * 4;
    expect(mirrored.sublist(last, last + 4), [1, 2, 3, 255]);
    expect(mirrored.sublist(0, 4), [0, 0, 0, 0]);
    expect(mirrorFrame(mirrored), frame);
  });

  testWidgets('renderer builds a 64×64 image from the assets', (tester) async {
    final renderer = AvatarRenderer();
    final look = AvatarLook.of(playerFixture().copyWith(armor: () => _armor('chain_mail', ArmorKind.heavy)));

    final image = await tester.runAsync(() => renderer.render(look.layers));
    expect(image!.width, avatarFrameSide);
    expect(image.height, avatarFrameSide);
    // Тот же облик берётся из кэша.
    expect(identical(await tester.runAsync(() => renderer.render(look.layers)), image), isTrue);
  });

  testWidgets('character sheet shows the avatar; the editor saves a new appearance', (tester) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final documents = Directory.systemTemp.createTempSync('pixel_avatar');
    addTearDown(() => documents.deleteSync(recursive: true));
    final renderer = AvatarRenderer();
    getIt
      ..registerSingleton<AvatarStore>(AvatarStore(documents: () async => documents))
      ..registerSingleton<AvatarRenderer>(renderer);
    addTearDown(getIt.reset);
    final cubit = PlayerCubit(playerFixture(), await SpSource.init());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: BlocBuilder<PlayerCubit, Player>(
              builder: (context, player) => PlayerModel(player: player, child: const PersonalityScreen()),
            ),
          ),
        ),
      ),
    );
    expect(find.byType(AvatarStage), findsOneWidget);

    await tester.tap(find.byTooltip('Изменить облик'));
    await tester.runAsync(() => renderer.palettes);
    await tester.pumpAndSettle();
    expect(find.text('Причёска'), findsOneWidget);
    // Персонаж на листе и в редакторе, три причёски, у мужского тела — четыре рубахи, штаны и юбка, четыре вида обуви.
    expect(find.byType(PixelAvatar), findsNWidgets(15));

    await tester.tap(find.text('Женщина'));
    await tester.pump();
    // У женского добавляются два платья и длинная юбка.
    expect(find.byType(PixelAvatar), findsNWidgets(18));
    // Предпросмотр закреплён: прокрутка к кнопке внизу его не сдвигает.
    final preview = find.descendant(of: find.byType(Dialog), matching: find.byType(AvatarStage));
    final previewTop = tester.getTopLeft(preview);
    await tester.ensureVisible(find.text('Сохранить'));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(preview), previewTop);
    await tester.tap(find.text('Сохранить'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(cubit.state.personality.appearance.body, BodyType.female);
    expect(find.text('Причёска'), findsNothing);
  });
}
