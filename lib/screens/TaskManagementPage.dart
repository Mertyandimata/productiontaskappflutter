import 'dart:async';
import 'dart:convert';

import 'package:etsu/utils/IndexedDBTaskManager.dart';
//import 'package:etsu/utils/excel_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/tasks.dart';
import '../utils/app_colors.dart';
import '../widgets/main_task_card.dart';
import '../widgets/task_detail_panel.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:html' as html;
import 'package:path_provider/path_provider.dart'; 
import 'package:flutter/foundation.dart' show kIsWeb;

class TaskManagementPage extends StatefulWidget {
  @override
  _TaskManagementPageState createState() => _TaskManagementPageState();
}

class _TaskManagementPageState extends State<TaskManagementPage> {
  String? selectedDepartment;
  List<String> departments = ['All', 'Hot Water', 'Cold Water', 'Machining', 'Pressing'];
  String? selectedPlant;
  List<String> plants = ['All', 'DM1', 'DS5', 'DC3', 'DB4'];
  MainTask? selectedTask;
  //late TextFileTaskManager taskManager;
  List<MainTask> mainTasks = [];
  late IndexedDBTaskManager taskManager; // TextFileTaskManager yerine IndexedDBTaskManager'ı tanımlıyoruz


  @override
  void initState() {
    super.initState();
    _initTaskManager();
  }
  /*
Future<void> _initTaskManager() async {
  print('TextFileTaskManager başlatılıyor...');
  taskManager = TextFileTaskManager();
  await _loadTasks();
}

void _downloadDatabase() {
  if (kIsWeb) {
    final csvContent = taskManager.exportToCSV(mainTasks);

    // Web platformunda çalıştığından emin ol
    // CSV dosyasını oluştur ve indir
    final blob = html.Blob([csvContent], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "tasks_database.csv")
      ..click();

    // URL'yi temizle
    html.Url.revokeObjectUrl(url);
  } else {
    print('Bu özellik sadece web platformunda çalışır.');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bu özellik sadece web platformunda kullanılabilir.')),
    );
  }
}*/
Future<void> _initTaskManager() async {
  print('IndexedDBTaskManager başlatılıyor...');
  taskManager = IndexedDBTaskManager(); // Yeni IndexedDBTaskManager'ı kullan
  await _loadTasks(); // Veritabanından görevleri yükle
}


