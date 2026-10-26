import 'dart:math';

import 'package:dnd_session/src/models/reaction.dart';
import 'package:flutter/material.dart';

/// Анимация реакции поверх всего приложения: реакция прилетает, «срабатывает» и исчезает, посередине видно, от кого.
/// Нажатия не перехватывает. Общая для приложений игрока и мастера.
///
/// Какашка, банан, клубника и персик прилетают из-за правого верхнего угла по дуге, вращаясь; букет и тёмная луна
/// поднимаются снизу. Затем какашка шлёпается с брызгами, букет рассыпается цветами, луна — звёздами,
/// остальные — своими копиями.
abstract final class ReactionOverlay {
  static const duration = Duration(milliseconds: 2200);

  static void show(BuildContext context, {required Reaction reaction, required String from}) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ReactionAnimation(reaction: reaction, from: from, onDone: () => entry.remove()),
    );
    overlay.insert(entry);
  }
}

class _ReactionAnimation extends StatefulWidget {
  final Reaction reaction;
  final String from;
  final VoidCallback onDone;

  const _ReactionAnimation({required this.reaction, required this.from, required this.onDone});

  @override
  State<_ReactionAnimation> createState() => _ReactionAnimationState();
}

class _ReactionAnimationState extends State<_ReactionAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Отрезки анимации: полёт, срабатывание, исчезновение.
  static const _flight = Interval(0, 0.35, curve: Curves.easeIn);
  static const _burst = Interval(0.35, 0.85, curve: Curves.easeOut);
  static const _fade = Interval(0.8, 1, curve: Curves.easeIn);

  bool get _rises => widget.reaction == Reaction.flowers || widget.reaction == Reaction.darkMoon;

  /// Небольшой разброс у каждой реакции: несколько подряд ложатся друг на друга, но не в одну точку.
  /// Место попадания — сдвиг в долях экрана, старт — точка на краю, изгиб дуги, вращение и покачивание.
  final _random = Random();
  late final _targetShift = Offset((_random.nextDouble() - 0.5) * 0.44, (_random.nextDouble() - 0.5) * 0.3);
  late final _startAlong = _random.nextDouble();
  late final _arc = 0.6 + _random.nextDouble() * 0.9;
  late final _spin = (3 + _random.nextDouble() * 2) * pi * (_random.nextBool() ? 1 : -1);
  late final _sway = (16 + _random.nextDouble() * 20) * (_random.nextBool() ? 1 : -1);
  late final _tilt = (_random.nextDouble() - 0.5) * 0.5;

  /// Частицы после срабатывания: направление, скорость и значок. Постоянные, чтобы не прыгали между кадрами.
  late final List<({double angle, double speed, String? emoji})> _particles = () {
    final random = Random();
    final emojis = switch (widget.reaction) {
      Reaction.flowers => ['🌸', '🌷', '🌹', '🌼', '🌺'],
      Reaction.darkMoon => ['✨', '⭐'],
      // Брызги какашки рисуются кружками.
      Reaction.poop => <String?>[null],
      final reaction => [reaction.emoji],
    };
    return [
      for (var i = 0; i < 12; i++)
        (
          angle: widget.reaction == Reaction.poop ? i * pi / 6 : -pi / 2 + (random.nextDouble() - 0.5) * pi * 1.5,
          speed: 110 + random.nextDouble() * 150,
          emoji: emojis[i % emojis.length],
        ),
    ];
  }();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: ReactionOverlay.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onDone();
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final target = Offset(size.width * (0.5 + _targetShift.dx), size.height * (0.42 + _targetShift.dy));
          // Брошенное — из-за верхнего края правее середины или из-за правого края выше середины;
          // поднимающееся — из-за нижнего края.
          final start = _rises
              ? Offset(size.width * (0.2 + 0.6 * _startAlong), size.height + 80)
              : (_startAlong < 0.5
                    ? Offset(size.width * (0.55 + _startAlong), -60)
                    : Offset(size.width + 60, size.height * (_startAlong - 0.5) * 0.8));
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;
              final flight = _flight.transform(t);
              final burst = _burst.transform(t);
              final opacity = 1 - _fade.transform(t);
              final landed = t >= _burst.begin;
              // Брошенное летит по дуге с подлётом сверху, поднимающееся — покачиваясь.
              final position = _rises
                  ? Offset.lerp(start, target, Curves.easeOutCubic.transform(flight))! +
                        Offset(sin(flight * pi * 3) * _sway * (1 - flight), 0)
                  : Offset(
                      start.dx + (target.dx - start.dx) * flight,
                      start.dy + (target.dy - start.dy) * pow(sin(flight * pi / 2), _arc),
                    );
              final isPoop = widget.reaction == Reaction.poop;
              return Stack(
                children: [
                  if (landed)
                    for (final particle in _particles) _particle(particle, target, burst, opacity, gravity: !isPoop),
                  _emoji(
                    widget.reaction.emoji,
                    position,
                    size: 96,
                    opacity: opacity,
                    // Брошенное вращается в полёте и ложится с лёгким наклоном.
                    angle: _rises ? 0 : (landed ? _tilt : flight * _spin + _tilt * flight),
                    // Какашка сплющивается, остальные пульсируют.
                    scaleX: landed ? (isPoop ? 1 + 0.6 * burst : 1 + 0.2 * sin(burst * pi)) : 1,
                    scaleY: landed ? (isPoop ? 1 - 0.35 * burst : 1 + 0.2 * sin(burst * pi)) : 1,
                  ),
                  if (landed)
                    // Подпись под местом попадания: у нескольких реакций подряд они не накрывают друг друга целиком.
                    Positioned(
                      left: 16,
                      right: 16,
                      top: target.dy + 64,
                      child: Opacity(
                        opacity: opacity * burst,
                        child: Text(
                          '${widget.from} ${widget.reaction.phrase}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.none,
                            shadows: const [Shadow(blurRadius: 8, color: Colors.black)],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// Частица разлетается от места срабатывания; [gravity] — потом падает вниз.
  Widget _particle(
    ({double angle, double speed, String? emoji}) particle,
    Offset center,
    double progress,
    double opacity, {
    required bool gravity,
  }) {
    final offset =
        Offset(cos(particle.angle), sin(particle.angle)) * (40 + particle.speed * progress) +
        (gravity ? Offset(0, 240 * progress * progress) : Offset.zero);
    final emoji = particle.emoji;
    if (emoji == null) {
      final position = center + offset;
      return Positioned(
        left: position.dx - 7,
        top: position.dy - 7,
        child: Opacity(
          opacity: opacity * (1 - progress * 0.3),
          child: Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(color: Color(0xFF7B4A2A), shape: BoxShape.circle),
          ),
        ),
      );
    }
    return _emoji(
      emoji,
      center + offset,
      size: 30,
      opacity: opacity,
      angle: progress * pi * 2 * (particle.speed > 185 ? 1 : -1),
    );
  }

  Widget _emoji(
    String emoji,
    Offset center, {
    required double size,
    double opacity = 1,
    double angle = 0,
    double scaleX = 1,
    double scaleY = 1,
  }) {
    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: angle,
          child: Transform.scale(
            scaleX: scaleX,
            scaleY: scaleY,
            child: Text(
              emoji,
              style: TextStyle(fontSize: size, decoration: TextDecoration.none),
            ),
          ),
        ),
      ),
    );
  }
}
