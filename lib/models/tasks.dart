// MainTask ve SubTask sınıfları
class MainTask {
  String id;
  String name;
  String description;
  List<String> peopleInvolved;
  DateTime startDate;
  DateTime? dueDate;
  List<SubTask> subTasks;
  String department;
  String plant;
  String? imageData;

  MainTask({
    required this.id,
    required this.name,
    required this.description,
    required this.peopleInvolved,
    required this.startDate,
    this.dueDate,
    required this.subTasks,
    required this.department,
    required this.plant,
    this.imageData,
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

  MainTask copyWith({
    String? name,
    String? description,
    List<String>? peopleInvolved,
    DateTime? startDate,
    DateTime? dueDate,
    List<SubTask>? subTasks,
    String? department,
    String? plant,
    String? imageData,
  }) {
    return MainTask(
      id: this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      peopleInvolved: peopleInvolved ?? this.peopleInvolved,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      subTasks: subTasks ?? this.subTasks,
      department: department ?? this.department,
      plant: plant ?? this.plant,
      imageData: imageData ?? this.imageData,
    );
  }
}

class SubTask {
  final String id;
  String name;
  String assignedTo;
  DateTime dueDate;
  String note;
  SubTaskStatus status;
  String? imageData;

  SubTask({
    required this.id,
    required this.name,
    required this.assignedTo,
    required this.dueDate,
    required this.note,
    this.status = SubTaskStatus.backlog,
    this.imageData,
  });

  SubTask copyWith({
    String? name,
    String? assignedTo,
    DateTime? dueDate,
    String? note,
    SubTaskStatus? status,
    String? imageData,
  }) {
    return SubTask(
      id: this.id,
      name: name ?? this.name,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
      note: note ?? this.note,
      status: status ?? this.status,
      imageData: imageData ?? this.imageData,
    );
  }
}

enum SubTaskStatus {
  backlog,
  inProgress,
  waiting,
  done,
}