  void _downloadDatabase() async {
    try {
      List<String> csvData = await taskManager.exportToCSV();
      
      // Ana görevler CSV'sini indir
      _downloadCSV(csvData[0], 'main_tasks.csv');
      
      // Alt görevler CSV'sini indir
      _downloadCSV(csvData[1], 'sub_tasks.csv');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Database exported successfully')),
      );
    } catch (e) {
      print('Veritabanı dışa aktarılırken hata oluştu: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while exporting the database')),
      );
    }
  }

  void _downloadCSV(String csvContent, String fileName) {
    final bytes = utf8.encode(csvContent);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }



  @override
  Widget build(BuildContext context) {
    print('TaskManagementPage arayüzü oluşturuluyor...');
    
    // Filtrelenmiş görevler listesi
    List<MainTask> filteredTasks = mainTasks.where((task) {
      print('Görev: ${task.name}, Department: ${task.department}, Plant: ${task.plant}');
      return (selectedDepartment == null || selectedDepartment == 'All' || task.department == selectedDepartment) &&
             (selectedPlant == null || selectedPlant == 'All' || task.plant == selectedPlant);
    }).toList();

    print('Filtrelenmiş görev sayısı: ${filteredTasks.length}');
    
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        toolbarHeight: 80,
        title: Row(
          children: [
            Image.asset(
              'assets/logo2.png',
              height: 90,
              width: 120,
            ),
            SizedBox(width: 10),
            Text(
              'ETSU Operations Dashboard',
              style: TextStyle(
                color: AppColors.darkGreen,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
       actions: [
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: _buildPlantDropdown(),
    ),
    SizedBox(width: 16),
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: _buildDepartmentDropdown(),
    ),
    SizedBox(width: 16),
    IconButton(
      icon: Icon(Icons.download, color: AppColors.primary),
      onPressed: _downloadDatabase,//_downloadDatabase,
      tooltip: 'Download Database',
    ),
  ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.backgroundLight, AppColors.backgroundDark],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Main Tasks',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _createNewTask(),
                    icon: Icon(Icons.add, color: Colors.white),
                    label: Text('Create Task', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: selectedTask != null ? 3 : 5,
                    child: filteredTasks.isEmpty
                      ? Center(
                          child: Text(
                            'No tasks for the selected department and plant.',
                            style: TextStyle(fontSize: 18, color: AppColors.primary),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            print('Görev gösteriliyor: ${filteredTasks[index].name}');
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              child: MainTaskCard(
                                task: filteredTasks[index],
                                onTaskUpdated: _updateTask,
                                onCardSelected: _selectTask,
                                onEditTask: _editMainTask,
                                onDeleteTask: _deleteMainTask,
                                isSelected: filteredTasks[index] == selectedTask,
                              ),
                            );
                          },
                        ),
                  ),
                  if (selectedTask != null)
                    Expanded(
                      flex: 4,
                      child: TaskDetailPanel(
                        task: selectedTask!,
                        onClose: () => setState(() => selectedTask = null),
                        onTaskUpdated: _updateTask,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

void _createNewTask() {
  print('Creating a new task...');
  _showCreateTaskDialog().then((newTask) {
    if (newTask != null) {
      _addNewTask(newTask); // Yeni görev eklendiğinde veri tabanına kaydediyoruz
    }
  });
}

  
Future<String?> pickAndEncodeImage() async {
  if (kIsWeb) {
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();

    final completer = Completer<String?>();
    input.onChange.listen((event) {
      final file = input.files!.first;
      final reader = html.FileReader();

      reader.onLoadEnd.listen((event) {
        final result = reader.result as String;
        final base64Image = result.split(',').last;
        completer.complete(base64Image);
      });

      reader.readAsDataUrl(file);
    });
    return completer.future;
  } else {
    // Mobil platformlar için fallback
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      String base64Image = base64Encode(file.bytes!);
      return base64Image;
    }
    return null;
  }
}


Widget _buildPlantDropdown() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: AppColors.veryLightGreen,
      borderRadius: BorderRadius.circular(8),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedPlant,
        hint: Text(
          'Select Plant',
          style: TextStyle(
            color: AppColors.mediumGreen,
            fontSize: 12,
          ),
        ),
        icon: Icon(
          Icons.arrow_drop_down,
          color: AppColors.darkGreen,
          size: 18,
        ),
        style: TextStyle(
          color: AppColors.darkGreen,
          fontSize: 12,
        ),
        dropdownColor: AppColors.almostWhite,
        onChanged: (String? newValue) {
          setState(() {
            selectedPlant = newValue;
          });
        },
        items: plants.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    ),
  );
}

Widget _buildDepartmentDropdown() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: AppColors.veryLightGreen,
      borderRadius: BorderRadius.circular(8),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedDepartment,
        hint: Text(
          'Select Department',
          style: TextStyle(
            color: AppColors.mediumGreen,
            fontSize: 12,
          ),
        ),
        icon: Icon(
          Icons.arrow_drop_down,
          color: AppColors.darkGreen,
          size: 18,
        ),
        style: TextStyle(
          color: AppColors.darkGreen,
          fontSize: 12,
        ),
        dropdownColor: AppColors.almostWhite,
        onChanged: (String? newValue) {
          setState(() {
            selectedDepartment = newValue;
          });
        },
        items: departments.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    ),
  );
}

  void _selectTask(MainTask task) {
    setState(() {
      selectedTask = task;
    });
  }



