class DeathThrows {
  final int death;
  final int life;

  const DeathThrows({
    required this.death,
    required this.life,
  });

  @override
  bool operator ==(Object other) {
    if (other is DeathThrows) {
      return death == other.death && life == other.life;
    }
    return false;
  }

  @override
  int get hashCode => Object.hashAll([death, life]);
}
