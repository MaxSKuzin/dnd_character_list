class Shield {
  final String name;
  final int defense;
  final int weight;

  const Shield(
    {
    required this.name,
    required this.defense,
    required this.weight, 
  });

  factory Shield.regular() => const Shield(
        name: 'Щит',
        defense: 2,
        weight: 6,
      );

  @override
  operator ==(Object other) =>
      other is Shield && other.name == name && other.defense == defense && other.weight == weight;

  @override
  int get hashCode => Object.hashAll([
        name,
        defense,
        weight,
      ]);
}
