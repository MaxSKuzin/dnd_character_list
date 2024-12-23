// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dnd_character_list/data/sp_source.dart' as _i895;
import 'package:dnd_character_list/domain/bloc/create_character_cubit.dart'
    as _i475;
import 'package:dnd_character_list/domain/bloc/created_characters_cubit.dart'
    as _i716;
import 'package:dnd_character_list/domain/bloc/level_up_cubit.dart' as _i876;
import 'package:dnd_character_list/domain/bloc/player_cubit.dart' as _i571;
import 'package:dnd_character_list/domain/models/player.dart' as _i747;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    await gh.singletonAsync<_i895.SpSource>(
      () => _i895.SpSource.init(),
      preResolve: true,
    );
    gh.factoryParam<_i571.PlayerCubit, _i747.Player, dynamic>((
      player,
      _,
    ) =>
        _i571.PlayerCubit(
          player,
          gh<_i895.SpSource>(),
        ));
    gh.factory<_i716.CreatedCharactersCubit>(
        () => _i716.CreatedCharactersCubit(gh<_i895.SpSource>()));
    gh.factory<_i475.CreateCharacterCubit>(
        () => _i475.CreateCharacterCubit(gh<_i895.SpSource>()));
    gh.factoryParam<_i876.LevelUpCubit, _i747.Player, dynamic>((
      player,
      _,
    ) =>
        _i876.LevelUpCubit(
          gh<_i895.SpSource>(),
          player,
        ));
    return this;
  }
}
