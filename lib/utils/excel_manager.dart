import 'dart:html' as html;
import 'dart:convert';
import '../models/tasks.dart';

class TextFileTaskManager {
  static const String mainTasksKey = 'main_tasks';
  static const String subTasksKey = 'sub_tasks';

  Future<void> saveTasks(List<MainTask> tasks) async {
    print('Saving tasks to local storage...');
    final mainTasksJson = tasks.map((task) => _encodeMainTask(task)).toList();
    final subTasksJson = tasks.expand((task) => task.subTasks.map((subTask) => _encodeSubTask(task.id, subTask))).toList();

    html.window.localStorage[mainTasksKey] = json.encode(mainTasksJson);
    html.window.localStorage[subTasksKey] = json.encode(subTasksJson);
    print('Tasks saved successfully.');
  }

  Future<List<MainTask>> readTasks() async {
    print('Reading tasks from local storage...');
    try {
      final mainTasksJson = html.window.localStorage[mainTasksKey];
      final subTasksJson = html.window.localStorage[subTasksKey];

      if (mainTasksJson == null || subTasksJson == null) {
        print('No tasks found in local storage.');
        return [];
      }

      final mainTasks = (json.decode(mainTasksJson) as List).map((taskJson) => _decodeMainTask(taskJson)).toList();
      final subTasks = (json.decode(subTasksJson) as List).map((subTaskJson) => _decodeSubTask(subTaskJson)).toList();

      for (var mainTask in mainTasks) {
        mainTask.subTasks = subTasks.where((subTask) => subTask.mainTaskId == mainTask.id).toList();
      }

      print('Tasks read successfully. Total main tasks: ${mainTasks.length}');
      return mainTasks;
    } catch (e) {
      print('Error reading tasks: $e');
      return [];
    }
  }

  Map<String, dynamic> _encodeMainTask(MainTask task) {
    return {
      'id': task.id,
      'name': task.name,
      'description': task.description,
      'peopleInvolved': task.peopleInvolved,
      'startDate': task.startDate.toIso8601String(),
      'dueDate': task.dueDate?.toIso8601String(),
      'department': task.department,
      'plant': task.plant,
      'imageData': task.imageData,
    };
  }

  Map<String, dynamic> _encodeSubTask(String mainTaskId, SubTask subTask) {
    return {
      'mainTaskId': mainTaskId,
      'id': subTask.id,
      'name': subTask.name,
      'assignedTo': subTask.assignedTo,
      'dueDate': subTask.dueDate.toIso8601String(),
      'note': subTask.note,
      'status': subTask.status.toString().split('.').last,
      'imageData': subTask.imageData,
    };
  }

  MainTask _decodeMainTask(Map<String, dynamic> json) {
    return MainTask(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      peopleInvolved: List<String>.from(json['peopleInvolved']),
      startDate: DateTime.parse(json['startDate']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      department: json['department'],
      plant: json['plant'],
      imageData: json['imageData'],
      subTasks: [],
    );
  }

  SubTask _decodeSubTask(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'],
      name: json['name'],
      assignedTo: json['assignedTo'],
      dueDate: DateTime.parse(json['dueDate']),
      note: json['note'],
      status: SubTaskStatus.values.firstWhere(
        (e) => e.toString() == 'SubTaskStatus.${json['status']}',
        orElse: () => SubTaskStatus.backlog,
      ),
      imageData: json['imageData'],
      mainTaskId: json['mainTaskId'],
    );
  }

Future<void> addMainTask(MainTask task) async {
  final tasks = await readTasks();
  tasks.add(task);
  print('Ana görev listesine eklendi: ${task.name}');
  await saveTasks(tasks);
  print('Ana görev kaydedildi: ${task.name}');
}


  Future<void> updateMainTask(MainTask updatedTask) async {
    final tasks = await readTasks();
    final index = tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      tasks[index] = updatedTask;
      await saveTasks(tasks);
      print('Main task updated: ${updatedTask.name}');
    } else {
      print('Main task not found for update: ${updatedTask.id}');
    }
  }

  Future<void> deleteMainTask(String taskId) async {
    final tasks = await readTasks();
    tasks.removeWhere((t) => t.id == taskId);
    await saveTasks(tasks);
    print('Main task deleted: $taskId');
  }

  Future<void> addSubTask(String mainTaskId, SubTask subTask) async {
    final tasks = await readTasks();
    final mainTaskIndex = tasks.indexWhere((t) => t.id == mainTaskId);
    if (mainTaskIndex != -1) {
      tasks[mainTaskIndex].subTasks.add(subTask);
      await saveTasks(tasks);
      print('Sub task added to main task: $mainTaskId');
    } else {
      print('Main task not found for adding sub task: $mainTaskId');
    }
  }

  Future<void> updateSubTask(String mainTaskId, SubTask updatedSubTask) async {
    final tasks = await readTasks();
    final mainTaskIndex = tasks.indexWhere((t) => t.id == mainTaskId);
    if (mainTaskIndex != -1) {
      final subTaskIndex = tasks[mainTaskIndex].subTasks.indexWhere((st) => st.id == updatedSubTask.id);
      if (subTaskIndex != -1) {
        tasks[mainTaskIndex].subTasks[subTaskIndex] = updatedSubTask;
        await saveTasks(tasks);
        print('Sub task updated in main task: $mainTaskId');
      } else {
        print('Sub task not found for update in main task: $mainTaskId');
      }
    } else {
      print('Main task not found for updating sub task: $mainTaskId');
    }
  }

  Future<void> deleteSubTask(String mainTaskId, String subTaskId) async {
    final tasks = await readTasks();
    final mainTaskIndex = tasks.indexWhere((t) => t.id == mainTaskId);
    if (mainTaskIndex != -1) {
      tasks[mainTaskIndex].subTasks.removeWhere((st) => st.id == subTaskId);
      await saveTasks(tasks);
      print('Sub task deleted from main task: $mainTaskId');
    } else {
      print('Main task not found for deleting sub task: $mainTaskId');
    }
  }
  String exportToCSV(List<MainTask> tasks) {
  final csvData = [
    ['ID', 'Name', 'Description', 'People Involved', 'Start Date', 'Due Date', 'Department', 'Plant', 'Completion Rate', 'Sub Tasks'],
    ...tasks.map((task) => [
      task.id,
      task.name,
      task.description,
      task.peopleInvolved.join(', '),
      task.startDate.toIso8601String(),
      task.dueDate?.toIso8601String() ?? '',
      task.department,
      task.plant,
      task.completionRate.toString(),
      task.subTasks.map((st) => '${st.name} (${st.status})').join('; ')
    ])
  ];

  return csvData.map((row) => row.join(',')).join('\n');
}

}