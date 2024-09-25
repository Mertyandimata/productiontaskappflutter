

class MainTask {
  final String name;
  final String description;
  final List<String> peopleInvolved;
  final DateTime startDate;
  final DateTime? dueDate;  // Yeni eklenen alan
  final List<SubTask> subTasks;
  final String department;
  final String plant;

  MainTask({
    required this.name,
    required this.description,
    required this.peopleInvolved,
    required this.startDate,
    this.dueDate,  // Opsiyonel parametre olarak eklendi
    required this.subTasks,
    required this.department,
    required this.plant,
  });

  double get completionRate {
    if (subTasks.isEmpty) return 0;
    int completedTasks = subTasks.where((task) => task.status == SubTaskStatus.done).length;
    return completedTasks / subTasks.length;
  }

  String get completionString {
    int completedTasks = subTasks.where((task) => task.status == SubTaskStatus.done).length;
    return '$completedTasks/${subTasks.length}';
  }
}

class SubTask {
  final String id;  // Unique identifier for the subtask
  late final String name;
  String assignedTo;
  DateTime dueDate;
  String note;
  SubTaskStatus status;

  SubTask({
    required this.id,
    required this.name,
    required this.assignedTo,
    required this.dueDate,
    required this.note,
    this.status = SubTaskStatus.backlog,
  });

  // Optional: Add a method to create a copy of the SubTask with updated fields
  SubTask copyWith({
    String? name,
    String? assignedTo,
    DateTime? dueDate,
    String? note,
    SubTaskStatus? status,
  }) {
    return SubTask(
      id: this.id,
      name: name ?? this.name,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
      note: note ?? this.note,
      status: status ?? this.status,
    );
  }
}

enum SubTaskStatus {
  backlog,
  inProgress,
  waiting,
  done,
}