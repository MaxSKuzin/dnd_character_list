import 'package:dnd_character_list/domain/models/armor_kind.dart';
import 'package:dnd_character_list/domain/models/combat.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Класс брони на экране боя; нажатие показывает, из чего он складывается.
class ProtectionWidget extends StatelessWidget {
  const ProtectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final protection = PlayerModel.protection(context).toString();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showDialog(
        context: context,
        builder: (_) => Dialog(
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: _ArmorClassDialog(player: PlayerModel.getPlayer(context)),
        ),
      ),
      child: _shield(context, protection),
    );
  }

  Widget _shield(BuildContext context, String protection) {
    return CustomPaint(
      painter: ShieldPainter(),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: CustomPaint(
          painter: ShieldPainter(
            color: context.customColors?.cardColor,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  protection,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  'КЛАСС\nБРОНИ',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(4)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Слагаемые класса брони с пояснениями: «Кожаный 11 — лёгкий доспех», «Ловкость +3 — модификатор».
class _ArmorClassDialog extends StatelessWidget {
  final Player player;

  const _ArmorClassDialog({required this.player});

  /// Откуда берётся слагаемое. Названия слагаемых задают [ArmorClass.parts] классов и [PlayerCombat.armorClass].
  String? _explain(String name) {
    final armor = player.armor;
    final shield = player.shield;
    if (armor != null && name == armor.name) return '${armor.kind.localizedName}: базовый КД доспеха';
    if (shield != null && name == shield.name) return 'Щит в руке';
    return switch (name) {
      'Без доспеха' => 'Базовый КД без доспеха',
      'Защита без доспехов' => player.armorClass.parts.any((e) => e.$1 == 'Мудрость')
          ? 'Умение монаха: без доспеха и щита 10 + Ловкость + Мудрость'
          : 'Умение варвара: без доспеха 10 + Ловкость + Телосложение, щит разрешён',
      'Драконья чешуя' => '«Драконья устойчивость» чародея: без доспеха 13 + Ловкость',
      'Ловкость' => armor?.kind == ArmorKind.medium
          ? 'Модификатор Ловкости, в среднем доспехе не больше +2'
          : 'Модификатор Ловкости',
      'Мудрость' => 'Модификатор Мудрости',
      'Телосложение' => 'Модификатор Телосложения',
      'Стиль «Оборона»' => 'Боевой стиль: +1, пока надет доспех',
      _ => null,
    };
  }

  static String _signed(int value) => value >= 0 ? '+$value' : '−${-value}';

  @override
  Widget build(BuildContext context) {
    final armorClass = player.armorClass;
    final warnings = [
      if (!player.isArmorProficient)
        'Нет владения доспехом: помеха на проверки, спасброски и атаки по Силе и Ловкости.',
      if (!player.isShieldProficient) 'Нет владения щитом: помеха на проверки, спасброски и атаки по Силе и Ловкости.',
      if (player.armor?.stealthDisadvantage ?? false) 'Доспех даёт помеху на проверки Ловкости (Скрытность).',
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Класс брони ${armorClass.value}',
            textAlign: TextAlign.center,
            style: context.theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 20),
          ),
          const Gap(16),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final (index, (name, value)) in armorClass.parts.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              if (_explain(name) case final explanation?)
                                Text(explanation, style: context.theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                        const Gap(12),
                        // Первое слагаемое — основа, остальные — прибавки.
                        Text(index == 0 ? '$value' : _signed(value),
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                const Divider(),
                Text(
                  '${armorClass.parts.indexed.map((e) => e.$1 == 0 ? '${e.$2.$2}' : _signed(e.$2.$2)).join(' ')} = ${armorClass.value}',
                  textAlign: TextAlign.end,
                ),
                if (player.classes.length > 1) ...[
                  const Gap(12),
                  Text('Из способов защиты классов берётся лучший.', style: context.theme.textTheme.bodySmall),
                ],
                for (final warning in warnings) ...[
                  const Gap(12),
                  Text(warning, style: const TextStyle(color: Colors.orangeAccent, fontSize: 12)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShieldPainter extends CustomPainter {
  final Color? color;

  ShieldPainter({
    this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    final height = size.height;
    final width = size.width;

    const topRadius = 16.0;

    // top border
    path.moveTo(0, height / 5);
    path.arcToPoint(
      Offset(width / 7, height / 12),
      radius: const Radius.circular(topRadius),
      clockwise: false,
    );
    path.lineTo(width / 2, 0);
    path.lineTo(width * 6 / 7, height / 12);
    path.arcToPoint(
      Offset(width, height / 5),
      radius: const Radius.circular(topRadius),
      clockwise: false,
    );

    // right border
    path.lineTo(width, height * 2 / 5);
    path.arcToPoint(
      Offset(width / 2, height),
      radius: const Radius.circular(80),
    );

    // left border
    path.arcToPoint(
      Offset(0, height * 2 / 5),
      radius: const Radius.circular(80),
    );
    path.close();

    canvas.drawPath(path, paint);
    if (color != null) {
      final Paint paint = Paint()
        ..color = color!
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(ShieldPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
