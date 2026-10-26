import 'package:dnd_character_list/domain/models/tools/craftsmen_tools.dart';
import 'package:dnd_character_list/domain/models/tools/falcification_kits.dart';
import 'package:dnd_character_list/domain/models/tools/fold_of_lawn.dart';
import 'package:dnd_character_list/domain/models/tools/makeup_kits.dart';
import 'package:dnd_character_list/domain/models/tools/musical_instruments.dart';
import 'package:dnd_character_list/domain/models/tools/navigator_tools.dart';
import 'package:dnd_character_list/domain/models/tools/play_sets.dart';
import 'package:dnd_character_list/domain/models/tools/poisoner_tools.dart';
import 'package:dnd_character_list/domain/models/tools/thieves_tools.dart';
import 'package:dnd_character_list/domain/models/tools/tool.dart';

enum ToolCategory {
  thievesTool,
  playSet,
  navigatorTool,
  poisonerTool,
  musicalInstrument,
  makeupKit,
  falsificationKit,
  foldOfLawn,
  craftsmenTool,
  vehicle;

  List<Tool> get tools => switch (this) {
        ToolCategory.thievesTool => thievesTools,
        ToolCategory.playSet => playSets,
        ToolCategory.navigatorTool => navigatorTools,
        ToolCategory.poisonerTool => poisonerTools,
        ToolCategory.musicalInstrument => musicalInstruments,
        ToolCategory.makeupKit => makeupKits,
        ToolCategory.falsificationKit => falsificationKits,
        ToolCategory.foldOfLawn => foldOfLawnTools,
        ToolCategory.craftsmenTool => craftsmenTools,
        ToolCategory.vehicle => [],
      };
}
