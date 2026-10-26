import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

/// Спасброски от смерти: по три отметки успехов и провалов, нажатие на отметку ставит столько.
class DeathThrowsWidget extends StatelessWidget {
  const DeathThrowsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final throws = PlayerModel.deathThrows(context);
    final currentHits = PlayerModel.health(context).current;
    final isDead = PlayerModel.isDead(context);
    final cubit = context.read<PlayerCubit>();
    // Спасброски нужны только на 0 хитов — в остальное время плитка приглушена, но остаётся на месте.
    final isActive = currentHits == 0 && !isDead;
    return IgnorePointer(
      ignoring: !isActive,
      child: Opacity(
        opacity: isActive || isDead ? 1 : 0.4,
        child: SheetTile(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Спасброски от смерти',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.theme.textTheme.labelSmall?.copyWith(color: Colors.white60),
              ),
              const Gap(4),
              _Marks(
                title: 'Успех',
                count: throws.life,
                color: Colors.greenAccent,
                onSelected: (value) => cubit.changeDeadThrow(life: value),
              ),
              _Marks(
                title: 'Провал',
                count: throws.death,
                color: Colors.redAccent,
                onSelected: (value) => cubit.changeDeadThrow(death: value),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Marks extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final ValueChanged<int> onSelected;

  const _Marks({required this.title, required this.count, required this.color, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.theme.textTheme.labelMedium?.copyWith(color: Colors.white70),
          ),
        ),
        for (var i = 1; i <= 3; i++)
          InkResponse(
            onTap: () => onSelected(i),
            radius: 16,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                i <= count ? Icons.circle : Icons.circle_outlined,
                size: 20,
                color: i <= count ? color : Colors.white38,
              ),
            ),
          ),
      ],
    );
  }
}