Future<MainTask?> _showCreateTaskDialog({MainTask? taskToEdit}) async {
  String taskName = taskToEdit?.name ?? '';
  String taskDescription = taskToEdit?.description ?? '';
  List<String> peopleInvolved = List.from(taskToEdit?.peopleInvolved ?? []);
  String? selectedDepartmentForTask = taskToEdit?.department;
  String? selectedPlantForTask = taskToEdit?.plant;
  DateTime startDate = taskToEdit?.startDate ?? DateTime.now();
  DateTime? dueDate = taskToEdit?.dueDate;
  String? imageData = taskToEdit?.imageData;

  // Yeni görev oluşturulacaksa ID üretiyoruz, düzenleme yapılıyorsa mevcut ID'yi kullanıyoruz
  int newTaskId = taskToEdit?.id != null ? int.parse(taskToEdit!.id) : _generateNewTaskId();

  return showDialog<MainTask>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                children: [
                  _buildHeader(taskToEdit == null ? 'Create New Task' : 'Edit Task'),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sol taraf (Task bilgileri)
                        Expanded(
                          flex: 3,
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTextField(
                                  icon: Icons.title,
                                  label: 'Task Name',
                                  initialValue: taskName,
                                  onChanged: (value) => setState(() => taskName = value),
                                ),
                                SizedBox(height: 16),
                                _buildTextField(
                                  icon: Icons.description,
                                  label: 'Description',
                                  initialValue: taskDescription,
                                  onChanged: (value) => setState(() => taskDescription = value),
                                  maxLines: 4,
                                ),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDropdown(
                                        icon: Icons.factory,
                                        label: 'Plant',
                                        value: selectedPlantForTask,
                                        items: plants.where((plant) => plant != 'All').toList(),
                                        onChanged: (value) => setState(() => selectedPlantForTask = value),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: _buildDropdown(
                                        icon: Icons.business,
                                        label: 'Department',
                                        value: selectedDepartmentForTask,
                                        items: departments.where((department) => department != 'All').toList(),
                                        onChanged: (value) => setState(() => selectedDepartmentForTask = value),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDateField(
                                        icon: Icons.calendar_today,
                                        label: 'Start Date',
                                        date: startDate,
                                        onTap: () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: startDate,
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );
                                          if (picked != null) {
                                            setState(() => startDate = picked);
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: _buildDateField(
                                        icon: Icons.event,
                                        label: 'Due Date',
                                        date: dueDate,
                                        onTap: () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: dueDate ?? DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );
                                          if (picked != null) {
                                            setState(() => dueDate = picked);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                _buildImageUpload(
                                  imageData: imageData,
                                  onImageSelected: (data) => setState(() => imageData = data),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Sağ taraf (People Involved)
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.almostWhite,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'People Involved',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    ...peopleInvolved.map((person) => _buildPersonChip(
                                      person,
                                      onDeleted: () => setState(() => peopleInvolved.remove(person)),
                                    )),
                                    _buildAddPersonChip(
                                      onTap: () => _showAddPersonDialog(
                                        context,
                                        (person) => setState(() => peopleInvolved.add(person)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildActionButtons(
                    onCancel: () => Navigator.of(context).pop(),
                    onSave: () {
                      if (taskName.isEmpty || taskDescription.isEmpty || selectedPlantForTask == null || selectedDepartmentForTask == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please fill in all required fields')),
                        );
                        return;
                      }

                      MainTask newOrUpdatedTask = MainTask(
                        id: newTaskId.toString(),
                        name: taskName,
                        description: taskDescription, 
                        peopleInvolved: peopleInvolved,
                        startDate: startDate,
                        dueDate: dueDate,
                        subTasks: taskToEdit?.subTasks ?? [],
                        department: selectedDepartmentForTask!,
                        plant: selectedPlantForTask!,
                        imageData: imageData,
                      );

                      Navigator.of(context).pop(newOrUpdatedTask);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

int _generateNewTaskId() {
  if (mainTasks.isEmpty) return 1;

  int maxId = mainTasks.map((task) => int.tryParse(task.id) ?? 0).reduce((a, b) => a > b ? a : b);
  return maxId + 1;
}

Widget _buildTaskCard(MainTask task) {
  return Card(
    elevation: 2,
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: InkWell(
      onTap: () => _selectTask(task),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (task.imageData != null)
  ClipRRect(
    borderRadius: BorderRadius.circular(4),
    child: Image.memory(
      base64Decode(task.imageData!),
      width: 50,
      height: 50,
      fit: BoxFit.cover,
    ),
  ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              task.description,
              style: TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Due: ${DateFormat('MMM d, y').format(task.dueDate ?? task.startDate)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  '${task.department} - ${task.plant}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: task.completionRate,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            SizedBox(height: 4),
            Text(
              '${(task.completionRate * 100).toStringAsFixed(0)}% Complete',
              style: TextStyle(fontSize: 12, color: AppColors.primary),
            ),
          ],
        ),
      ),
    ),
  );
}

void _editMainTask(MainTask task) {
  print('Editing task: ${task.name}');
  _showCreateTaskDialog(taskToEdit: task).then((editedTask) {
    if (editedTask != null) {
      _updateTask(editedTask);
    }
  });
}




  
Widget _buildImageUpload({
  required String? imageData,
  required Function(String?) onImageSelected,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Task Image',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
      SizedBox(height: 8),
      InkWell(
        onTap: () {
          final html.FileUploadInputElement input = html.FileUploadInputElement()..accept = 'image/*';
          input.click();

          input.onChange.listen((event) {
            final file = input.files!.first;
            final reader = html.FileReader();

            reader.onLoadEnd.listen((event) {
              final result = reader.result as String;
              final base64Image = result.split(',').last;
              onImageSelected(base64Image);
            });

            reader.readAsDataUrl(file);
          });
        },
        child: Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.veryLightGreen),
            borderRadius: BorderRadius.circular(12),
          ),
          child: imageData != null
              ? Image.memory(
                  base64Decode(imageData),
                  fit: BoxFit.cover,
                )
              : Icon(
                  Icons.add_photo_alternate,
                  size: 40,
                  color: AppColors.primary,
                ),
        ),
      ),
    ],
  );
}
  String capitalize(String? text) {
    if (text == null || text.isEmpty) {
      return '';
    }
    return text[0].toUpperCase() + text.substring(1);
  }

  Widget _buildAddPersonChip({required VoidCallback onTap}) {
    return ActionChip(
      avatar: Icon(Icons.add, size: 16, color: AppColors.primary),
      label: Text('Add Person', style: TextStyle(fontSize: 12, color: AppColors.primary)),
      onPressed: onTap,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.primary),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.add_task, color: Colors.white, size: 24),
          SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonChip(String person, {required VoidCallback onDeleted}) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: AppColors.primary,
        child: Text(
          person[0].toUpperCase(),
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
      ),
      label: Text(person, style: TextStyle(fontSize: 12)),
      deleteIcon: Icon(Icons.close, size: 16),
      onDeleted: onDeleted,
      backgroundColor: AppColors.veryLightGreen,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required String label,
    required Function(String) onChanged,
    String? initialValue,
    int maxLines = 1,
  }) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        labelText: label,
        labelStyle: TextStyle(fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      style: TextStyle(fontSize: 14),
      onChanged: onChanged,
      maxLines: maxLines,
      controller: TextEditingController(text: initialValue),
    );
  }

  Widget _buildDropdown({
    required IconData icon,
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        labelText: label,
        labelStyle: TextStyle(fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: TextStyle(fontSize: 14)),
        );
      }).toList(),
      onChanged: onChanged,
      style: TextStyle(fontSize: 14, color: AppColors.textDark),
    );
  }

  Widget _buildDateField({
    required IconData icon,
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          labelText: label,
          labelStyle: TextStyle(fontSize: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        child: Text(
          date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Select Date',
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildActionButtons({required VoidCallback onCancel, required VoidCallback onSave}) {
  return Container(
    padding: EdgeInsets.all(20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          child: Text('Cancel', style: TextStyle(color: AppColors.primary, fontSize: 14)),
          onPressed: onCancel,
        ),
        SizedBox(width: 16),
        ElevatedButton(
          child: Text('Save', style: TextStyle(color: Colors.white, fontSize: 14)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: onSave,
        ),
      ],
    ),
  );
}

  void _showAddPersonDialog(BuildContext context, Function(String) onAdd) {
    String newPerson = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Person'),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Enter person\'s name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onChanged: (value) => newPerson = value,
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: AppColors.primary)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Add', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                if (newPerson.isNotEmpty) {
                  onAdd(newPerson);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  /*
Future<void> _addNewTask(MainTask newTask) async {
  try {
    print('Yeni ana görev ekleniyor: ${newTask.name}');
    await taskManager.addMainTask(newTask);
    print('Yeni ana görev başarıyla eklendi: ${newTask.name}');
    await _loadTasks();
  } catch (e) {
    print('Ana görev eklenirken hata oluştu: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ana görev eklenirken bir hata oluştu')),
    );
  }
}

Future<void> _addNewSubTask(String mainTaskId, SubTask newSubTask) async {
  try {
    print('Yeni alt görev ekleniyor: ${newSubTask.name} (Ana Görev ID: $mainTaskId)');
    await taskManager.addSubTask(mainTaskId, newSubTask);
    print('Yeni alt görev başarıyla eklendi: ${newSubTask.name}');
    await _loadTasks();
  } catch (e) {
    print('Alt görev eklenirken hata oluştu: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Alt görev eklenirken bir hata oluştu')),
    );
  }
}

Future<void> _updateTask(MainTask updatedTask) async {
  try {
    print('Ana görev güncelleniyor: ${updatedTask.name}');
    await taskManager.updateMainTask(updatedTask);
    print('Ana görev başarıyla güncellendi: ${updatedTask.name}');
    await _loadTasks();
  } catch (e) {
    print('Ana görev güncellenirken hata oluştu: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ana görev güncellenirken bir hata oluştu')),
    );
  }
}

Future<void> _updateSubTask(String mainTaskId, SubTask updatedSubTask) async {
  try {
    print('Alt görev güncelleniyor: ${updatedSubTask.name} (Ana Görev ID: $mainTaskId)');
    await taskManager.updateSubTask(mainTaskId, updatedSubTask);
    print('Alt görev başarıyla güncellendi: ${updatedSubTask.name}');
    await _loadTasks();
  } catch (e) {
    print('Alt görev güncellenirken hata oluştu: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Alt görev güncellenirken bir hata oluştu')),
    );
  }
}

Future<void> _deleteMainTask(MainTask task) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Ana Görevi Sil'),
        content: Text('Bu görevi ve ona bağlı tüm alt görevleri silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            child: Text('İptal'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text('Sil'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                print('Ana görev siliniyor: ${task.name}');
                await taskManager.deleteMainTask(task.id);
                print('Ana görev ve bağlı alt görevler başarıyla silindi: ${task.name}');
                Navigator.of(context).pop();
                await _loadTasks();
                if (selectedTask?.id == task.id) {
                  setState(() {
                    selectedTask = null;
                  });
                }
              } catch (e) {
                print('Ana görev silinirken hata oluştu: $e');
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ana görev silinirken bir hata oluştu')),
                );
              }
            },
          ),
        ],
      );
    },
  );
}

Future<void> _deleteSubTask(String mainTaskId, String subTaskId) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Alt Görevi Sil'),
        content: Text('Bu alt görevi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            child: Text('İptal'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text('Sil'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                print('Alt görev siliniyor: $subTaskId (Ana Görev ID: $mainTaskId)');
                await taskManager.deleteSubTask(mainTaskId, subTaskId);
                print('Alt görev başarıyla silindi: $subTaskId');
                Navigator.of(context).pop();
                await _loadTasks();
              } catch (e) {
                print('Alt görev silinirken hata oluştu: $e');
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Alt görev silinirken bir hata oluştu')),
                );
              }
            },
          ),
        ],
      );
    },
  );
}

Future<void> _loadTasks() async {
  try {
    print('Görevler yükleniyor...');
    var tasks = await taskManager.readTasks();
    setState(() {
      mainTasks = tasks;
    });
    print('Görevler başarıyla yüklendi. Toplam ana görev sayısı: ${mainTasks.length}');
  } catch (e) {
    print('Görevler yüklenirken hata oluştu: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Görevler yüklenirken bir hata oluştu')),
    );
  }
}*/

Future<void> _addNewTask(MainTask newTask) async {
  try {
    await taskManager.addMainTask(newTask); // IndexedDB'ye ana görevi ekler
    print('Yeni ana görev başarıyla eklendi: ${newTask.name}');
    await _loadTasks();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Main task successfully added: ${newTask.name}')),
    );
  } catch (e) {
    print('Ana görev eklenirken hata oluştu: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred while adding the main task')),
    );
  }
}
Future<void> _addNewSubTask(String mainTaskId, SubTask newSubTask) async {
  try {
    await taskManager.addSubTask(mainTaskId, newSubTask);
    print('Yeni alt görev başarıyla eklendi: ${newSubTask.name}');
    await _loadTasks();
  } catch (e) {
    print('Alt görev eklenirken hata oluştu: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred while adding a subtask')),
    );
  }
}

