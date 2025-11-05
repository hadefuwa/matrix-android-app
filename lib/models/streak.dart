class Streak {
  final String habitId; // Which habit this streak belongs to
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCompletedDate;
  final DateTime? lastCheckedDate;

  const Streak({
    required this.habitId,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedDate,
    this.lastCheckedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'habitId': habitId,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastCompletedDate': lastCompletedDate?.toIso8601String(),
      'lastCheckedDate': lastCheckedDate?.toIso8601String(),
    };
  }

  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      habitId: json['habitId'] as String,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastCompletedDate: json['lastCompletedDate'] != null
          ? DateTime.parse(json['lastCompletedDate'] as String)
          : null,
      lastCheckedDate: json['lastCheckedDate'] != null
          ? DateTime.parse(json['lastCheckedDate'] as String)
          : null,
    );
  }

  Streak copyWith({
    String? habitId,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastCompletedDate,
    DateTime? lastCheckedDate,
  }) {
    return Streak(
      habitId: habitId ?? this.habitId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      lastCheckedDate: lastCheckedDate ?? this.lastCheckedDate,
    );
  }
}

