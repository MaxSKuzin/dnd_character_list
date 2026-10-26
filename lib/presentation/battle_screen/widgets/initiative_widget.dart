import 'package:dnd_character_list/data/session/session_source.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:dnd_character_list/presentation/session/initiative_prompt.dart';
import 'package:flutter/material.dart';

/// Бонус инициативы. В сессии мастера нажатие открывает ввод броска — он уходит мастеру в очередь боя.
class InitiativeWidget extends StatelessWidget {
  const InitiativeWidget({super.key});

  void _onTap(BuildContext context) {
    final player = PlayerModel.getPlayer(context);
    if (getIt<SessionSource>().isJoined(player)) askInitiative(context, player);
  }

  @override
  Widget build(BuildContext context) {
    final initiative = PlayerModel.watch(context).initiative;

    return GestureDetector(
      onTap: () => _onTap(context),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: DecoratedBox(
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(4),
              ),
              color: context.customColors?.cardColor,
            ),
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
      ),
    );
  }
}
