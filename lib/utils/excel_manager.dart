import 'dart:math';
import 'dart:io';
import 'package:etsu/models/tasks.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

class ExcelManager {
  final String filePath;

  ExcelManager(this.filePath);

  // Benzersiz ID oluşturma
  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(9999).toString();
  }

  // Excel dosyasını Byte array üzerinden okuma
  Future<List<MainTask>> readTasksFromFile(Uint8List fileBytes) async {
    var excel = Excel.decodeBytes(fileBytes); // Dosyayı byte olarak decode ediyoruz

    var mainTasks = <MainTask>[];
    var subTasksMap = <String, List<SubTask>>{};

    var mainTaskSheet = excel['MainTask'];
    var subTaskSheet = excel['SubTask'];

    // SubTask'leri okuma ve ilgili MainTask'e bağlama
    if (subTaskSheet != null) {
      for (var row in subTaskSheet.rows.skip(1)) {
        var subTask = SubTask(
          id: row[1]?.toString() ?? '',
          name: row[2]?.toString() ?? '',
          assignedTo: row[3]?.toString() ?? '',
          dueDate: DateTime.parse(row[4]?.toString() ?? ''),
          note: row[5]?.toString() ?? '',
          status: SubTaskStatus.values.firstWhere(
            (e) => e.toString() == 'SubTaskStatus.${row[6]?.toString()}',
          ),
          imageData: row[7]?.toString(),
        );
        var mainTaskId = row[0]?.toString();
        if (mainTaskId != null) {
          subTasksMap[mainTaskId] = subTasksMap[mainTaskId] ?? [];
          subTasksMap[mainTaskId]!.add(subTask);
        }
      }
    }

    // MainTask'leri okuma
    if (mainTaskSheet != null) {
      for (var row in mainTaskSheet.rows.skip(1)) {
        var mainTask = MainTask(
          id: row[0]?.toString() ?? '',
          name: row[1]?.toString() ?? '',
          description: row[2]?.toString() ?? '',
          peopleInvolved: (row[3]?.toString() ?? '').split(', '),
          startDate: DateTime.parse(row[4]?.toString() ?? ''),
          dueDate: row[5] != null ? DateTime.parse(row[5].toString()) : null,
          department: row[6]?.toString() ?? '',
          plant: row[7]?.toString() ?? '',
          subTasks: subTasksMap[row[0]?.toString()] ?? [],
          imageData: row[8]?.toString(),
        );
        mainTasks.add(mainTask);
      }
    }

    return mainTasks;
  }

  // Excel dosyasını assets klasöründen okuma
  Future<void> loadExcelFromAssets() async {
    try {
      ByteData data = await rootBundle.load('assets/data.xlsx');
      var bytes = data.buffer.asUint8List();
      var excel = Excel.decodeBytes(bytes);

      // Sayfalar ve veriler
      for (var table in excel.tables.keys) {
        print(table); // Sayfa adı
        print(excel.tables[table]!.maxRows); // Satır sayısı
        for (var row in excel.tables[table]!.rows) {
          print('$row');
        }
      }
    } catch (e) {
      print('Excel dosyası yüklenirken hata: $e');
    }
  }

  // Excel'den verileri okuma
  Future<List<MainTask>> readTasks() async {
    var file = File(filePath);
    if (!await file.exists()) throw Exception('Excel dosyası bulunamadı!');

    var bytes = await file.readAsBytes();
    var excel = Excel.decodeBytes(bytes);

    var mainTasks = <MainTask>[];
    var subTasksMap = <String, List<SubTask>>{};

    var mainTaskSheet = excel['MainTask'];
    var subTaskSheet = excel['SubTask'];

    // SubTask'leri okuma ve ilgili MainTask'e bağlama
    if (subTaskSheet != null) {
      for (var row in subTaskSheet.rows.skip(1)) {
        var subTask = SubTask(
          id: row[1]?.toString() ?? '',
          name: row[2]?.toString() ?? '',
          assignedTo: row[3]?.toString() ?? '',
          dueDate: DateTime.parse(row[4]?.toString() ?? ''),
          note: row[5]?.toString() ?? '',
          status: SubTaskStatus.values.firstWhere(
            (e) => e.toString() == 'SubTaskStatus.${row[6]?.toString()}',
          ),
          imageData: row[7]?.toString(),
        );
        var mainTaskId = row[0]?.toString();
        if (mainTaskId != null) {
          subTasksMap[mainTaskId] = subTasksMap[mainTaskId] ?? [];
          subTasksMap[mainTaskId]!.add(subTask);
        }
      }
    }

    // MainTask'leri okuma
    if (mainTaskSheet != null) {
      for (var row in mainTaskSheet.rows.skip(1)) {
        var mainTask = MainTask(
          id: row[0]?.toString() ?? '',
          name: row[1]?.toString() ?? '',
          description: row[2]?.toString() ?? '',
          peopleInvolved: (row[3]?.toString() ?? '').split(', '),
          startDate: DateTime.parse(row[4]?.toString() ?? ''),
          dueDate: row[5] != null ? DateTime.parse(row[5].toString()) : null,
          department: row[6]?.toString() ?? '',
          plant: row[7]?.toString() ?? '',
          subTasks: subTasksMap[row[0]?.toString()] ?? [],
          imageData: row[8]?.toString(),
        );
        mainTasks.add(mainTask);
      }
    }

    return mainTasks;
  }

  dynamic toCellValue(dynamic value) {
    if (value is String) {
      return value;
    } else if (value is int || value is double) {
      return value;
    } else if (value is DateTime) {
      return value.toIso8601String();
    } else {
      return ''; // Null veya bilinmeyen tür için boş string
    }
  }

  // Yeni MainTask ekleme
  Future<void> addMainTask(MainTask task, String filePath) async {
    var file = File(filePath);
    var bytes = await file.readAsBytes();
    var excel = Excel.decodeBytes(bytes);
    var sheet = excel['MainTask'];

    sheet.appendRow([
      toCellValue(task.id), 
      toCellValue(task.name),
      toCellValue(task.description),
      toCellValue(task.peopleInvolved.join(', ')),
      toCellValue(task.startDate),
      toCellValue(task.dueDate ?? ''),
      toCellValue(task.department),
      toCellValue(task.plant),
      toCellValue(task.imageData ?? '')
    ]);

    saveExcel(excel, filePath);
  }

  // Yeni SubTask ekleme
  Future<void> addSubTask(String mainTaskId, SubTask subTask, String filePath) async {
    var file = File(filePath);
    var bytes = await file.readAsBytes();
    var excel = Excel.decodeBytes(bytes);
    var sheet = excel['SubTask'];

    sheet.appendRow([
      toCellValue(mainTaskId),
      toCellValue(subTask.id),
      toCellValue(subTask.name),
      toCellValue(subTask.assignedTo),
      toCellValue(subTask.dueDate),
      toCellValue(subTask.note),
      toCellValue(subTask.status.toString().split('.').last),
      toCellValue(subTask.imageData ?? '')
    ]);

    saveExcel(excel, filePath);
  }

  // MainTask güncelleme
  Future<void> updateMainTask(MainTask updatedTask, String filePath) async {
    var file = File(filePath);
    var bytes = await file.readAsBytes();
    var excel = Excel.decodeBytes(bytes);
    var sheet = excel['MainTask'];

    if (sheet == null) throw Exception('MainTask sayfası bulunamadı.');

    for (var i = 1; i < sheet.rows.length; i++) {
      if (sheet.rows[i][0] == updatedTask.id) {
        sheet.updateCell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i),
          toCellValue(updatedTask.id),
        );
        sheet.updateCell(
          CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i),
          toCellValue(updatedTask.name),
        );
        sheet.updateCell(
          CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i),
          toCellValue(updatedTask.description),
        );
        sheet.updateCell(
          CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i),
          toCellValue(updatedTask.peopleInvolved.join(', ')),
        );
        sheet.updateCell(
          CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i),
          toCellValue(updatedTask.startDate.toIso8601String()),
        );
        sheet.updateCell(
          CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i),
          toCellValue(updatedTask.dueDate?.toIso8601String() ?? ''),
        );
        sheet.updateCell(
          CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i),
          toCellValue(updatedTask.department),
        );
        sheet.updateCell(
          CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: i),
          toCellValue(updatedTask.plant),
        );
        sheet.updateCell(
          CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: i),
          toCellValue(updatedTask.imageData ?? ''),
        );
        break;
      }
    }

    saveExcel(excel, filePath);
  }

  // SubTask güncelleme
  Future<void> updateSubTask(String mainTaskId, SubTask updatedSubTask, String filePath) async {
    var file = File(filePath);
    var bytes = await file.readAsBytes();
    var excel = Excel.decodeBytes(bytes);
    var sheet = excel['SubTask'];

    if (sheet == null) throw Exception('SubTask sayfası bulunamadı.');

    for (var i = 1; i < sheet.rows.length; i++) {
      if (sheet.rows[i][0] == mainTaskId && sheet.rows[i][1] == updatedSubTask.id) {
        sheet.updateCell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i),
          toCellValue(mainTaskId),
        );
        sheet.updateCell(
          CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i),
          toCellValue(updatedSubTask.id),
        );
        sheet.updateCell(
          CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i),
          toCellValue(updatedSubTask.name),
        );
        sheet.updateCell(
          CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i),
          toCellValue(updatedSubTask.assignedTo),
        );
        sheet.updateCell(
          CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i),
          toCellValue(updatedSubTask.dueDate.toIso8601String()),
        );
        sheet.updateCell(
          CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i),
          toCellValue(updatedSubTask.note),
        );
        sheet.updateCell(
          CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i),
          toCellValue(updatedSubTask.status.toString().split('.').last),
        );
        sheet.updateCell(
          CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: i),
          toCellValue(updatedSubTask.imageData ?? ''),
        );
        break;
      }
    }

    saveExcel(excel, filePath);
  }

  // MainTask silme
  Future<void> deleteMainTask(String taskId, String filePath) async {
    var file = File(filePath);
    var bytes = await file.readAsBytes();
    var excel = Excel.decodeBytes(bytes);
    var mainTaskSheet = excel['MainTask'];
    var subTaskSheet = excel['SubTask'];

    if (mainTaskSheet == null) throw Exception('MainTask sayfası bulunamadı.');

    List<int> rowsToRemove = [];

    // MainTask'i silmek için satırları bul
    for (var i = 0; i < mainTaskSheet.rows.length; i++) {
      if (mainTaskSheet.rows[i][0]?.toString() == taskId) {
        rowsToRemove.add(i);
      }
    }

    // Belirlenen satırları sil
    for (var rowIndex in rowsToRemove.reversed) {
      mainTaskSheet.removeRow(rowIndex);
    }

    // İlgili SubTask'leri sil
    if (subTaskSheet != null) {
      List<int> subTaskRowsToRemove = [];
      for (var i = 0; i < subTaskSheet.rows.length; i++) {
        if (subTaskSheet.rows[i][0]?.toString() == taskId) {
          subTaskRowsToRemove.add(i);
        }
      }
      for (var rowIndex in subTaskRowsToRemove.reversed) {
        subTaskSheet.removeRow(rowIndex);
      }
    }

    saveExcel(excel, filePath);
  }

  // Excel dosyasını kaydetme
  Future<void> saveExcel(Excel excel, String filePath) async {
    List<int>? fileBytes = excel.save();
    if (fileBytes != null) {
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }
  }
}
