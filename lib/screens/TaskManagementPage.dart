import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/tasks.dart';
import '../utils/app_colors.dart';
import '../widgets/main_task_card.dart';
import '../widgets/task_detail_panel.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:html' as html;

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
List<MainTask> mainTasks = [
  MainTask(
    name: 'Optimize Production Line',
    description: 'Improve efficiency of the main production line',
    peopleInvolved: ['John Doe', 'Jane Smith'],
    startDate: DateTime.now().subtract(Duration(days: 10)),
    dueDate: DateTime.now().add(Duration(days: 20)),
    department: 'Hot Water',
    plant: 'DM1',
    subTasks: [
      SubTask(
        id: '1',
        name: 'Analyze current workflow',
        assignedTo: 'John Doe',
        dueDate: DateTime.now().add(Duration(days: 5)),
        note: 'Identify bottlenecks in the production process',
        status: SubTaskStatus.inProgress,
      ),
      SubTask(
        id: '2',
        name: 'Implement new scheduling system',
        assignedTo: 'Jane Smith',
        dueDate: DateTime.now().add(Duration(days: 10)),
        note: 'Introduce a new system to reduce downtime',
        status: SubTaskStatus.backlog,
      ),
    ],
  ),
  MainTask(
    name: 'Install New Press Machine',
    description: 'Install and calibrate the new press machine in the plant.',
    peopleInvolved: ['Alice Johnson', 'Mark Thompson'],
    startDate: DateTime.now().subtract(Duration(days: 5)),
    dueDate: DateTime.now().add(Duration(days: 25)),
    department: 'Pressing',
    plant: 'DC3',
    subTasks: [
      SubTask(
        id: '3',
        name: 'Machine setup and calibration',
        assignedTo: 'Alice Johnson',
        dueDate: DateTime.now().add(Duration(days: 15)),
        note: 'Ensure machine is properly calibrated',
        status: SubTaskStatus.backlog,
      ),
    ],
  ),
  MainTask(
    name: 'Cold Water System Maintenance',
    description: 'Perform scheduled maintenance on the cold water system.',
    peopleInvolved: ['Samantha Lee', 'Chris Evans'],
    startDate: DateTime.now().subtract(Duration(days: 15)),
    dueDate: DateTime.now().add(Duration(days: 10)),
    department: 'Cold Water',
    plant: 'DS5',
    subTasks: [],
  ),
  MainTask(
    name: 'Upgrade Machining Equipment',
    description: 'Upgrade the machining equipment for better precision.',
    peopleInvolved: ['Robert Downey', 'Natalie Portman'],
    startDate: DateTime.now().subtract(Duration(days: 20)),
    dueDate: DateTime.now().add(Duration(days: 15)),
    department: 'Machining',
    plant: 'DB4',
    subTasks: [
      SubTask(
        id: '4',
        name: 'Order new parts',
        assignedTo: 'Natalie Portman',
        dueDate: DateTime.now().add(Duration(days: 5)),
        note: 'Ensure all new parts are ordered and delivered on time',
        status: SubTaskStatus.waiting,
      ),
    ],
  ),
  MainTask(
    name: 'Energy Efficiency Audit',
    description: 'Conduct an energy audit to find ways to reduce electricity usage.',
    peopleInvolved: ['Bruce Wayne', 'Diana Prince'],
    startDate: DateTime.now().subtract(Duration(days: 3)),
    dueDate: DateTime.now().add(Duration(days: 30)),
    department: 'Hot Water',
    plant: 'DM1',
    subTasks: [
      SubTask(
        id: '5',
        name: 'Collect energy usage data',
        assignedTo: 'Bruce Wayne',
        dueDate: DateTime.now().add(Duration(days: 7)),
        note: 'Review current energy consumption metrics',
        status: SubTaskStatus.inProgress,
      ),
      SubTask(
        id: '6',
        name: 'Present findings to management',
        assignedTo: 'Diana Prince',
        dueDate: DateTime.now().add(Duration(days: 20)),
        note: 'Show potential areas for reducing energy usage',
        status: SubTaskStatus.backlog,
      ),
      SubTask(
        id: '13',
        name: 'Present findings to management',
        assignedTo: 'Diana Prince',
        dueDate: DateTime.now().add(Duration(days: 20)),
        note: 'Show potential areas for reducing energy usage',
        status: SubTaskStatus.backlog,
      ),
      SubTask(
        id: '14',
        name: 'Present findings to management',
        assignedTo: 'Diana Prince',
        dueDate: DateTime.now().add(Duration(days: 20)),
        note: 'Show potential areas for reducing energy usage',
        status: SubTaskStatus.backlog,
      ),
    ],
  ),
  MainTask(
    name: 'Inspect Safety Equipment',
    description: 'Check the condition of all safety equipment in the plant.',
    peopleInvolved: ['Clark Kent', 'Barry Allen'],
    startDate: DateTime.now().subtract(Duration(days: 7)),
    dueDate: DateTime.now().add(Duration(days: 21)),
    department: 'Pressing',
    plant: 'DS5',
    subTasks: [
      SubTask(
        id: '7',
        name: 'Inspect fire extinguishers',
        assignedTo: 'Clark Kent',
        dueDate: DateTime.now().add(Duration(days: 14)),
        note: 'Ensure all extinguishers are up to date',
        status: SubTaskStatus.inProgress,
      ),
    ],
  ),
];

  @override
  void initState() {
    super.initState();
    if (mainTasks.isNotEmpty) {
      mainTasks.sort((a, b) => b.startDate.compareTo(a.startDate));
      selectedTask = mainTasks[0];
    }
  }

  Future<String?> pickAndEncodeImage() async {
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

  @override
  Widget build(BuildContext context) {
    List<MainTask> filteredTasks = mainTasks.where((task) =>
      (selectedDepartment == null || selectedDepartment == 'All' || task.department == selectedDepartment) &&
      (selectedPlant == null || selectedPlant == 'All' || task.plant == selectedPlant)
    ).toList();

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
                    onPressed: () => _showCreateTaskDialog(),
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

  void _updateTask(MainTask updatedTask) {
    setState(() {
      int index = mainTasks.indexWhere((task) => task.name == updatedTask.name);
      if (index != -1) {
        mainTasks[index] = updatedTask;
        if (selectedTask != null && selectedTask!.name == updatedTask.name) {
          selectedTask = updatedTask;
        }
      }
    });
  }

  void _showCreateTaskDialog({MainTask? taskToEdit}) {
  String taskName = taskToEdit?.name ?? '';
  String taskDescription = taskToEdit?.description ?? '';
  List<String> peopleInvolved = List.from(taskToEdit?.peopleInvolved ?? []);
  String? selectedDepartmentForTask = taskToEdit?.department;
  String? selectedPlantForTask = taskToEdit?.plant;
  DateTime startDate = taskToEdit?.startDate ?? DateTime.now();
  DateTime? dueDate = taskToEdit?.dueDate;
  String? imageData = taskToEdit?.imageData;

  showDialog(
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
                                  onChanged: (value) => taskName = value,
                                ),
                                SizedBox(height: 16),
                                _buildTextField(
                                  icon: Icons.description,
                                  label: 'Description',
                                  initialValue: taskDescription,
                                  onChanged: (value) => taskDescription = value,
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
                    onCreate: () {
                      if (taskName.isNotEmpty && taskDescription.isNotEmpty &&
                          selectedPlantForTask != null && selectedDepartmentForTask != null) {
                        MainTask newTask = MainTask(
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
                        Navigator.of(context).pop(newTask);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please fill in all required fields')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  ).then((result) {
    if (result != null) {
      if (taskToEdit == null) {
        _addNewTask(result);
      } else {
        _updateTask(result);
      }
    }
  });
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
    _showCreateTaskDialog(taskToEdit: task);
  }

  void _deleteMainTask(MainTask task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Task'),
          content: Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                setState(() {
                  mainTasks.remove(task);
                  if (selectedTask == task) {
                    selectedTask = null;
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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

  Widget _buildActionButtons({required VoidCallback onCancel, required VoidCallback onCreate}) {
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
            child: Text('Create', style: TextStyle(color: Colors.white, fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: onCreate,
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

  void _addNewTask(MainTask newTask) {
    setState(() {
      mainTasks.add(newTask);
      mainTasks.sort((a, b) => b.startDate.compareTo(a.startDate));
    });
  }
}