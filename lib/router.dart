import 'package:auto_route/auto_route.dart';

import 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  AppRouter({
    super.navigatorKey,
  });

  @override
  List<AutoRoute> get routes => [
        AdaptiveRoute(
          page: MainFlowRoute.page,
          children: [
            AdaptiveRoute(
              page: MainRoute.page,
              initial: true,
            ),
            AdaptiveRoute(
              page: BattleRoute.page,
            ),
            AdaptiveRoute(
              page: SpellsRoute.page,
            ),
            AdaptiveRoute(
              page: PersonalityRoute.page,
            ),
            AdaptiveRoute(
              page: InventoryRoute.page,
            ),
          ],
        ),
        AdaptiveRoute(
          page: CreateCharacterRoute.page,
          children: [
            AdaptiveRoute(
              page: SelectRaceRoute.page,
              initial: true,
            ),
            AdaptiveRoute(
              page: FillStatsRoute.page,
            ),
            AdaptiveRoute(
              page: SelectClassRoute.page,
            ),
            AdaptiveRoute(
              page: SelectSpellsRoute.page,
            ),
            AdaptiveRoute(
              page: SelectSkillsRoute.page,
            ),
            AdaptiveRoute(
              page: StartingEquipmentRoute.page,
            ),
            AdaptiveRoute(
              page: SetPersonalityRoute.page,
            ),
            AdaptiveRoute(
              page: SelectBackgroundRoute.page,
            ),
            AdaptiveRoute(
              page: ProficienciesRoute.page,
            ),
            AdaptiveRoute(
              page: SelectSubclassRoute.page,
            ),
            AdaptiveRoute(
              page: SelectOptionRoute.page,
            ),
            AdaptiveRoute(
              page: SelectFightingStyleRoute.page,
            ),
            AdaptiveRoute(
              page: SelectClassOptionsRoute.page,
            ),
          ],
        ),
        AdaptiveRoute(
          page: InventoryAddItemRoute.page,
        ),
        AdaptiveRoute(
          page: ItemCatalogRoute.page,
        ),
        AdaptiveRoute(
          initial: true,
          page: SelectCharacterRoute.page,
        ),
        AdaptiveRoute(
          page: LevelUpFlowRoute.page,
          children: [
            AdaptiveRoute(
              page: LevelUpClassRoute.page,
              initial: true,
            ),
            AdaptiveRoute(
              page: SelectSpellsRoute.page,
            ),
            AdaptiveRoute(
              page: SelectSkillsRoute.page,
            ),
            AdaptiveRoute(
              page: SelectSubclassRoute.page,
            ),
            AdaptiveRoute(
              page: ReplaceSpellRoute.page,
            ),
            AdaptiveRoute(
              page: AbilityScoreImprovementRoute.page,
            ),
            AdaptiveRoute(
              page: ProficienciesRoute.page,
            ),
            AdaptiveRoute(
              page: FillStatsRoute.page,
            ),
            AdaptiveRoute(
              page: SelectFightingStyleRoute.page,
            ),
            AdaptiveRoute(
              page: SelectOptionRoute.page,
            ),
            AdaptiveRoute(
              page: SelectClassOptionsRoute.page,
            ),
          ],
        ),
      ];
}
