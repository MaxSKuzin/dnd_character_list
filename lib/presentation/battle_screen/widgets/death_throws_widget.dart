import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/presentation/common/widgets/labeled_border.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class DeathThrowsWidget extends StatelessWidget {
  const DeathThrowsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final throws = PlayerModel.deathThrows(context);
    final currentHits = PlayerModel.health(context).current;
    final isDead = PlayerModel.isDead(context);

    final emptyCircle = Container(
      decoration: ShapeDecoration(
        shape: const CircleBorder(
          side: BorderSide(
            color: Colors.white,
          ),
        ),
        color: context.theme.scaffoldBackgroundColor,
      ),
      height: 20,
      width: 20,
    );
    final filledCircle = Container(
      decoration: const ShapeDecoration(
        shape: CircleBorder(
          side: BorderSide(
            color: Colors.white,
          ),
        ),
      ),
      height: 20,
      width: 20,
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: const ShapeDecoration(
          shape: CircleBorder(),
          color: Colors.white,
        ),
      ),
    );
    return IgnorePointer(
      ignoring: currentHits > 0 || isDead,
      child: LabeledBorder(
        backgroundColor: context.customColors?.cardColor,
        text: 'СПАСБРОСКИ ОТ СМЕРТИ',
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'УСПЕХ',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        for (var i = 0; i < 5; i++)
                          i.isOdd
                              ? const Expanded(
                                  child: Column(
                                    children: [
                                      Divider(
                                        color: Colors.white,
                                        thickness: 1,
                                        height: 1,
                                      ),
                                      Gap(2),
                                      Divider(
                                        color: Colors.white,
                                        thickness: 1,
                                        height: 1,
                                      ),
                                    ],
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () => context.read<PlayerCubit>().changeDeadThrow(
                                        life: (i ~/ 2) + 1,
                                      ),
                                  child: (i ~/ 2) + 1 <= throws.life ? filledCircle : emptyCircle,
                                ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'ПРОВАЛ',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        for (var i = 0; i < 5; i++)
                          i.isOdd
                              ? const Expanded(
                                  child: Column(
                                    children: [
                                      Divider(
                                        color: Colors.white,
                                        thickness: 1,
                                        height: 1,
                                      ),
                                      Gap(2),
                                      Divider(
                                        color: Colors.white,
                                        thickness: 1,
                                        height: 1,
                                      ),
                                    ],
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () => context.read<PlayerCubit>().changeDeadThrow(
                                        death: (i ~/ 2) + 1,
                                      ),
                                  child: (i ~/ 2) + 1 <= throws.death ? filledCircle : emptyCircle,
                                ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
