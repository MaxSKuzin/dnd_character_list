import 'package:dnd_character_list/data/sp_source.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/shield.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class PlayerCubit extends Cubit<Player> {
  final SpSource _source;

  PlayerCubit(
    @factoryParam super.player,
    this._source,
  );

  void takeDamage(int value) {
    emit(state.takeDamage(value));
  }

  void heal(int health) {
    emit(state.heal(health));
  }

  void shortRest(int health) {
    emit(state.heal(health));
  }

  void longRest() {
    emit(state.healFull());
  }

  void levelUp<T extends Specialization>(T spec) {
    emit(state.levelUp<T>(spec));
  }

  void addClass<T extends Specialization>(T spec) {
    emit(state.addClass(spec));
  }

  void spendMana(int mana) {
    emit(state.spendMana(mana));
  }

  void recoverMana(int mana) {
    emit(state.recoverMana(mana));
  }

  void changeDeadThrow({int? death, int? life}) {
    emit(state.changeDeadThrow(death: death, life: life));
  }

  void useExtra(ClassExtras extra) {
    emit(state.useExtra(extra));
  }

  void restoreExtra(ClassExtras extra) {
    emit(state.restoreExtra(extra));
  }

  Future<void> equipMainWeapon(Weapon weapon) async {
    final newPlayer = state.equipMainWeapon(weapon);
    await _source.savePlayer(newPlayer);
    emit(newPlayer);
  }

  Future<void> equipSecondaryWeapon(Weapon weapon) async {
    final newPlayer = state.equipSecondaryWeapon(weapon);
    await _source.savePlayer(newPlayer);
    emit(newPlayer);
  }

  Future<void> unequipMainWeapon(Weapon weapon) async {
    final newPlayer = state.unequipMainWeapon(weapon);
    await _source.savePlayer(newPlayer);
    emit(newPlayer);
  }

  Future<void> unequipSecondaryWeapon(Weapon weapon) async {
    final newPlayer = state.unequipSecondaryWeapon(weapon);
    await _source.savePlayer(newPlayer);
    emit(newPlayer);
  }

  Future<void> equipShield(Shield shield) async {
    final newPlayer = state.equipShield(shield);
    await _source.savePlayer(newPlayer);
    emit(newPlayer);
  }

  Future<void> unequipShield(Shield shield) async {
    final newPlayer = state.unequipShield(shield);
    await _source.savePlayer(newPlayer);
    emit(newPlayer);
  }

  Future<void> equipArmor(Armor armor) async {
    final newPlayer = state.equipArmor(armor);
    await _source.savePlayer(newPlayer);
    emit(newPlayer);
  }

  Future<void> unequipArmor(Armor armor) async {
    final newPlayer = state.unequipArmor(armor);
    await _source.savePlayer(newPlayer);
    emit(newPlayer);
  }
}
