import 'dart:async';

import 'package:flutter/material.dart';

/// Сообщение от мастера или игрока — карточка сверху экрана поверх всего приложения, отдельно от снекбаров:
/// урон или реакция её не вытесняют. Несколько сообщений складываются стопкой, новое сверху. Карточка уходит сама
/// через несколько секунд (длинный текст висит дольше), по крестику, свайпом вверх или по «Ответить».
/// Оформление как у шапок экранов: градиент от фона к основному цвету темы, белая рамка.
/// Общая для приложений игрока и мастера.
///
/// ```dart
/// NoteOverlay.show(context, from: 'Мастер', text: 'Бросьте восприятие', onReply: () => ...);
/// ```
abstract final class NoteOverlay {
  /// Больше карточек не помещается: самые старые убираются.
  static const maxVisible = 3;

  static OverlayEntry? _entry;
  static OverlayState? _overlay;

  /// Показанные сообщения, новое первым. Общие для всех вызовов: несколько сообщений в одном кадре попадают
  /// в одну стопку.
  static final _notes = ValueNotifier<List<_Note>>(const []);

  static void show(BuildContext context, {required String from, required String text, VoidCallback? onReply}) {
    // Оверлей, где висела стопка, мог исчезнуть вместе с приложением (например, в тестах).
    if (_entry != null && !(_overlay?.mounted ?? false)) {
      _entry = null;
      _notes.value = const [];
    }
    if (_entry == null) {
      final overlay = Overlay.maybeOf(context, rootOverlay: true);
      if (overlay == null) return;
      final entry = OverlayEntry(builder: (_) => const _NoteStack());
      _entry = entry;
      _overlay = overlay;
      overlay.insert(entry);
    }
    _notes.value = [_Note(from: from, text: text, onReply: onReply), ..._notes.value].take(maxVisible).toList();
  }

  static void _remove(_Note note) {
    if (!_notes.value.contains(note)) return;
    _notes.value = _notes.value.where((e) => e != note).toList();
    if (_notes.value.isEmpty) {
      _entry?.remove();
      _entry = null;
    }
  }

  /// Сколько висит карточка: на чтение длинного текста нужно больше времени.
  static Duration durationFor(String text) => Duration(seconds: (5 + text.length ~/ 20).clamp(5, 15));
}

class _Note {
  final String from;
  final String text;
  final VoidCallback? onReply;

  /// Ключ карточки: одинаковые сообщения подряд — разные карточки.
  final key = UniqueKey();

  _Note({required this.from, required this.text, this.onReply});
}

class _NoteStack extends StatelessWidget {
  const _NoteStack();

  @override
  Widget build(BuildContext context) {
    // Только сами карточки принимают нажатия, остальной экран работает как обычно.
    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ValueListenableBuilder(
              valueListenable: NoteOverlay._notes,
              builder: (context, notes, _) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final note in notes)
                    _NoteCard(key: note.key, note: note, onClose: () => NoteOverlay._remove(note)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoteCard extends StatefulWidget {
  final _Note note;
  final VoidCallback onClose;

  const _NoteCard({super.key, required this.note, required this.onClose});

  @override
  State<_NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<_NoteCard> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 250))..forward();
  late final Timer _timer;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(NoteOverlay.durationFor(widget.note.text), _close);
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    if (_closing) return;
    _closing = true;
    _timer.cancel();
    await _controller.reverse();
    widget.onClose();
  }

  void _reply() {
    _close();
    widget.note.onReply?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    return SizeTransition(
      sizeFactor: curve,
      alignment: Alignment.bottomCenter,
      child: FadeTransition(
        opacity: curve,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, -0.4), end: Offset.zero).animate(curve),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Dismissible(
              key: widget.note.key,
              direction: DismissDirection.up,
              onDismissed: (_) {
                _closing = true;
                _timer.cancel();
                widget.onClose();
              },
              child: Material(
                type: MaterialType.transparency,
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [colors.surfaceContainerLow, colors.primaryContainer],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.white),
                    ),
                    shadows: const [BoxShadow(color: Colors.black54, blurRadius: 16, offset: Offset(0, 4))],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 4, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.mail_outline, size: 18, color: Colors.white70),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.note.from.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelLarge?.copyWith(letterSpacing: 1.2, color: Colors.white70),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Закрыть',
                              visualDensity: VisualDensity.compact,
                              onPressed: _close,
                              icon: const Icon(Icons.close, size: 18, color: Colors.white70),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Text(
                            widget.note.text,
                            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                          ),
                        ),
                        if (widget.note.onReply != null)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: _reply,
                              style: TextButton.styleFrom(foregroundColor: Colors.white),
                              icon: const Icon(Icons.reply, size: 18),
                              label: const Text('Ответить'),
                            ),
                          )
                        else
                          const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
