import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/presentation/common/widgets/labeled_border.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class ClassExtraWidget extends StatelessWidget {
  final ClassExtras extra;
  final int count;

  const ClassExtraWidget({
    required this.extra,
    required this.count,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: context.theme.copyWith(
        iconButtonTheme: IconButtonThemeData(
          style: context.theme.iconButtonTheme.style?.copyWith(
            backgroundColor: const WidgetStatePropertyAll(Colors.amber),
            iconColor: const WidgetStatePropertyAll(Colors.amber),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          final description = PlayerModel.getPlayer(context)
              .classes
              .firstWhere(
                (e) => e.classExtras.contains(extra),
              )
              .classExtraDescription;

          showDialog(
            context: context,
            builder: (_) => Dialog(
              shape: const RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: _DescriptionDialog(
                extra: extra,
                description: description(extra),
              ),
            ),
          );
        },
        child: LabeledBorder(
          backgroundColor: context.customColors?.cardColor,
          text: extra.name.toUpperCase(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.read<PlayerCubit>().useExtra(extra),
                  icon: const Text('-'),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$count',
                      style: context.theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => context.read<PlayerCubit>().restoreExtra(extra),
                  icon: const Text('+'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DescriptionDialog extends StatelessWidget {
  final ClassExtras extra;
  final String description;

  const _DescriptionDialog({
    required this.extra,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 24,
        horizontal: 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            extra.name,
            style: context.theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const Gap(16),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                Text(
                  description,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
