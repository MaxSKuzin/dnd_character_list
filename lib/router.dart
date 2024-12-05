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
          initial: true,
          children: [
            AdaptiveRoute(
              page: MainRoute.page,
              initial: true,
            ),
            AdaptiveRoute(
              page: BattleRoute.page,
            ),
            AdaptiveRoute(
              page: PersonalityRoute.page,
            ),
          ],
        ),
      ];
}
