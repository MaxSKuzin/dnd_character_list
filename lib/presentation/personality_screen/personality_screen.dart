import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/peculiarity.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/presentation/common/widgets/character_avatar.dart';
import 'package:dnd_character_list/presentation/common/widgets/class_image.dart';
import 'package:dnd_character_list/presentation/common/widgets/html_content.dart';
import 'package:dnd_character_list/presentation/common/widgets/pixel_avatar/appearance_editor.dart';
import 'package:dnd_character_list/presentation/common/widgets/pixel_avatar/avatar_layers.dart';
import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/extensions/feature_choices.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:dnd_character_list/presentation/personality_screen/widgets/peculiarity_widget.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

/// Лист персонажа: шапка с аватаром, внешность, классы, особенности по источникам, языки и владения,
/// характер и предыстория.
@RoutePage()
class PersonalityScreen extends StatelessWidget {
  const PersonalityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = PlayerModel.watch(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _Header(player: player),
          const Gap(16),
          _Appearance(player: player),
          const Gap(16),
          _Classes(classes: player.classes),
          const Gap(16),
          _Features(player: player),
          const Gap(16),
          _LanguagesAndProficiencies(player: player),
          if (player.personality.traits.isNotEmpty) ...[
            const Gap(16),
            _Traits(traits: player.personality.traits),
          ],
          const Gap(16),
          _Background(player: player),
          const Gap(24),
          const _DeleteCharacter(),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Player player;

  const _Header({required this.player});

  @override
  Widget build(BuildContext context) {
    final personality = player.personality;
    final textTheme = context.theme.textTheme;
    return SheetHeader(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Аватар меняется нажатием; хранится только на этом устройстве.
              GestureDetector(
                onTap: () => changeAvatar(context),
                child: Stack(
                  children: [
                    CharacterAvatar(avatar: personality.avatar, frame: personality.avatarFrame, name: personality.name),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.theme.colorScheme.primary,
                          border: Border.all(color: Colors.white),
                        ),
                        child: Icon(Icons.photo_camera, size: 14, color: context.theme.colorScheme.onPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(personality.name, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                    const Gap(2),
                    Text('${player.race.name} · ${player.level} уровень', style: textTheme.bodyMedium),
                    Text(player.background.name, style: textTheme.bodySmall?.copyWith(color: Colors.white70)),
                    const Gap(8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final spec in player.classes) SheetBadge('${spec.classKind.localizedName} ${spec.level}')
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(16),
          FilledButton.icon(
            onPressed: () => context.pushRoute(LevelUpFlowRoute(player: PlayerModel.getPlayer(context))),
            icon: const Icon(Icons.arrow_upward),
            label: const Text('Новый уровень'),
          ),
        ],
      ),
    );
  }
}

class _Appearance extends StatelessWidget {
  final Player player;

  const _Appearance({required this.player});

  @override
  Widget build(BuildContext context) {
    final personality = player.personality;
    final values = [
      ('Возраст', '${personality.age}'),
      ('Рост', '${personality.height} см'),
      ('Вес', '${personality.weight} кг'),
    ];
    final look = AvatarLook.of(player);
    return SheetSection(
      icon: Icons.face_outlined,
      title: 'Внешность',
      trailing: IconButton(
        tooltip: 'Изменить облик',
        onPressed: () => _editAppearance(context, look),
        icon: const Icon(Icons.edit_outlined),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Пиксельный персонаж в надетой экипировке; нажатие открывает редактор облика.
          Center(
            child: GestureDetector(
              onTap: () => _editAppearance(context, look),
              child: AvatarStage(look: look, size: 224),
            ),
          ),
          const Gap(8),
          TileGrid(
            columns: 3,
            children: [
              for (final (label, value) in values) InfoTile(label: label, value: value.trim().isEmpty ? '—' : value)
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _editAppearance(BuildContext context, AvatarLook look) async {
    final cubit = context.read<PlayerCubit>();
    final appearance = await AppearanceEditor.show(context, look);
    if (appearance != null) await cubit.setAppearance(appearance);
  }
}

class _Classes extends StatelessWidget {
  final List<Specialization> classes;

  const _Classes({required this.classes});

  @override
  Widget build(BuildContext context) {
    return SheetSection(
      icon: Icons.shield_moon_outlined,
      title: classes.length > 1 ? 'Классы' : 'Класс',
      child: Column(
        children: [
          for (final (index, spec) in classes.indexed) ...[
            if (index > 0) const Divider(height: 16, color: Colors.white12),
            Row(
              children: [
                SizedBox.square(dimension: 56, child: ClassImage(classType: spec.classKind)),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(spec.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      Text(
                        '${spec.level} уровень · кость хитов ${spec.hitDice.name}',
                        style: context.theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                      ),
                      if (spec.choicesDescription case final choices?)
                        Text(choices, style: context.theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Особенности по источникам: раса, предыстория, каждый класс, черты. Выбор в умениях виден в названии.
class _Features extends StatelessWidget {
  final Player player;

  const _Features({required this.player});

  @override
  Widget build(BuildContext context) {
    final background = player.background;
    final groups = <(String, List<Peculiarity>)>[
      (player.race.name, player.race.peculiarities),
      if (background.featureName != null)
        (
          'Предыстория',
          [
            Peculiarity(
              name: background.featureName!.toUpperCase(),
              description: background.featureHtml ?? '',
              isHtml: true,
            ),
          ],
        ),
      for (final spec in player.classes) (spec.name, spec.abilitiesWithChoices),
      (
        'Черты',
        [
          for (final e in player.feats)
            Peculiarity(name: 'ЧЕРТА: ${e.feat.name.toUpperCase()}', description: e.feat.descriptionHtml, isHtml: true),
        ],
      ),
    ].where((e) => e.$2.isNotEmpty).toList();
    if (groups.isEmpty) return const SizedBox.shrink();
    return SheetSection(
      icon: Icons.auto_awesome_outlined,
      title: 'Особенности',
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, (title, features)) in groups.indexed) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(16, index == 0 ? 0 : 12, 16, 4),
              child: Text(
                title,
                style: context.theme.textTheme.labelMedium?.copyWith(color: context.theme.colorScheme.primary),
              ),
            ),
            for (final feature in features) PeculiarityWidget(classAbility: feature),
          ],
        ],
      ),
    );
  }
}

class _LanguagesAndProficiencies extends StatelessWidget {
  final Player player;

  const _LanguagesAndProficiencies({required this.player});

  @override
  Widget build(BuildContext context) {
    final proficiencies = {
      if (player.armorProficiencies.isNotEmpty)
        'Доспехи': player.armorProficiencies.map((e) => e.localizedName).join(', '),
      if (player.toolProficiencies.isNotEmpty) 'Инструменты': player.toolProficiencies.join(', '),
    };
    return SheetSection(
      icon: Icons.translate,
      title: 'Языки и владения',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final language in player.knownLanguages) SheetBadge(language.localizedName)],
          ),
          for (final MapEntry(key: title, value: value) in proficiencies.entries) ...[
            const Gap(12),
            Text(title, style: context.theme.textTheme.labelSmall?.copyWith(color: Colors.white60)),
            Text(value),
          ],
        ],
      ),
    );
  }
}

class _Traits extends StatelessWidget {
  final Map<String, String> traits;

  const _Traits({required this.traits});

  @override
  Widget build(BuildContext context) {
    return SheetSection(
      icon: Icons.psychology_outlined,
      title: 'Характер',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, MapEntry(key: title, value: value)) in traits.entries.indexed) ...[
            if (index > 0) const Gap(12),
            Text(title, style: context.theme.textTheme.labelSmall?.copyWith(color: Colors.white60)),
            const Gap(2),
            Text(value),
          ],
        ],
      ),
    );
  }
}

class _Background extends StatelessWidget {
  final Player player;

  const _Background({required this.player});

  @override
  Widget build(BuildContext context) {
    final background = player.background;
    final story = player.personality.story.trim();
    return SheetSection(
      icon: Icons.menu_book_outlined,
      title: 'Предыстория: ${background.name}',
      trailing: IconButton(
        tooltip: 'Описание предыстории',
        onPressed: () => showDialog(
          context: context,
          builder: (_) => HtmlDialog(title: background.name, html: background.descriptionHtml),
        ),
        icon: const Icon(Icons.info_outline),
      ),
      child: Text(
        story.isEmpty ? 'История персонажа пока не написана.' : story,
        style: story.isEmpty ? const TextStyle(color: Colors.white54, fontStyle: FontStyle.italic) : null,
      ),
    );
  }
}

/// Удаление персонажа с подтверждением; после него — экран выбора персонажа.
class _DeleteCharacter extends StatelessWidget {
  const _DeleteCharacter();

  Future<void> _delete(BuildContext context) async {
    final cubit = context.read<PlayerCubit>();
    final name = cubit.state.personality.name;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удалить «$name»?'),
        content: const Text('Персонаж и его аватар удалятся с этого устройства. Отменить это нельзя.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: context.theme.colorScheme.error),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final router = context.router.root;
    await cubit.delete();
    router.popUntilRouteWithName(SelectCharacterRoute.name);
  }

  @override
  Widget build(BuildContext context) {
    final color = context.theme.colorScheme.error;
    return OutlinedButton.icon(
      onPressed: () => _delete(context),
      style: OutlinedButton.styleFrom(foregroundColor: color, side: BorderSide(color: color)),
      icon: const Icon(Icons.delete_outline),
      label: const Text('Удалить персонажа'),
    );
  }
}
