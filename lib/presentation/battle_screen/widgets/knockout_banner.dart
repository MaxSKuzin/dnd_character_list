import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

/// Нокаут после трёх успешных спасбросков от смерти: персонаж с 1 хитом, но без сознания. В сессии мастера его
/// приводят в чувство союзник или мастер; без сессии — кнопка, когда за столом решили, что он очнулся.
class KnockoutBanner extends StatelessWidget {
  const KnockoutBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!PlayerModel.isKnockedOut(context)) return const SizedBox();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: theme.colorScheme.errorContainer,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(
            children: [
              const Icon(Icons.bedtime),
              const Gap(12),
              const Expanded(
                child: Text('Нокаут: 1 хит, без сознания. Вас может привести в чувство союзник или лечение.'),
              ),
              TextButton(
                onPressed: () => context.read<PlayerCubit>().wakeUp(),
                child: const Text('Очнуться'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
