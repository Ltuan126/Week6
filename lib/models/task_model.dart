class Task {
  final int id;
  final String title;
  final String description;
  final String status;
  final String category;
  final String priority;
  final List<Subtask> subtasks;
  final List<Attachment> attachments;
  bool isDone;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.category = '',
    this.priority = '',
    this.subtasks = const [],
    this.attachments = const [],
    this.isDone = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      category: json['category'] ?? '',
      priority: json['priority'] ?? '',
      subtasks: ((json['subtasks'] ?? []) as List)
          .map((e) => Subtask.fromJson(e))
          .toList(),
      attachments: ((json['attachments'] ?? []) as List)
          .map((e) => Attachment.fromJson(e))
          .toList(),
      isDone: json['isDone'] ?? false,
    );
  }
}

class Subtask {
  final int id;
  final String title;
  final bool done;

  Subtask({
    required this.id,
    required this.title,
    required this.done,
  });

  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      id: json['id'],
      title: json['title'] ?? '',
      done: json['done'] ?? false,
    );
  }
}

class Attachment {
  final String name;

  Attachment({required this.name});

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      name: json['name'] ?? '',
    );
  }
}
