/// Реакция для настроения за столом: игрок кидает её другому игроку или мастеру, мастер — игроку. У получателя
/// показывается анимация, на бой не влияет.
enum Reaction {
  flowers('💐', 'дарит вам букет'),
  poop('💩', 'кидает в вас какашкой'),
  banana('🍌', 'угощает вас бананом'),
  strawberry('🍓', 'угощает вас клубникой'),
  darkMoon('🌚', 'показывает вам тёмную луну'),
  peach('🍑', 'кидает в вас персиком');

  const Reaction(this.emoji, this.phrase);

  final String emoji;

  /// Продолжение фразы после имени отправителя: «Лира дарит вам букет».
  final String phrase;

  static Reaction? fromName(Object? name) => values.where((e) => e.name == name).firstOrNull;
}

/// Другой подключённый игрок сессии: кому можно отправить реакцию.
class SessionMate {
  final String id;
  final String name;

  const SessionMate({required this.id, required this.name});

  @override
  bool operator ==(Object other) => other is SessionMate && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory SessionMate.fromJson(Map<String, dynamic> json) => SessionMate(id: json['id'], name: json['name']);
}
