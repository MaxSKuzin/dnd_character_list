import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/bloc/create_character_cubit.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/start_equipment.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/domain/models/weapon_type.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/weapon_info_dialog.dart';
import 'package:dnd_character_list/presentation/common/widgets/labeled_border.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

@RoutePage()
class SelectWeaponsScreen extends StatefulWidget {
  final StartEquipment equipment;

  const SelectWeaponsScreen({
    super.key,
    required this.equipment,
  });

  @override
  State<SelectWeaponsScreen> createState() => _SelectWeaponsScreenState();
}

class _SelectWeaponsScreenState extends State<SelectWeaponsScreen> {
  Weapon? _selectedWeapon;
  late Weapon? _secondWeapon =
      widget.equipment.secondWeapons?.length == 1 ? widget.equipment.secondWeapons!.first : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Основное оружие ${_selectedWeapon != null ? '1' : '0'}/1',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(16),
                ...widget.equipment.weapons.map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: WeaponWidget(
                      weapon: e,
                      isSelected: _selectedWeapon == e,
                      onTap: () {
                        setState(() {
                          if (_selectedWeapon == e) {
                            _selectedWeapon = null;
                          } else {
                            _selectedWeapon = e;
                          }
                        });
                      },
                    ),
                  ),
                ),
                if (widget.equipment.secondWeapons != null) ...[
                  const Gap(16),
                  Text(
                    'Второстепенное оружие ${_secondWeapon != null ? '1' : '0'}/1',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(16),
                  ...widget.equipment.secondWeapons!.map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: WeaponWidget(
                        weapon: e,
                        isSelected: _secondWeapon == e,
                        onTap: () {
                          if (widget.equipment.secondWeapons?.length == 1) return;
                          setState(() {
                            if (_selectedWeapon == e) {
                              _secondWeapon = null;
                            } else {
                              _secondWeapon = e;
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ],
                const Gap(16),
                OutlinedButton(
                  onPressed: _selectedWeapon != null &&
                          (_secondWeapon != null || (widget.equipment.secondWeapons?.length ?? 0) == 0)
                      ? () {
                          context.read<CreateCharacterCubit>().setWeapons(
                                _selectedWeapon!,
                                _secondWeapon,
                              );
                          if (widget.equipment.armor != null) {
                            context.read<CreateCharacterCubit>().setArmor(
                                  widget.equipment.armor!,
                                );
                          }
                          final newLanguagesCount =
                              context.read<CreateCharacterCubit>().race!.additionalLanguagesCount +
                                  context.read<CreateCharacterCubit>().background!.additionalLangauges;
                          if (newLanguagesCount > 0) {
                            context.pushRoute(
                              SelectLanguagesRoute(
                                knownLanguages: context.read<CreateCharacterCubit>().race!.knownLanguages,
                                maxLanguages: newLanguagesCount,
                              ),
                            );
                          } else {
                            context.pushRoute(const SetPersonalityRoute());
                          }
                        }
                      : null,
                  child: const Text('Далее'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WeaponWidget extends StatelessWidget {
  final Weapon weapon;
  final Function() onTap;
  final bool isSelected;

  const WeaponWidget({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.weapon,
  });

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ColorFilter.mode(
        isSelected ? Colors.transparent : Colors.black45,
        BlendMode.srcATop,
      ),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        onLongPress: () => WeaponInfoDialog.show(context, weapon: weapon),
        child: Row(
          children: [
            Expanded(
              child: LabeledBorder(
                backgroundColor: context.customColors?.cardColor,
                text:
                    (weapon.type == WeaponType.universal ? WeaponType.oneHanded.name : weapon.type.name).toUpperCase(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: Center(
                    child: Text(
                      weapon.name,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            const Gap(8),
            Expanded(
              child: LabeledBorder(
                backgroundColor: context.customColors?.cardColor,
                text: '1${Dice.k20.name}',
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: Center(
                    child: Text(
                      weapon.isFencing ? StatKind.dexterity.name : StatKind.strength.name,
                    ),
                  ),
                ),
              ),
            ),
            const Gap(8),
            Expanded(
              child: LabeledBorder(
                backgroundColor: context.customColors?.cardColor,
                text: weapon.damageType.name.toUpperCase(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: Center(
                    child: Text(weapon.getRawDamageString()),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
