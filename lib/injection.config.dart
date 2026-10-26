// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dnd_character_list/data/avatar_store.dart' as _i338;
import 'package:dnd_character_list/data/rules_repository.dart' as _i890;
import 'package:dnd_character_list/data/session/session_source.dart' as _i359;
import 'package:dnd_character_list/data/sp_source.dart' as _i895;
import 'package:dnd_character_list/data/spells_repository.dart' as _i809;
import 'package:dnd_character_list/data/ttg/ttg_backgrounds_mapper.dart'
    as _i942;
import 'package:dnd_character_list/data/ttg/ttg_cache.dart' as _i841;
import 'package:dnd_character_list/data/ttg/ttg_class_mapper.dart' as _i153;
import 'package:dnd_character_list/data/ttg/ttg_client.dart' as _i595;
import 'package:dnd_character_list/data/ttg/ttg_equipment_mapper.dart' as _i116;
import 'package:dnd_character_list/data/ttg/ttg_feats_mapper.dart' as _i315;
import 'package:dnd_character_list/data/ttg/ttg_options_mapper.dart' as _i626;
import 'package:dnd_character_list/data/ttg/ttg_spells_mapper.dart' as _i594;
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
    await gh.singletonAsync<_i359.SessionSource>(
      () => _i359.SessionSource.init(),
      preResolve: true,
    );
    gh.lazySingleton<_i626.TtgOptionsMapper>(() => _i626.TtgOptionsMapper());
    gh.lazySingleton<_i153.TtgClassMapper>(() => _i153.TtgClassMapper());
    gh.lazySingleton<_i594.TtgSpellsMapper>(() => _i594.TtgSpellsMapper());
    gh.lazySingleton<_i841.TtgCache>(() => _i841.TtgCache());
    gh.lazySingleton<_i942.TtgBackgroundsMapper>(
        () => _i942.TtgBackgroundsMapper());
    gh.lazySingleton<_i116.TtgEquipmentMapper>(
        () => _i116.TtgEquipmentMapper());
    gh.lazySingleton<_i315.TtgFeatsMapper>(() => _i315.TtgFeatsMapper());
    gh.lazySingleton<_i595.TtgClient>(
      () => _i595.TtgClient(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i338.AvatarStore>(() => _i338.AvatarStore());
    gh.factoryParam<_i571.PlayerCubit, _i747.Player, dynamic>((
      player,
      _,
    ) =>
        _i571.PlayerCubit(
          player,
          gh<_i895.SpSource>(),
        ));
    gh.lazySingleton<_i809.SpellsRepository>(() => _i809.SpellsRepository(
          gh<_i595.TtgClient>(),
          gh<_i594.TtgSpellsMapper>(),
        ));
    gh.factory<_i716.CreatedCharactersCubit>(
        () => _i716.CreatedCharactersCubit(gh<_i895.SpSource>()));
    gh.factoryParam<_i876.LevelUpCubit, _i747.Player, dynamic>((
      player,
      _,
    ) =>
        _i876.LevelUpCubit(
          gh<_i895.SpSource>(),
          gh<_i809.SpellsRepository>(),
          player,
        ));
    gh.lazySingleton<_i890.RulesRepository>(() => _i890.RulesRepository(
          gh<_i595.TtgClient>(),
          gh<_i841.TtgCache>(),
          gh<_i153.TtgClassMapper>(),
          gh<_i942.TtgBackgroundsMapper>(),
          gh<_i315.TtgFeatsMapper>(),
          gh<_i116.TtgEquipmentMapper>(),
          gh<_i626.TtgOptionsMapper>(),
        ));
    gh.factory<_i475.CreateCharacterCubit>(() => _i475.CreateCharacterCubit(
          gh<_i895.SpSource>(),
          gh<_i809.SpellsRepository>(),
        ));
    return this;
  }
}
