class Habit {
  final String id;
  final String name;
  final String icon; // Icon name or emoji
  final bool isActive;

  Habit({
    required this.id,
    required this.name,
    required this.icon,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'isActive': isActive,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Habit copyWith({
    String? id,
    String? name,
    String? icon,
    bool? isActive,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
    );
  }
}

