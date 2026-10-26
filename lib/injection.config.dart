// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dnd_character_list/data/dnd_su/dnd_su_backgrounds_parser.dart'
    as _i674;
import 'package:dnd_character_list/data/dnd_su/dnd_su_cache.dart' as _i263;
import 'package:dnd_character_list/data/dnd_su/dnd_su_class_parser.dart'
    as _i364;
import 'package:dnd_character_list/data/dnd_su/dnd_su_client.dart' as _i914;
import 'package:dnd_character_list/data/dnd_su/dnd_su_feats_parser.dart'
    as _i487;
import 'package:dnd_character_list/data/dnd_su/dnd_su_spells_parser.dart'
    as _i987;
import 'package:dnd_character_list/data/rules_repository.dart' as _i890;
import 'package:dnd_character_list/data/sp_source.dart' as _i895;
import 'package:dnd_character_list/data/spells_repository.dart' as _i809;
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
    gh.lazySingleton<_i914.DndSuClient>(
      () => _i914.DndSuClient(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i987.DndSuSpellsParser>(() => _i987.DndSuSpellsParser());
    gh.lazySingleton<_i364.DndSuClassParser>(() => _i364.DndSuClassParser());
    gh.lazySingleton<_i674.DndSuBackgroundsParser>(
        () => _i674.DndSuBackgroundsParser());
    gh.lazySingleton<_i487.DndSuFeatsParser>(() => _i487.DndSuFeatsParser());
    gh.lazySingleton<_i263.DndSuCache>(() => _i263.DndSuCache());
    gh.factoryParam<_i571.PlayerCubit, _i747.Player, dynamic>((
      player,
      _,
    ) =>
        _i571.PlayerCubit(
          player,
          gh<_i895.SpSource>(),
        ));
    gh.lazySingleton<_i809.SpellsRepository>(() => _i809.SpellsRepository(
          gh<_i914.DndSuClient>(),
          gh<_i987.DndSuSpellsParser>(),
        ));
    gh.factory<_i716.CreatedCharactersCubit>(
        () => _i716.CreatedCharactersCubit(gh<_i895.SpSource>()));
    gh.lazySingleton<_i890.RulesRepository>(() => _i890.RulesRepository(
          gh<_i914.DndSuClient>(),
          gh<_i263.DndSuCache>(),
          gh<_i364.DndSuClassParser>(),
          gh<_i674.DndSuBackgroundsParser>(),
          gh<_i487.DndSuFeatsParser>(),
        ));
    gh.factoryParam<_i876.LevelUpCubit, _i747.Player, dynamic>((
      player,
      _,
    ) =>
        _i876.LevelUpCubit(
          gh<_i895.SpSource>(),
          gh<_i809.SpellsRepository>(),
          player,
        ));
    gh.factory<_i475.CreateCharacterCubit>(() => _i475.CreateCharacterCubit(
          gh<_i895.SpSource>(),
          gh<_i809.SpellsRepository>(),
        ));
    return this;
  }
}
