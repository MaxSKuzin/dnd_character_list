class ClassAbility {
  final String name;
  final String description;

  const ClassAbility({
    required this.name,
    required this.description,
  });

  factory ClassAbility.fromJson(Map<String, dynamic> json) {
    return ClassAbility(
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}
