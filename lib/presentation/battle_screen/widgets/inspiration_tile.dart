import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Вдохновение от мастера: есть или нет, нажатие переключает.
class InspirationTile extends StatelessWidget {
  const InspirationTile({super.key});

  @override
  Widget build(BuildContext context) {
    final inspiration = PlayerModel.watch(context).inspiration;
    return InfoTile(
      label: 'Вдохновение',
      value: inspiration ? '★ Есть' : 'Нет',
      caption: inspiration ? 'нажмите, когда потратите' : 'нажмите, когда даст мастер',
      valueStyle: context.theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: inspiration ? context.theme.colorScheme.primary : Colors.white54,
      ),
      onTap: () => context.read<PlayerCubit>().setInspiration(!inspiration),
    );
  }
}
