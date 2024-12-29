import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/peculiarity.dart';
import 'package:dnd_character_list/presentation/common/widgets/text_parser/text_parses_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class PeculiarityWidget extends StatelessWidget {
  final Peculiarity classAbility;

  const PeculiarityWidget({super.key, required this.classAbility});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showDialog(
          context: context,
          builder: (_) => BlocProvider.value(
            value: context.read<PlayerCubit>(),
            child: Dialog(
              shape: const RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: _DialogInfo(classAbility: classAbility),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 16,
          ),
          child: Text(
            classAbility.name.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _DialogInfo extends StatelessWidget {
  final Peculiarity classAbility;

  const _DialogInfo({
    super.key,
    required this.classAbility,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            classAbility.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(8),
          Flexible(
            child: SingleChildScrollView(
              child: TextParses(
                classAbility.description.trim(),
              ),
            ),
          ),
          if (classAbility.manaRequired != null)
            Column(
              children: [
                const Gap(8),
                OutlinedButton(
                  onPressed: () {
                    context.read<PlayerCubit>().spendMana(
                          classAbility.manaRequired!.mana,
                        );
                    Navigator.pop(context);
                  },
                  child: Text('Использовать (${classAbility.manaRequired!.mana} маны)'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
