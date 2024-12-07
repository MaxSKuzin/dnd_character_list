class Peculiarity {
  final String name;
  final String description;

  const Peculiarity({
    required this.name,
    required this.description,
  });

  @override
  bool operator ==(Object other) {
    if (other is Peculiarity) {
      return name == other.name && description == other.description;
    }
    return false;
  }

  @override
  int get hashCode => Object.hashAll([name, description]);
}
