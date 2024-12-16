import 'package:dnd_character_list/domain/models/stat.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:flutter/material.dart';

class EnterStatWidget extends StatelessWidget {
  final StatKind statKind;
  final int value;
  final bool canAdd;
  final bool canSubtract;
  final void Function() onAdd;
  final void Function() onSubtract;

  const EnterStatWidget({
    super.key,
    required this.statKind,
    required this.value,
    required this.canAdd,
    required this.canSubtract,
    required this.onAdd,
    required this.onSubtract,
  });

  @override
  Widget build(BuildContext context) {
    final stat = Stat(value: value, kind: statKind);
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Colors.white,
            width: 2,
          ),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    stat.kind.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: canSubtract ? onSubtract : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Text(
                    '${stat.value}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: canAdd ? onAdd : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              Expanded(
                child: Text(
                  '${stat.bonus >= 0 ? '+' : ''}${stat.bonus}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
