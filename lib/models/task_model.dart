import 'dart:convert';

enum TaskPriority { low, medium, high }

class Task {
  final int? id;
  final String title;
  final String category;
  final TaskPriority priority;
  final DateTime date;
  final String time; // HH:mm format
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  Task({
    this.id,
    required this.title,
    required this.category,
    required this.priority,
    required this.date,
    required this.time,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  Task copyWith({
    int? id,
    String? title,
    String? category,
    TaskPriority? priority,
    DateTime? date,
    String? time,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      date: date ?? this.date,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'priority': priority.index,
      'date': date.toIso8601String(),
      'time': time,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      priority: TaskPriority.values[map['priority']],
      date: DateTime.parse(map['date']),
      time: map['time'],
      isCompleted: map['isCompleted'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Task.fromJson(String source) => Task.fromMap(json.decode(source));
}
