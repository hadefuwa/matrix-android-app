class Goal {
  final String id;
  final String name;
  final double targetAmount;
  final double baseRewardPerDay;
  final double growthPercentage;
  final bool isActive;
  final String? imagePath; // Path to the goal image

  Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.baseRewardPerDay,
    required this.growthPercentage,
    this.isActive = true,
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'baseRewardPerDay': baseRewardPerDay,
      'growthPercentage': growthPercentage,
      'isActive': isActive,
      'imagePath': imagePath,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      name: json['name'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      baseRewardPerDay: (json['baseRewardPerDay'] as num).toDouble(),
      growthPercentage: (json['growthPercentage'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      imagePath: json['imagePath'] as String?,
    );
  }

  Goal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? baseRewardPerDay,
    double? growthPercentage,
    bool? isActive,
    String? imagePath,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      baseRewardPerDay: baseRewardPerDay ?? this.baseRewardPerDay,
      growthPercentage: growthPercentage ?? this.growthPercentage,
      isActive: isActive ?? this.isActive,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