Future<void> _updateTask(MainTask updatedTask) async {
  try {
    await taskManager.updateMainTask(updatedTask); // IndexedDB'de ana görevi günceller
    print('Ana görev başarıyla güncellendi: ${updatedTask.name}');
    await _loadTasks();
  } catch (e) {
    print('Ana görev güncellenirken hata oluştu: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred while updating the main task')),
    );
  }
}


Future<void> _updateSubTask(String mainTaskId, SubTask updatedSubTask) async {
  try {
    await taskManager.updateSubTask(mainTaskId, updatedSubTask);
    print('Alt görev başarıyla güncellendi: ${updatedSubTask.name}');
    await _loadTasks();
  } catch (e) {
    print('Alt görev güncellenirken hata oluştu: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred while updating the subtask')),
    );
  }
}

Future<void> _deleteMainTask(MainTask task) async {
  try {
    await taskManager.deleteMainTask(task.id); // IndexedDB'den ana görevi siler
    print('Ana görev başarıyla silindi: ${task.name}');
    await _loadTasks();
  } catch (e) {
    print('Ana görev silinirken hata oluştu: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred while deleting the main task')),
    );
  }
}




Future<void> _loadTasks() async {
  try {
    var tasks = await taskManager.readTasks();
    setState(() {
      mainTasks = tasks;
    });
    print('Görevler başarıyla yüklendi. Toplam ana görev sayısı: ${mainTasks.length}');
  } catch (e) {
    print('Görevler yüklenirken hata oluştu: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred while loading tasks')),
    );
  }
}



}