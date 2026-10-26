import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/data/avatar_store.dart';
import 'package:dnd_character_list/domain/bloc/created_characters_cubit.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/common/widgets/character_avatar.dart';
import 'package:dnd_character_list/presentation/common/widgets/class_image.dart';
import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

/// Выбор персонажа: карточки с аватаром (или картинкой класса), именем, расой и классами; последняя — новый
/// персонаж. Удаляется персонаж на его экране.
@RoutePage()
class SelectCharacterScreen extends StatelessWidget {
  const SelectCharacterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocProvider(
          create: (_) => getIt<CreatedCharactersCubit>(),
          child: BlocBuilder<CreatedCharactersCubit, List<Player>>(
            builder: (context, characters) => CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  sliver: SliverToBoxAdapter(
                    child: SheetHeader(
                      child: Row(
                        children: [
                          const Icon(Icons.groups_outlined, size: 32),
                          const Gap(12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Персонажи',
                                  style: context.theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  characters.isEmpty ? 'Создайте первого персонажа' : 'Выберите, кем играть',
                                  style: context.theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 260,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    delegate: SliverChildListDelegate([
                      for (final character in characters) _CharacterCard(character: character),
                      const _NewCharacterCard(),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final Player character;

  const _CharacterCard({required this.character});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.theme.textTheme;
    return Material(
      color: context.customColors?.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.router.push(MainFlowRoute(player: character)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _CharacterPicture(character: character),
            // Затемнение снизу, чтобы подпись читалась на любой картинке.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.transparent, Colors.black87],
                  stops: [0, 0.45, 1],
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    character.personality.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${character.race.name} · ${character.level} уровень',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                  Text(
                    character.classes.map((e) => '${e.classKind.localizedName} ${e.level}').join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewCharacterCard extends StatelessWidget {
  const _NewCharacterCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white54),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.pushRoute(const CreateCharacterRoute()),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 40),
            Gap(8),
            Text('Новый персонаж'),
          ],
        ),
      ),
    );
  }
}

/// Аватар персонажа, а без него — картинка основного класса.
class _CharacterPicture extends StatelessWidget {
  final Player character;

  const _CharacterPicture({required this.character});

  @override
  Widget build(BuildContext context) {
    final avatar = character.personality.avatar;
    final classImage = Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 56),
      child: ClassImage(classType: character.classes.first.classKind),
    );
    if (avatar == null) return classImage;
    return FutureBuilder(
      future: getIt<AvatarStore>().file(avatar),
      builder: (context, snapshot) => switch (snapshot.data) {
        // Квадрат аватара по большей стороне карточки: заполняет её, края обрезаются.
        final file? => LayoutBuilder(
            builder: (context, constraints) {
              final side = constraints.biggest.longestSide;
              return ClipRect(
                child: OverflowBox(
                  minWidth: side,
                  maxWidth: side,
                  minHeight: side,
                  maxHeight: side,
                  child: FramedAvatarImage(file: file, frame: character.personality.avatarFrame),
                ),
              );
            },
          ),
        null => classImage,
      },
    );
  }
}
