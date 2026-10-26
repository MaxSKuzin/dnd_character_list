import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';

class SpeedWidget extends StatelessWidget {
  const SpeedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
                      '${PlayerModel.getPlayer(context).speed}',
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
                        'СКОРОСТЬ',
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
