import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

/// Аватары персонажей в `<Documents>/avatars/`. В персонаже хранится только имя файла: путь к папке приложения
/// на iOS меняется при обновлении. Аватары остаются на устройстве и мастеру не передаются.
@lazySingleton
class AvatarStore {
  final Future<Directory> Function() _documents;

  AvatarStore({@ignoreParam Future<Directory> Function()? documents})
      : _documents = documents ?? getApplicationDocumentsDirectory;

  late final Future<Directory> _directory = () async {
    final directory = Directory('${(await _documents()).path}/avatars');
    await directory.create(recursive: true);
    return directory;
  }();

  /// Копирует выбранное изображение и возвращает имя файла для `Personality.avatar`.
  Future<String> save(String sourcePath) async {
    final extension = sourcePath.contains('.') ? sourcePath.substring(sourcePath.lastIndexOf('.')) : '.jpg';
    final name = 'avatar_${DateTime.now().microsecondsSinceEpoch}$extension';
    await File(sourcePath).copy('${(await _directory).path}/$name');
    return name;
  }

  Future<File?> file(String? name) async {
    if (name == null) return null;
    final file = File('${(await _directory).path}/$name');
    return await file.exists() ? file : null;
  }

  Future<void> delete(String? name) async => (await file(name))?.delete();
}
