import 'dart:io';

import 'package:dnd_character_list/data/avatar_store.dart';
import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/personality.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

/// Круглый аватар персонажа из `AvatarStore` в выбранном положении; без аватара — первая буква имени.
class CharacterAvatar extends StatefulWidget {
  final String? avatar;
  final AvatarFrame frame;
  final String name;
  final double size;

  const CharacterAvatar({
    super.key,
    required this.avatar,
    this.frame = AvatarFrame.initial,
    required this.name,
    this.size = 88,
  });

  @override
  State<CharacterAvatar> createState() => _CharacterAvatarState();
}

class _CharacterAvatarState extends State<CharacterAvatar> {
  late Future<File?> _file = getIt<AvatarStore>().file(widget.avatar);

  @override
  void didUpdateWidget(CharacterAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avatar != widget.avatar) _file = getIt<AvatarStore>().file(widget.avatar);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.customColors?.cardColor,
        border: Border.all(color: Colors.white, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: FutureBuilder(
        future: _file,
        builder: (context, snapshot) {
          final file = snapshot.data;
          if (file != null) return FramedAvatarImage(file: file, frame: widget.frame);
          return Center(
            child: Text(
              widget.name.isEmpty ? '?' : widget.name.characters.first.toUpperCase(),
              style: TextStyle(fontSize: widget.size * 0.42, fontWeight: FontWeight.w700),
            ),
          );
        },
      ),
    );
  }
}

/// Фотография в квадрате в положении [frame]: заполняет квадрат от левого верхнего угла, как в редакторе,
/// затем масштабируется и сдвигается. Квадрат — по меньшей стороне доступного места.
class FramedAvatarImage extends StatelessWidget {
  final File file;
  final AvatarFrame frame;

  const FramedAvatarImage({super.key, required this.file, required this.frame});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.biggest.shortestSide;
        return Center(
          child: ClipRect(
            child: SizedBox.square(
              dimension: side,
              child: Transform(
                transform: Matrix4.identity()
                  ..translateByDouble(frame.dx * side, frame.dy * side, 0, 1)
                  ..scaleByDouble(frame.scale, frame.scale, 1, 1),
                child: FittedBox(
                  fit: BoxFit.cover,
                  alignment: Alignment.topLeft,
                  clipBehavior: Clip.none,
                  child: Image.file(file, key: ValueKey(file.path)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Пункт меню аватара.
enum _AvatarAction { gallery, camera, frame, remove }

/// Аватар: выбрать из галереи, сфотографировать (где есть камера), изменить положение или убрать. Новый файл
/// копируется в папку приложения, прежний удаляется. После выбора фотографии открывается редактор положения.
Future<void> changeAvatar(BuildContext context) async {
  final cubit = context.read<PlayerCubit>();
  final picker = ImagePicker();
  final store = getIt<AvatarStore>();
  final personality = cubit.state.personality;
  final current = personality.avatar;
  final currentFile = await store.file(current);
  if (!context.mounted) return;
  final action = await showModalBottomSheet<_AvatarAction>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Выбрать из галереи'),
            onTap: () => Navigator.pop(context, _AvatarAction.gallery),
          ),
          if (picker.supportsImageSource(ImageSource.camera))
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Сделать фото'),
              onTap: () => Navigator.pop(context, _AvatarAction.camera),
            ),
          if (currentFile != null)
            ListTile(
              leading: const Icon(Icons.crop_free),
              title: const Text('Изменить положение'),
              onTap: () => Navigator.pop(context, _AvatarAction.frame),
            ),
          if (current != null)
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Убрать аватар'),
              onTap: () => Navigator.pop(context, _AvatarAction.remove),
            ),
        ],
      ),
    ),
  );
  if (action == null || !context.mounted) return;
  switch (action) {
    case _AvatarAction.remove:
      await cubit.setAvatar(null);
      await store.delete(current);
      return;
    case _AvatarAction.frame:
      final frame = await AvatarEditorScreen.show(context, file: currentFile!, frame: personality.avatarFrame);
      if (frame != null) await cubit.setAvatar(current, frame: frame);
      return;
    case _AvatarAction.gallery || _AvatarAction.camera:
      break;
  }
  final source = action == _AvatarAction.camera ? ImageSource.camera : ImageSource.gallery;
  final XFile? image;
  try {
    image = await picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Не удалось открыть изображение: $e')));
    }
    return;
  }
  if (image == null || !context.mounted) return;
  final frame = await AvatarEditorScreen.show(context, file: File(image.path));
  if (frame == null) return;
  final name = await store.save(image.path);
  await cubit.setAvatar(name, frame: frame);
  await store.delete(current);
}

