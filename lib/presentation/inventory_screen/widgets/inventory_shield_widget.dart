import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/shield.dart';
import 'package:dnd_character_list/presentation/inventory_screen/widgets/shield_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InventoryShieldWidget extends StatelessWidget {
  const InventoryShieldWidget({
    super.key,
    required this.item,
  });

  final Shield item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => showDialog(
        context: context,
        builder: (_) => BlocProvider.value(
          value: context.read<PlayerCubit>(),
          child: ShieldDialog(item),
        ),
      ),
      title: Text(item.name),
    );
  }
}

