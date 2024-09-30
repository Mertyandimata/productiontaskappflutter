import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_browser.dart';
import 'dart:io' as io; // Diğer platformlar için
import '../models/tasks.dart';

class IndexedDBTaskManager {
  static const String dbName = 'TaskDatabase';
  static const int dbVersion = 1;
  static const String mainTasksStore = 'main_tasks';
  static const String subTasksStore = 'sub_tasks';

  Database? _db;

  // Veritabanını başlatma fonksiyonu
Future<void> _initDB() async {



  _db = await idbFactoryBrowser.open(dbName, version: dbVersion, onUpgradeNeeded: _initializeDatabase);
  print("IndexedDB veritabanı başarıyla açıldı: $dbName");
}
  // Veritabanı tablolarını oluşturma
  void _initializeDatabase(VersionChangeEvent e) {
    Database db = (e.target as Request).result as Database;
    db.createObjectStore(mainTasksStore, keyPath: 'id'); // Ana görevler için store
    db.createObjectStore(subTasksStore, keyPath: 'id');  // Alt görevler için store
  }

  // Ana görevleri veritabanına kaydetme
  Future<void> saveTasks(List<MainTask> tasks) async {
    await _initDB();
    Transaction txn = _db!.transaction([mainTasksStore, subTasksStore], idbModeReadWrite);
    ObjectStore mainTaskStore = txn.objectStore(mainTasksStore);
    ObjectStore subTaskStore = txn.objectStore(subTasksStore);

    // Tüm store'ları temizleyelim
    await mainTaskStore.clear();
    await subTaskStore.clear();

    for (var task in tasks) {
      await mainTaskStore.put(_encodeMainTask(task)); // Ana görevleri ekle

      for (var subTask in task.subTasks) {
        await subTaskStore.put(_encodeSubTask(task.id, subTask)); // Alt görevleri ekle
      }
    }
    await txn.completed;
    print("Tüm görevler IndexedDB'ye başarıyla kaydedildi.");
  }

  // Ana görevleri okuma
  Future<List<MainTask>> readTasks() async {
    await _initDB();
    Transaction txn = _db!.transaction([mainTasksStore, subTasksStore], idbModeReadOnly);
    ObjectStore mainTaskStore = txn.objectStore(mainTasksStore);
    ObjectStore subTaskStore = txn.objectStore(subTasksStore);

    List<MainTask> mainTasks = [];
    List<SubTask> subTasks = [];

    // Tüm ana görevleri oku
    await mainTaskStore.openCursor(autoAdvance: true).listen((cursor) {
      final mainTask = _decodeMainTask(cursor.value as Map<String, dynamic>);
      mainTasks.add(mainTask);
    }).asFuture();

    // Tüm alt görevleri oku
    await subTaskStore.openCursor(autoAdvance: true).listen((cursor) {
      final subTask = _decodeSubTask(cursor.value as Map<String, dynamic>);
      subTasks.add(subTask);
    }).asFuture();

    // Ana görevlere bağlı alt görevleri ekle
    for (var mainTask in mainTasks) {
      mainTask.subTasks = subTasks.where((subTask) => subTask.mainTaskId == mainTask.id).toList();
    }

    print("Ana görevler başarıyla okundu. Toplam görev sayısı: ${mainTasks.length}");
    return mainTasks;
  }

  // Ana görev ekleme
  Future<void> addMainTask(MainTask task) async {
    await _initDB();
    Transaction txn = _db!.transaction([mainTasksStore], idbModeReadWrite);
    ObjectStore mainTaskStore = txn.objectStore(mainTasksStore);

    await mainTaskStore.put(_encodeMainTask(task));
    await txn.completed;
    print('Ana görev başarıyla kaydedildi: ${task.name}');
  }

  // Alt görev ekleme
  Future<void> addSubTask(String mainTaskId, SubTask subTask) async {
    await _initDB();
    Transaction txn = _db!.transaction([subTasksStore], idbModeReadWrite);
    ObjectStore subTaskStore = txn.objectStore(subTasksStore);

    await subTaskStore.put(_encodeSubTask(mainTaskId, subTask));
    await txn.completed;
    print('Alt görev başarıyla eklendi: ${subTask.name}');
  }

  // Ana görev güncelleme
  Future<void> updateMainTask(MainTask updatedTask) async {
    await _initDB();
    Transaction txn = _db!.transaction([mainTasksStore], idbModeReadWrite);
    ObjectStore mainTaskStore = txn.objectStore(mainTasksStore);

    await mainTaskStore.put(_encodeMainTask(updatedTask));
    await txn.completed;
    print('Ana görev başarıyla güncellendi: ${updatedTask.name}');
  }

  // Alt görev güncelleme
  Future<void> updateSubTask(String mainTaskId, SubTask updatedSubTask) async {
    await _initDB();
    Transaction txn = _db!.transaction([subTasksStore], idbModeReadWrite);
    ObjectStore subTaskStore = txn.objectStore(subTasksStore);

    await subTaskStore.put(_encodeSubTask(mainTaskId, updatedSubTask));
    await txn.completed;
    print('Alt görev başarıyla güncellendi: ${updatedSubTask.name}');
  }

  // Ana görev silme
  Future<void> deleteMainTask(String taskId) async {
    await _initDB();
    Transaction txn = _db!.transaction([mainTasksStore, subTasksStore], idbModeReadWrite);
    ObjectStore mainTaskStore = txn.objectStore(mainTasksStore);
    ObjectStore subTaskStore = txn.objectStore(subTasksStore);

    await mainTaskStore.delete(taskId);
    await subTaskStore.delete(taskId); // Ana görevle ilişkili alt görevler de silinebilir
    await txn.completed;
    print('Ana görev başarıyla silindi: $taskId');
  }

  // Alt görev silme
  Future<void> deleteSubTask(String mainTaskId, String subTaskId) async {
    await _initDB();
    Transaction txn = _db!.transaction([subTasksStore], idbModeReadWrite);
    ObjectStore subTaskStore = txn.objectStore(subTasksStore);

    await subTaskStore.delete(subTaskId);
    await txn.completed;
    print('Alt görev başarıyla silindi: $subTaskId');
  }

  // Ana ve alt görevleri CSV formatında dışa aktarma
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
}
