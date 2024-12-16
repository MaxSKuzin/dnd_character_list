import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/classes/bard.dart';
import 'package:dnd_character_list/domain/models/personality.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/races/tiefling.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(name: 'MainFlowRoute')
class MainFlow extends StatefulWidget {
  const MainFlow({super.key});

  @override
  State<MainFlow> createState() => _MainFlowState();
}

class _MainFlowState extends State<MainFlow> {
  Player setPlayer() {
    return Player(
      personality: Personality(
        eyesColor: 'Белый',
        hairColor: 'Каштановый',
        skinColor: 'Красный',
        name: 'Фелая',
        age: 24,
        height: 160,
        weight: 50,
        story:
            'Всю свою жизнь я путешествовала с труппой бардов тифлингов. Вечно гонимые мы были вынуждены жить кочевым образом жизни. Из-за такого уклада я привыкла к нападкам от "недемонизированных" и стараюсь избегать неприятностей, но пылкий нрав не дает мне покоя, и переодически мы попали в беду из-за моего острого языка. Но однажды произошло нечто, что перевернуло мою жизнь на до и после. Наша труппа наткнулась на проклятое место и теперь вынуждены бродить по миру в одиночку, в поисках лучших целителей нашего мира. Так и я прибыла на северные земли, чтобы найти исцеление для своих близких, чтобы мы могли продолжить наш и без того тяжелый путь',
      ),
      race: Tiefling.faerun(),
      weapons: [
        Weapon.rapier(),
        Weapon.dagger(),
      ],
      shield: null,
      armor: Armor.leather(),
      strength: 8,
      dexterity: 15,
      constitution: 14,
      intelligence: 8,
      wisdom: 10,
      charisma: 15,
      classes: [
        Bard.level1(
          isMain: true,
          knownSpells: [
            Spell(
              name: 'Злая насмешка',
              distance: 60,
              slot: SpellSlot.conspiracy,
              components: [
                SpellComponent.v(),
              ],
              duration: 0,
              isConcentration: false,
              description: (player, spec) {
                final dice = spec.level >= 5
                    ? '2к4'
                    : spec.level >= 11
                        ? '3к4'
                        : spec.level >= 17
                            ? '4к4'
                            : '1к4';
                return '''
              Вы испускаете на существо, видимое в пределах дистанции, поток оскорблений вперемешку с тонкой магией. Если цель слышит вас (при этом она не обязана вас понимать), она должна преуспеть в спасброске Мудрости, иначе получит урон психической энергией $dice, и следующий бросок атаки до конца своего следующего хода совершит с помехой.
              ''';
              },
            ),
            Spell(
              name: 'Меткий удар',
              distance: 30,
              slot: SpellSlot.conspiracy,
              components: [
                SpellComponent.s(),
              ],
              duration: 1,
              isConcentration: true,
              description: (player, spec) =>
                  'Вы вытягиваете руку и указываете пальцем на цель, находящуюся в пределах дистанции. Ваша магия даёт краткое понимание защиты цели. В своем следующем ходу вы совершаете с преимуществом первый бросок атаки по цели, при условии, что заклинание к тому моменту не окончится.',
            ),
            Spell(
              name: 'Волна грома',
              distance: 15,
              slot: SpellSlot.level1,
              components: [
                SpellComponent.v(),
                SpellComponent.s(),
              ],
              duration: 0,
              isConcentration: false,
              description: (player, spec) => '''
От вас исходит волна громовой силы. Все существа в кубе с длиной ребра 15 футов, исходящего от вас, должны совершить спасбросок Телосложения. При провале существо получает 2к8 урона звуком и отталкивается на 10 футов от вас. При успехе существо получает половину урона и не толкается.

Кроме того, незакреплённые предметы, оказавшиеся полностью в области эффекта, автоматически толкаются на 10 футов от вас эффектом заклинания, и заклинание издает громовой рокот, слышимый на расстоянии 300 футов.
''',
            ),
            Spell(
              name: 'Лечащее слово',
              distance: 60,
              slot: SpellSlot.level1,
              components: [
                SpellComponent.v(),
              ],
              duration: 0,
              isConcentration: false,
              description: (player, spec) {
                final stat = spec.spellKind!;
                final bonus = player.stats[stat]!.bonus;
                return 'Существо на ваш выбор, видимое в пределах дистанции, восстанавливает количество хитов, равное 1к4+$bonus (${stat.name.substring(0, 3)}). Это заклинание не оказывает никакого эффекта на Нежить и Конструктов.';
              },
            ),
          ],
        ),
      ],
      chosenSkills: [
        Skill.acrobatics,
        Skill.fraud,
        Skill.harassment,
        Skill.conviction,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlayerCubit(setPlayer()),
      child: BlocBuilder<PlayerCubit, Player>(
        builder: (context, state) => PlayerModel(
          player: state,
          child: AutoTabsScaffold(
            // appBarBuilder: (context, tabsRouter) => AppBar(
            //   title: const Text('DnD Character List'),
            //   actions: [
            //     IconButton(
            //       icon: const Icon(Icons.arrow_upward),
            //       onPressed: () {
            //         context.read<PlayerCubit>().levelUp<Bard>();
            //       },
            //     ),
            //   ],
            // ),
            bottomNavigationBuilder: (context, tabsRouter) => BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  label: 'Статы',
                  icon: Icon(Icons.format_list_numbered),
                ),
                BottomNavigationBarItem(
                  label: 'Бой',
                  icon: Icon(Icons.sports_mma_outlined),
                ),
                BottomNavigationBarItem(
                  label: 'Спеллы',
                  icon: Icon(Icons.back_hand_outlined),
                ),
                BottomNavigationBarItem(
                  label: 'Перс',
                  icon: Icon(Icons.person),
                ),
              ],
              onTap: tabsRouter.setActiveIndex,
              currentIndex: tabsRouter.activeIndex,
            ),
            routes: const [
              MainRoute(),
              BattleRoute(),
              SpellsRoute(),
              PersonalityRoute(),
            ],
          ),
        ),
      ),
    );
  }
}
