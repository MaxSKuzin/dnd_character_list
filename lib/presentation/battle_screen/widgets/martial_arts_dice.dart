import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/models/classes/monk.dart';
import 'package:dnd_character_list/presentation/common/widgets/html_content.dart';
import 'package:dnd_character_list/presentation/common/widgets/labeled_border.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';

/// Кость боевых искусств монаха в сетке счётчиков. В доспехе или со щитом умение не действует — плитка
/// приглушена. Нажатие показывает описание «Боевых искусств».
class MartialArtsDice extends StatelessWidget {
  const MartialArtsDice({super.key});

  /// Описание умения с сайта, сохранённое в монахе.
  static void showDescription(BuildContext context) {
    final feature = PlayerModel.getPlayer(context)
        .classes
        .whereType<Monk>()
        .expand((e) => e.features)
        .firstWhereOrNull((e) => e.name == 'БОЕВЫЕ ИСКУССТВА');
    if (feature == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Боевые искусства'),
        content: SingleChildScrollView(child: HtmlContent(feature.description)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = PlayerModel.watch(context);
    final monk = player.classes.whereType<Monk>().firstOrNull;
    if (monk == null) return const SizedBox.shrink();
    final isActive = Monk.isUnarmored(player);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showDescription(context),
      child: LabeledBorder(
        backgroundColor: context.customColors?.cardColor,
        text: 'БОЕВЫЕ ИСКУССТВА',
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '1${monk.martialArtsDice.name}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isActive ? null : Colors.grey,
                ),
              ),
              if (!isActive)
                const Text(
                  'Не действует в доспехе или со щитом',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
