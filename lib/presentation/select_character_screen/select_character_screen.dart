import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/data/avatar_store.dart';
import 'package:dnd_character_list/domain/bloc/created_characters_cubit.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/common/widgets/character_avatar.dart';
import 'package:dnd_character_list/presentation/common/widgets/class_image.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class SelectCharacterScreen extends StatelessWidget {
  const SelectCharacterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocProvider(
            create: (_) => getIt<CreatedCharactersCubit>(),
            child: BlocBuilder<CreatedCharactersCubit, List<Player>>(
              builder: (context, characters) => GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                children: [
                  ...characters.map(
                    (character) => GestureDetector(
                      onTap: () {
                        context.router.push(
                          MainFlowRoute(player: character),
                        );
                      },
                      child: Stack(
                        children: [
                          Positioned.fill(child: _CharacterPicture(character: character)),
                          Center(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      character.personality.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                      ),
                                    ),
                                    Text(
                                      '${character.level} уровень',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => context.pushRoute(const CreateCharacterRoute()),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ),
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
    final classImage = ClassImage(classType: character.classes.first.classKind);
    if (avatar == null) return classImage;
    return FutureBuilder(
      future: getIt<AvatarStore>().file(avatar),
      builder: (context, snapshot) => switch (snapshot.data) {
        final file? => ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FramedAvatarImage(file: file, frame: character.personality.avatarFrame),
          ),
        null => classImage,
      },
    );
  }
}
