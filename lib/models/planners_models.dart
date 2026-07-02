class WorkTask {
  final String id;
  final String title;
  final String description;
  final String assignedStaffId;
  final String assignedStaffName;
  final DateTime dueDate;
  final String priority; // 'low', 'medium', 'high'
  final String status; // 'todo', 'in_progress', 'done'

  WorkTask({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedStaffId,
    required this.assignedStaffName,
    required this.dueDate,
    required this.priority,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'assignedStaffId': assignedStaffId,
    'assignedStaffName': assignedStaffName,
    'dueDate': dueDate.toIso8601String(),
    'priority': priority,
    'status': status,
  };

  factory WorkTask.fromJson(Map<String, dynamic> json) => WorkTask(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    assignedStaffId: json['assignedStaffId'] as String,
    assignedStaffName: json['assignedStaffName'] as String,
    dueDate: DateTime.parse(json['dueDate'] as String),
    priority: json['priority'] as String,
    status: json['status'] as String,
  );

  WorkTask copyWith({
    String? title,
    String? description,
    String? assignedStaffId,
    String? assignedStaffName,
    DateTime? dueDate,
    String? priority,
    String? status,
  }) => WorkTask(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    assignedStaffId: assignedStaffId ?? this.assignedStaffId,
    assignedStaffName: assignedStaffName ?? this.assignedStaffName,
    dueDate: dueDate ?? this.dueDate,
    priority: priority ?? this.priority,
    status: status ?? this.status,
  );
}

class BusinessMilestone {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;

  BusinessMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'isCompleted': isCompleted,
  };

  factory BusinessMilestone.fromJson(Map<String, dynamic> json) => BusinessMilestone(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    isCompleted: json['isCompleted'] as bool,
  );

  BusinessMilestone copyWith({
    String? title,
    String? description,
    bool? isCompleted,
  }) => BusinessMilestone(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    isCompleted: isCompleted ?? this.isCompleted,
  );
}
