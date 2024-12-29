import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spells_entities/level1/bless.dart';
import 'package:dnd_character_list/domain/models/spell/spells_entities/level1/command.dart';
import 'package:dnd_character_list/domain/models/spell/spells_entities/level1/compelled_duel.dart';
import 'package:dnd_character_list/domain/models/spell/spells_entities/level1/comprehend_languages.dart';
import 'package:dnd_character_list/domain/models/spell/spells_entities/level1/cure_wounds.dart';
import 'package:dnd_character_list/domain/models/spell/spells_entities/level1/detect_evil_and_good.dart';
import 'package:dnd_character_list/domain/models/spell/spells_entities/level1/detect_magic.dart';
import 'package:dnd_character_list/domain/models/spell/spells_entities/level1/detect_poison_and_disease.dart';
import 'package:dnd_character_list/domain/models/spell/spells_entities/level1/divine_favor.dart';
import 'package:dnd_character_list/domain/models/spell/spells_entities/level1/healing_word.dart';
import 'package:dnd_character_list/domain/models/spell/spells_entities/level1/heroism.dart';
import 'package:dnd_character_list/domain/models/spell/spells_entities/level1/protection_from_evil_and_good.dart';
import 'package:dnd_character_list/domain/models/spell/spells_entities/level1/purify_food_and_drink.dart';
import 'package:dnd_character_list/domain/models/spell/spells_entities/level1/searing_smite.dart';
import 'package:dnd_character_list/domain/models/spell/spells_entities/level1/shield_of_faith.dart';
import 'package:dnd_character_list/domain/models/spell/spells_entities/level1/speak_with_animals.dart';
import 'package:dnd_character_list/domain/models/spell/spells_entities/level1/thunder_wave.dart';
import 'package:dnd_character_list/domain/models/spell/spells_entities/level1/thunderous_smite.dart';
import 'package:dnd_character_list/domain/models/spell/spells_entities/level1/wrathful_smite.dart';

final spellsLevel1 = <Spell>[
  Bless(),
  Command(),
  CompelledDuel(),
  ComprehendLanguages(),
  CureWounds(),
  DetectEvilAndGood(),
  DetectMagic(),
  DetectPoisonAndDisease(),
  DivineFavor(),
  HealingWord(),
  Heroism(),
  ProtectionFromEvilAndGood(),
  PurifyFoodAndDrink(),
  SearingSmite(),
  ShieldOfFaith(),
  SpeakWithAnimals(),
  ThunderWave(),
  ThunderousSmite(),
  WrathfulSmite(),
];
