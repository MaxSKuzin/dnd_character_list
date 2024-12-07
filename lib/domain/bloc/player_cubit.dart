import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/specialization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlayerCubit extends Cubit<Player> {
  PlayerCubit(super.player);

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
    levelUp();
    emit(state.healFull());
  }

  void levelUp<T extends Specialization>() {
    emit(state.levelUp<T>());
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
}
