import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/specialization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlayerCubit extends Cubit<Player> {
  PlayerCubit(super.player);

  void takeDamage(int value) {
    emit(state.takeDamage(value));
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
}
