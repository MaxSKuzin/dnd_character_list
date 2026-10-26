import 'package:dnd_character_list/data/sp_source.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/balance.dart';
import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/domain/models/combat.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/shield.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
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

  void wakeUp() {
    emit(state.wakeUp());
  }

  void shortRest(int health) {
    emit(state.heal(health));
  }

  void longRest() {
    emit(state.longRest());
  }

  void levelUp<T extends Specialization>(T spec) {
    emit(state.levelUp<T>(spec));
  }

  void addClass<T extends Specialization>(T spec) {
    emit(state.addClass(spec));
  }

  void spendSpellSlot(SpellSlot slot) {
    emit(state.spendSpellSlot(slot));
  }

  void restoreSpellSlot(SpellSlot slot) {
    emit(state.restoreSpellSlot(slot));
  }

  void spendSorceryPoints(int points) {
    emit(state.spendSorceryPoints(points));
  }

  void convertSpellSlotToSorceryPoints(SpellSlot slot) {
    emit(state.convertSpellSlotToSorceryPoints(slot));
  }

  void createSpellSlot(SpellSlot slot) {
    emit(state.createSpellSlot(slot));
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

  Future<void> equipWeapon(Weapon weapon, WeaponSlot slot) async {
    final newPlayer = state.equipWeapon(weapon, slot);
    await _source.savePlayer(newPlayer);
    emit(newPlayer);
  }

  Future<void> unequipWeapon(WeaponSlot slot) async {
    final newPlayer = state.unequipWeapon(slot);
    await _source.savePlayer(newPlayer);
    emit(newPlayer);
  }

  Future<void> equipShield(Shield shield) async {
    final newPlayer = state.equipShield(shield);
    await _source.savePlayer(newPlayer);
    emit(newPlayer);
  }

  Future<void> unequipShield() async {
    final newPlayer = state.unequipShield();
    await _source.savePlayer(newPlayer);
    emit(newPlayer);
  }

  Future<void> equipArmor(Armor armor) async {
    final newPlayer = state.equipArmor(armor);
    await _source.savePlayer(newPlayer);
    emit(newPlayer);
  }

  Future<void> unequipArmor() async {
    final newPlayer = state.unequipArmor();
    await _source.savePlayer(newPlayer);
    emit(newPlayer);
  }

  Future<void> spendBalance(Balance balance) async {
    final newPlayer = state.spendBalance(balance);
    await _source.savePlayer(newPlayer);
    emit(newPlayer);
  }

  Future<void> addBalance(Balance balance) async {
    final newPlayer = state.addBalance(balance);
    await _source.savePlayer(newPlayer);
    emit(newPlayer);
  }

  Future<void> removeItem(InventoryItem item) async {
    final newPlayer = state.removeItem(item);
    await _source.savePlayer(newPlayer);
    emit(newPlayer);
  }

  Future<void> addItemQuantity(InventoryItem item) async {
    final newPlayer = state.addItemQuantity(item);
    await _source.savePlayer(newPlayer);
    emit(newPlayer);
  }

  Future<void> addItem(InventoryItem item) async {
    final newPlayer = state.addItem(item);
    await _source.savePlayer(newPlayer);
    emit(newPlayer);
  }
}
