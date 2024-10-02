import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_browser.dart';
import '../models/tasks.dart';

class IndexedDBTaskManager {
  static const String dbName = 'TaskDatabase';
  static const int dbVersion = 2;
  static const String mainTasksStore = 'main_tasks';
  static const String subTasksStore = 'sub_tasks';

  Database? _db;

  Future<void> _initDB() async {
    _db = await idbFactoryBrowser.open(dbName, version: dbVersion, onUpgradeNeeded: _onUpgradeNeeded);
    print("IndexedDB veritabanı başarıyla açıldı: $dbName");
  }

  void _onUpgradeNeeded(VersionChangeEvent event) {
    Database db = event.database;
    
    if (!db.objectStoreNames.contains(mainTasksStore)) {
      db.createObjectStore(mainTasksStore, keyPath: 'id');
    }
    
    if (!db.objectStoreNames.contains(subTasksStore)) {
      ObjectStore subStore = db.createObjectStore(subTasksStore, keyPath: 'id');
      subStore.createIndex('mainTaskId', 'mainTaskId', unique: false);
    } else {
      ObjectStore subStore = event.transaction!.objectStore(subTasksStore);
      if (!subStore.indexNames.contains('mainTaskId')) {
        subStore.createIndex('mainTaskId', 'mainTaskId', unique: false);
      }
    }
  }

  Future<void> saveTasks(List<MainTask> tasks) async {
    await _initDB();
    Transaction txn = _db!.transaction([mainTasksStore, subTasksStore], idbModeReadWrite);
    ObjectStore mainTaskStore = txn.objectStore(mainTasksStore);
    ObjectStore subTaskStore = txn.objectStore(subTasksStore);

    await mainTaskStore.clear();
    await subTaskStore.clear();

    for (var task in tasks) {
      await mainTaskStore.put(_encodeMainTask(task));
      for (var subTask in task.subTasks) {
        await subTaskStore.put(_encodeSubTask(task.id, subTask));
      }
    }
    await txn.completed;
    print("Tüm görevler IndexedDB'ye başarıyla kaydedildi.");
  }

  Future<List<MainTask>> readTasks() async {
    await _initDB();
    Transaction txn = _db!.transaction([mainTasksStore, subTasksStore], idbModeReadOnly);
    ObjectStore mainTaskStore = txn.objectStore(mainTasksStore);
    ObjectStore subTaskStore = txn.objectStore(subTasksStore);

    List<MainTask> mainTasks = [];
    Map<String, List<SubTask>> subTasksMap = {};

    await mainTaskStore.openCursor(autoAdvance: true).listen((cursor) {
      final mainTask = _decodeMainTask(cursor.value as Map<String, dynamic>);
      mainTasks.add(mainTask);
      subTasksMap[mainTask.id] = [];
    }).asFuture();

    await subTaskStore.openCursor(autoAdvance: true).listen((cursor) {
      final subTask = _decodeSubTask(cursor.value as Map<String, dynamic>);
      if (subTasksMap.containsKey(subTask.mainTaskId)) {
        subTasksMap[subTask.mainTaskId]!.add(subTask);
      }
    }).asFuture();

    for (var mainTask in mainTasks) {
      mainTask.subTasks = subTasksMap[mainTask.id] ?? [];
    }

    print("Ana görevler ve alt görevler başarıyla okundu. Toplam ana görev sayısı: ${mainTasks.length}");
    return mainTasks;
  }