/// Редактор положения фотографии в круге: двигать и увеличивать пальцами. Возвращает положение
/// или `null`, если пользователь отменил.
class AvatarEditorScreen extends StatefulWidget {
  final File file;

  /// Текущее положение; `null` — новая фотография, она ставится по центру.
  final AvatarFrame? frame;

  const AvatarEditorScreen({super.key, required this.file, this.frame});

  static Future<AvatarFrame?> show(BuildContext context, {required File file, AvatarFrame? frame}) =>
      Navigator.of(context).push<AvatarFrame>(
        MaterialPageRoute(fullscreenDialog: true, builder: (_) => AvatarEditorScreen(file: file, frame: frame)),
      );

  @override
  State<AvatarEditorScreen> createState() => _AvatarEditorScreenState();
}

class _AvatarEditorScreenState extends State<AvatarEditorScreen> {
  final _controller = TransformationController();

  /// Размер фотографии: по нему фотография заполняет круг, а пальцами её можно сдвигать до краёв.
  late final Future<Size> _imageSize = () async {
    final image = await decodeImageFromList(await widget.file.readAsBytes());
    final size = Size(image.width.toDouble(), image.height.toDouble());
    image.dispose();
    return size;
  }();

  double? _side;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Фотография, заполняющая квадрат [side] от левого верхнего угла.
  static Size _cover(Size image, double side) {
    final scale = side / image.shortestSide;
    return Size(image.width * scale, image.height * scale);
  }

  void _reset(Size image, double side, {AvatarFrame? frame}) {
    if (frame != null) {
      _controller.value = Matrix4.identity()
        ..translateByDouble(frame.dx * side, frame.dy * side, 0, 1)
        ..scaleByDouble(frame.scale, frame.scale, 1, 1);
      return;
    }
    // По центру фотографии.
    final cover = _cover(image, side);
    _controller.value = Matrix4.identity()
      ..translateByDouble(-(cover.width - side) / 2, -(cover.height - side) / 2, 0, 1);
  }

  AvatarFrame get _frame {
    final matrix = _controller.value;
    final side = _side!;
    return AvatarFrame(
      scale: matrix.getMaxScaleOnAxis(),
      dx: matrix.storage[12] / side,
      dy: matrix.storage[13] / side,
    );
  }

  @override
  Widget build(BuildContext context) {
    final side = (MediaQuery.sizeOf(context).width - 32).clamp(120.0, 420.0);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Положение аватара'),
        actions: [
          TextButton(
            onPressed: _side == null ? null : () => Navigator.pop(context, _frame),
            child: const Text('Готово'),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _imageSize,
        builder: (context, snapshot) {
          final image = snapshot.data;
          if (snapshot.hasError) return const Center(child: Text('Не удалось открыть фотографию.'));
          if (image == null) return const Center(child: CircularProgressIndicator());
          if (_side != side) {
            // Положение в долях стороны круга не зависит от размера: при повороте экрана оно сохраняется.
            final frame = _side == null ? widget.frame : _frame;
            _side = side;
            // Контроллер нельзя менять во время построения — после кадра.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() => _reset(image, side, frame: frame));
            });
          }
          final cover = _cover(image, side);
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text('Двигайте и увеличивайте фотографию, чтобы выбрать, что видно в круге.',
                      textAlign: TextAlign.center),
                ),
                SizedBox.square(
                  dimension: side,
                  child: Stack(
                    children: [
                      ClipRect(
                        child: InteractiveViewer(
                          transformationController: _controller,
                          constrained: false,
                          minScale: 1,
                          maxScale: 6,
                          child: Image.file(widget.file, width: cover.width, height: cover.height, fit: BoxFit.fill),
                        ),
                      ),
                      const IgnorePointer(child: CustomPaint(size: Size.infinite, painter: _CircleMaskPainter())),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _reset(image, side)),
                  icon: const Icon(Icons.center_focus_strong),
                  label: const Text('По центру'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Затемнение вокруг круга аватара и рамка круга.
class _CircleMaskPainter extends CustomPainter {
  const _CircleMaskPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final circle = Path()..addOval(rect.deflate(1));
    final mask = Path.combine(PathOperation.difference, Path()..addRect(rect), circle);
    canvas.drawPath(mask, Paint()..color = Colors.black.withValues(alpha: 0.55));
    canvas.drawPath(
        circle,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(_CircleMaskPainter oldDelegate) => false;
}
