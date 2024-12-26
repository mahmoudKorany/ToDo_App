class TaskModel {
  final String title;
  final String body;
  final bool isCompleted;
  final DateTime createdAt;

  TaskModel({
    required this.title,
    required this.body,
    this.isCompleted = false,
    required this.createdAt,
  });

  TaskModel copyWith({
    String? title,
    String? body,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TaskModel(
      title: title ?? this.title,
      body: body ?? this.body,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      title: json['title'] as String,
      body: json['body'] as String,
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
