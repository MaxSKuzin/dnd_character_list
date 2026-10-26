import 'package:dnd_character_list/data/ttg/ttg_text.dart';
import 'package:dnd_character_list/domain/models/metamagic.dart';
import 'package:injectable/injectable.dart';

/// Переводит ответ `POST /options/<slug>` (особенности классов) в модели приложения.
@lazySingleton
class TtgOptionsMapper {
  /// [link] — ссылка из списка (`/options/careful_spell`): в ответе по варианту её нет.
  Metamagic metamagic(String link, Map<String, dynamic> json) => Metamagic(
        link: TtgText.normalizeLink(link),
        name: TtgText.names(json['name']).$1,
        source: (json['source'] as Map?)?['name'],
        descriptionHtml: TtgText.html(json['description']),
      );
}
