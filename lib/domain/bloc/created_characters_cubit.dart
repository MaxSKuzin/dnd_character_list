import 'package:dnd_character_list/data/sp_source.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class CreatedCharactersCubit extends Cubit<List<Player>> {
  final SpSource _source;

  CreatedCharactersCubit(this._source) : super([]);

  void loadPlayers() {
    emit(_source.getSavedPlayers());
  }

  void removePlayer(Player player) {
    _source.removePlayer(player);
    emit(_source.getSavedPlayers());
  }
}