  Future<void> addMainTask(MainTask task) async {
    await _initDB();
    Transaction txn = _db!.transaction([mainTasksStore, subTasksStore], idbModeReadWrite);
    ObjectStore mainTaskStore = txn.objectStore(mainTasksStore);
    ObjectStore subTaskStore = txn.objectStore(subTasksStore);

    await mainTaskStore.put(_encodeMainTask(task));
    for (var subTask in task.subTasks) {
      await subTaskStore.put(_encodeSubTask(task.id, subTask));
    }
    await txn.completed;
    print('Ana görev ve alt görevleri başarıyla kaydedildi: ${task.name}');
  }
 Future<void> updateMainTask(MainTask updatedTask) async {
    await _initDB();
    Transaction txn = _db!.transaction([mainTasksStore, subTasksStore], idbModeReadWrite);
    ObjectStore mainTaskStore = txn.objectStore(mainTasksStore);
    ObjectStore subTaskStore = txn.objectStore(subTasksStore);

    await mainTaskStore.put(_encodeMainTask(updatedTask));
    
    try {
      Index mainTaskIdIndex = subTaskStore.index('mainTaskId');
      await mainTaskIdIndex.openCursor(key: updatedTask.id).listen((cursor) {
        if (cursor != null) {
          cursor.delete();
          cursor.next();
        }
      }).asFuture();
    } catch (e) {
      print('Alt görevleri silerken hata oluştu: $e');
      await subTaskStore.openCursor().listen((cursor) {
        if (cursor != null) {
          Map<String, dynamic> value = cursor.value as Map<String, dynamic>;
          if (value['mainTaskId'] == updatedTask.id) {
            cursor.delete();
          }
          cursor.next();
        }
      }).asFuture();
    }

    for (var subTask in updatedTask.subTasks) {
      await subTaskStore.put(_encodeSubTask(updatedTask.id, subTask));
    }

    await txn.completed;
    print('Ana görev ve alt görevleri başarıyla güncellendi: ${updatedTask.name}');
  }
 Future<void> deleteMainTask(String taskId) async {
    await _initDB();
    Transaction txn = _db!.transaction([mainTasksStore, subTasksStore], idbModeReadWrite);
    ObjectStore mainTaskStore = txn.objectStore(mainTasksStore);
    ObjectStore subTaskStore = txn.objectStore(subTasksStore);

    await mainTaskStore.delete(taskId);
    
    try {
      Index mainTaskIdIndex = subTaskStore.index('mainTaskId');
      await mainTaskIdIndex.openCursor(key: taskId).listen((cursor) {
        if (cursor != null) {
          cursor.delete();
          cursor.next();
        }
      }).asFuture();
    } catch (e) {
      print('Alt görevleri silerken hata oluştu: $e');
      await subTaskStore.openCursor().listen((cursor) {
        if (cursor != null) {
          Map<String, dynamic> value = cursor.value as Map<String, dynamic>;
          if (value['mainTaskId'] == taskId) {
            cursor.delete();
          }
          cursor.next();
        }
      }).asFuture();
    }

    await txn.completed;
    print('Ana görev ve ilişkili alt görevler başarıyla silindi: $taskId');
  }

  Future<void> addSubTask(String mainTaskId, SubTask subTask) async {
    await _initDB();
    Transaction txn = _db!.transaction([subTasksStore], idbModeReadWrite);
    ObjectStore subTaskStore = txn.objectStore(subTasksStore);

    await subTaskStore.put(_encodeSubTask(mainTaskId, subTask));
    await txn.completed;
    print('Alt görev başarıyla eklendi: ${subTask.name}');
  }

  Future<void> updateSubTask(String mainTaskId, SubTask updatedSubTask) async {
    await _initDB();
    Transaction txn = _db!.transaction([subTasksStore], idbModeReadWrite);
    ObjectStore subTaskStore = txn.objectStore(subTasksStore);

    await subTaskStore.put(_encodeSubTask(mainTaskId, updatedSubTask));
    await txn.completed;
    print('Alt görev başarıyla güncellendi: ${updatedSubTask.name}');
  }

  Future<void> deleteSubTask(String mainTaskId, String subTaskId) async {
    await _initDB();
    Transaction txn = _db!.transaction([subTasksStore], idbModeReadWrite);
    ObjectStore subTaskStore = txn.objectStore(subTasksStore);

    await subTaskStore.delete(subTaskId);
    await txn.completed;
    print('Alt görev başarıyla silindi: $subTaskId');
  }

  Future<List<String>> exportToCSV() async {
    await _initDB();
    Transaction txn = _db!.transaction([mainTasksStore, subTasksStore], idbModeReadOnly);
    ObjectStore mainTaskStore = txn.objectStore(mainTasksStore);
    ObjectStore subTaskStore = txn.objectStore(subTasksStore);

    List<MainTask> mainTasks = [];
    List<SubTask> allSubTasks = [];

    await mainTaskStore.openCursor(autoAdvance: true).listen((cursor) {
      final mainTask = _decodeMainTask(cursor.value as Map<String, dynamic>);
      mainTasks.add(mainTask);
    }).asFuture();

    await subTaskStore.openCursor(autoAdvance: true).listen((cursor) {
      final subTask = _decodeSubTask(cursor.value as Map<String, dynamic>);
      allSubTasks.add(subTask);
    }).asFuture();

    // Ana görevler için CSV
    String mainTasksCSV = 'ID,Name,Description,People Involved,Start Date,Due Date,Department,Plant,Completion Rate\n';
    for (var task in mainTasks) {
      mainTasksCSV += '${task.id},"${task.name}","${task.description}","${task.peopleInvolved.join(', ')}",'
          '${task.startDate.toIso8601String()},${task.dueDate?.toIso8601String() ?? ''},'
          '${task.department},${task.plant},${task.completionRate}\n';
    }

    // Alt görevler için CSV
    String subTasksCSV = 'ID,Main Task ID,Name,Assigned To,Due Date,Note,Status\n';
    for (var subTask in allSubTasks) {
      subTasksCSV += '${subTask.id},${subTask.mainTaskId},"${subTask.name}","${subTask.assignedTo}",'
          '${subTask.dueDate.toIso8601String()},"${subTask.note}",${subTask.status}\n';
    }

    return [mainTasksCSV, subTasksCSV];
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
      'id': subTask.id,
      'mainTaskId': mainTaskId,
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
}