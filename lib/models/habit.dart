enum HabitType {
  good,
  bad;

  static HabitType? fromString(String? value) {
    if (value == null) return null;
    return HabitType.values.where((e) => e.name == value).firstOrNull;
  }
}

class Habit {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final HabitType? type;
  final int points;

  const Habit({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.type,
    required this.points,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: HabitType.fromString(json['type'] as String?),
      points: json['points'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'type': type?.name,
      'points': points,
    };
  }

  Habit copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    HabitType? type,
    int? points,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      points: points ?? this.points,
    );
  }
}
