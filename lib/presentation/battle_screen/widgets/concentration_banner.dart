import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

/// Концентрация на заклинании; «Прервать» — когда за столом решили, что она закончилась.
class ConcentrationBanner extends StatelessWidget {
  const ConcentrationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final spell = PlayerModel.watch(context).concentration;
    if (spell == null) return const SizedBox();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: theme.colorScheme.secondaryContainer,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(
            children: [
              const Icon(Icons.psychology_outlined),
              const Gap(12),
              Expanded(child: Text('Концентрация: $spell')),
              TextButton(
                onPressed: () => context.read<PlayerCubit>().endConcentration(),
                child: const Text('Прервать'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Что сказать игроку после урона [damage]: спасбросок концентрации или что она прервалась (на 0 хитов).
String? concentrationNotice(Player before, Player after, int damage) {
  final spell = before.concentration;
  if (spell == null || damage <= 0) return null;
  if (after.concentration == null) return 'Концентрация на «$spell» прервана';
  return 'Концентрация на «$spell»: спасбросок Телосложения, Сл ${Player.concentrationSaveDc(damage)}';
}
