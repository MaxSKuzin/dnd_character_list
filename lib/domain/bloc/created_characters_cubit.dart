import 'dart:async';

import 'package:dnd_character_list/data/sp_source.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class CreatedCharactersCubit extends Cubit<List<Player>> {
  final SpSource _source;
  late final StreamSubscription _subscription;

  CreatedCharactersCubit(this._source) : super([]) {
    _source.loadPlayers();
    _subscription = _source.playersStream.listen((event) {
      emit(event);
    });
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }

  void removePlayer(Player player) {
    _source.removePlayer(player);
  }
}
