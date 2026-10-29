import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/presentation/common/widgets/enter_number_dialog.dart';
import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Временные хиты: «+» — получить (остаётся большее из прежних и новых), «−» — убрать. Урон тратит их первыми.
class TempHits extends StatelessWidget {
  const TempHits({super.key});

  @override
  Widget build(BuildContext context) {
    final tempHits = PlayerModel.tempHits(context);
    return InfoTile(
      label: 'Временные хиты',
      value: tempHits == 0 ? '—' : '$tempHits',
      caption: 'тратятся первыми',
      valueStyle: context.theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      decreaseTooltip: 'Убрать',
      increaseTooltip: 'Получить',
      onDecrease: tempHits == 0 ? null : () => context.read<PlayerCubit>().gainTempHits(0),
      onIncrease: () async {
        final cubit = context.read<PlayerCubit>();
        final value = await EnterNumberDialog.show(
          context,
          title: 'Временные хиты',
          labelText: 'Не складываются: останется большее',
        );
        if (value != null) cubit.gainTempHits(value);
      },
    );
  }
}
