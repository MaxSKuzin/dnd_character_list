sealed class SpellComponent {
  final String name;

  const SpellComponent({required this.name});

  factory SpellComponent.v() => const VerbalComponent();

  factory SpellComponent.s() => const SomaticComponent();

  factory SpellComponent.m(String description) => MaterialComponent(
        description: description,
      );
}

final class VerbalComponent extends SpellComponent {
  const VerbalComponent() : super(name: 'В');

  @override
  String toString() => name;
}

final class SomaticComponent extends SpellComponent {
  const SomaticComponent() : super(name: 'С');

  @override
  String toString() => name;
}

final class MaterialComponent extends SpellComponent {
  final String description;

  const MaterialComponent({required this.description}) : super(name: 'М ($description)');

  @override
  String toString() => name;
}
