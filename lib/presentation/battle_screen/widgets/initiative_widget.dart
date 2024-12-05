import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';

class InitiativeWidget extends StatelessWidget {
  const InitiativeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = PlayerModel.stats(context);
    final initiative = stats.firstWhere((e) => e.kind == StatKind.dexterity).bonus;
    final decoration = ShapeDecoration(
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(8),
      ),
    );
    return DecoratedBox(
      decoration: decoration,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: DecoratedBox(
          decoration: decoration,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Expanded(
                  child: Center(
                    child: Text(
                      '${initiative >= 0 ? '+' : ''}$initiative',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: FittedBox(
                      child: Text(
                        'ИНИЦИАТИВА',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
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
