class TaskModel {
  final int? id;
  final String title;
  final String time;
  final String date;
  final String status;
  final String? details;
  final String priority;
  final String category;

  TaskModel({
    this.id,
    required this.title,
    required this.time,
    required this.date,
    required this.status,
    this.details,
    required this.priority,
    required this.category,
  });

  TaskModel copyWith({
    int? id,
    String? title,
    String? time,
    String? date,
    String? status,
    String? details,
    String? priority,
    String? category,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      date: date ?? this.date,
      status: status ?? this.status,
      details: details ?? this.details,
      priority: priority ?? this.priority,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'date': date,
      'status': status,
      'details': details,
      'priority': priority,
      'category': category,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'date': date,
      'status': status,
      'details': details,
      'priority': priority,
      'category': category,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as int?,
      title: json['title'] as String,
      time: json['time'] as String,
      date: json['date'] as String,
      status: json['status'] as String,
      details: json['details'] as String?,
      priority: json['priority'] as String,
      category: json['category'] as String,
    );
  }
}
