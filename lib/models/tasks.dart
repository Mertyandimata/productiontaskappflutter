import 'dart:convert';

enum SubTaskStatus {
  backlog,
  inProgress,
  waiting,
  done,
}

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'peopleInvolved': peopleInvolved,
      'startDate': startDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'subTasks': subTasks.map((st) => st.toJson()).toList(),
      'department': department,
      'plant': plant,
      'imageData': imageData,
    };
  }

  factory MainTask.fromJson(Map<String, dynamic> json) {
    return MainTask(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      peopleInvolved: List<String>.from(json['peopleInvolved']),
      startDate: DateTime.parse(json['startDate']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      subTasks: (json['subTasks'] as List).map((st) => SubTask.fromJson(st)).toList(),
      department: json['department'],
      plant: json['plant'],
      imageData: json['imageData'],
    );
  }
}
class SubTask {
  final String id;
  final String mainTaskId;  // Yeni eklenen alan
  String name;
  String assignedTo;
  DateTime dueDate;
  String note;
  SubTaskStatus status;
  String? imageData;

  SubTask({
    required this.id,
    required this.mainTaskId,  // Yapıcıya eklendi
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
      mainTaskId: this.mainTaskId,  // copyWith metoduna eklendi
      name: name ?? this.name,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
      note: note ?? this.note,
      status: status ?? this.status,
      imageData: imageData ?? this.imageData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mainTaskId': mainTaskId,  // JSON dönüşümüne eklendi
      'name': name,
      'assignedTo': assignedTo,
      'dueDate': dueDate.toIso8601String(),
      'note': note,
      'status': status.toString().split('.').last,
      'imageData': imageData,
    };
  }

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'],
      mainTaskId: json['mainTaskId'],  // JSON'dan oluşturmaya eklendi
      name: json['name'],
      assignedTo: json['assignedTo'],
      dueDate: DateTime.parse(json['dueDate']),
      note: json['note'],
      status: SubTaskStatus.values.firstWhere(
        (e) => e.toString() == 'SubTaskStatus.${json['status']}',
        orElse: () => SubTaskStatus.backlog,
      ),
      imageData: json['imageData'],
    );
  }
}