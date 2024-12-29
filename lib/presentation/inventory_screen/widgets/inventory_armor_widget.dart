import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/presentation/inventory_screen/widgets/armor_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InventoryArmorWidget extends StatelessWidget {
  const InventoryArmorWidget({
    super.key,
    required this.item,
    required this.quantity,
  });

  final Armor item;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => showDialog(
        context: context,
        builder: (_) => Dialog(
          shape: const RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.white,
            ),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: BlocProvider.value(
            value: context.read<PlayerCubit>(),
            child: ArmorWidget(
              item,
              canWear: true,
            ),
          ),
        ),
      ),
      title: Text(item.name),
      trailing: Text('x$quantity'),
    );
  }
}
