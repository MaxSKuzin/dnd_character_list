import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/presentation/common/widgets/separated_column.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:dnd_character_list/presentation/main_screen/widgets/passive_wisdom_widget.dart';
import 'package:dnd_character_list/presentation/main_screen/widgets/stat_widget.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class PlayerStatsList extends StatefulWidget {
  const PlayerStatsList({super.key});

  @override
  State<PlayerStatsList> createState() => _PlayerStatsListState();
}

class _PlayerStatsListState extends State<PlayerStatsList> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = PlayerModel.stats(context);
    final wisdom = stats.firstWhere(
      (e) => e.kind == StatKind.wisdom,
    );
    return FadingEdgeScrollView.fromSingleChildScrollView(
      child: SingleChildScrollView(
        controller: _scrollController,
        child: SeparatedColumn(
          separatorBuilder: (context, index) => const Gap(16),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...stats.map((e) => StatWidget(stat: e)),
            PassiveWisdomWidget(value: 10 + wisdom.bonus),
          ],
        ),
      ),
    );
  }
}
