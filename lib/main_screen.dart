import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/models/barbarian.dart';
import 'package:dnd_character_list/domain/models/bard.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/stat.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@RoutePage()
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var player = Player(
    constitution: Stat(value: 15),
    classes: [
      Bard(
        level: 1,
        isMain: true,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SeparatedColumn(
          children: [
            FilledButton(
              onPressed: () {
                setState(() {
                  player = Player(
                    constitution: Stat(value: 15),
                    classes: [
                      Bard(
                        level: 1,
                        isMain: true,
                      ),
                    ],
                  );
                });
              },
              child: const Text('Сбросить'),
            ),
            CustomText('Классы: ${player.classes.map((e) => '${e.name}:${e.level}').join(', ')}'),
            CustomText('Телосложение: ${player.constitution.value} ${player.constitution.bonus}'),
            CustomText('Макс. Хиты: ${player.maxHits}'),
            CustomText('Хиты: ${player.currentHits}'),
            CustomText('Кость хитов: ${player.hitDices}'),
            const SizedBox(),
            FilledButton(
              onPressed: () {
                setState(() {
                  player.levelUp<Bard>();
                });
              },
              child: const Text('Поднять уровень барда'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  player.levelUp<Barbarian>();
                });
              },
              child: const Text('Поднять уровень варвара'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  player.addClass(
                    Barbarian(
                      level: 1,
                      isMain: false,
                    ),
                  );
                });
              },
              child: const Text('Добавить класс варвара'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  player.takeDamage(7);
                });
              },
              child: const Text('7 урона'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  player.restoreHealthPart();
                });
              },
              child: const Text('Короткий отдых'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  player.restoreHealthFull();
                });
              },
              child: const Text('Долгий отдых'),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomText extends StatelessWidget {
  final String text;
  const CustomText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class SeparatedColumn extends StatelessWidget {
  final List<Widget> children;

  const SeparatedColumn({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < children.length * 2; i++)
          i.isEven
              ? const SizedBox(
                  height: 10,
                )
              : children[i ~/ 2]
      ],
    );
  }
}

@Injectable()
class A {}
