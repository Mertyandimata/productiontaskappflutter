import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/tasks.dart';
import '../utils/app_colors.dart';
import '../widgets/main_task_card.dart';
import '../widgets/task_detail_panel.dart';
import 'package:intl/intl.dart';

class TaskManagementPage extends StatefulWidget {
  @override
  _TaskManagementPageState createState() => _TaskManagementPageState();
}

class _TaskManagementPageState extends State<TaskManagementPage> {
  String? selectedDepartment;
  List<String> departments = ['All', 'Hot Water', 'Cold Water', 'Machining', 'Pressing'];
  String? selectedPlant;
  List<String> plants = ['All', 'DM1', 'DS5', 'DC3', 'DB4'];
  
  List<MainTask> mainTasks = [
    MainTask(
      name: 'Optimize Production Line',
      description: 'Improve efficiency of the main production line',
      peopleInvolved: ['John Doe', 'Jane Smith'],
      startDate: DateTime.now().subtract(Duration(days: 10)),
      dueDate: DateTime.now().add(Duration(days: 20)),
      subTasks: [],
      department: 'Hot Water',
      plant: 'DM1',
    ),
    // Add more sample tasks here
  ];

  MainTask? selectedTask;

  @override
  Widget build(BuildContext context) {
    List<MainTask> filteredTasks = mainTasks.where((task) =>
      (selectedDepartment == null || selectedDepartment == 'All' || task.department == selectedDepartment) &&
      (selectedPlant == null || selectedPlant == 'All' || task.plant == selectedPlant)
    ).toList();

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        toolbarHeight: 80, // Increased height for better spacing
        title: Row(
          children: [
            Image.asset(
              'assets/logo2.png',
              height: 90, // Adjusted height
              width: 120, // Adjusted width
            ),
            SizedBox(width: 10),
            Text(
              'Operation Task Management',
              style: TextStyle(
                color: AppColors.darkGreen,
                fontWeight: FontWeight.bold,
                fontSize: 20, // Adjusted font size
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
                    onPressed: _showCreateTaskDialog,
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
                                isSelected: filteredTasks[index] == selectedTask,
                              ),
                            );
                          },
                        ),
                  ),
                  if (selectedTask != null)
                    Expanded(
                      flex: 2,
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
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.veryLightGreen,
      borderRadius: BorderRadius.circular(8),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedPlant,
        hint: Text('Select Plant', 
          style: TextStyle(color: AppColors.mediumGreen, fontSize: 14)),
        icon: Icon(Icons.arrow_drop_down, color: AppColors.darkGreen),
        style: TextStyle(color: AppColors.darkGreen, fontSize: 14),
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
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.veryLightGreen,
      borderRadius: BorderRadius.circular(8),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedDepartment,
        hint: Text('Select Department', 
          style: TextStyle(color: AppColors.mediumGreen, fontSize: 14)),
        icon: Icon(Icons.arrow_drop_down, color: AppColors.darkGreen),
        style: TextStyle(color: AppColors.darkGreen, fontSize: 14),
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
      }
    });
  }
void _showCreateTaskDialog() {
  String taskName = '';
  String taskDescription = '';
  List<String> peopleInvolved = [];
  String? selectedDepartmentForTask;
  String? selectedPlantForTask;
  DateTime startDate = DateTime.now();
  DateTime? dueDate;

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
                  _buildHeader('Create New Task'),
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
                                  onChanged: (value) => taskName = capitalize(value),
                                ),
                                SizedBox(height: 16),
                                _buildTextField(
                                  icon: Icons.description,
                                  label: 'Description',
                                  onChanged: (value) => taskDescription = capitalize(value),
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
                                        (person) => setState(() => peopleInvolved.add(capitalize(person))),
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
                        Navigator.of(context).pop();
                        _addNewTask(MainTask(
                          name: taskName,
                          description: taskDescription,
                          peopleInvolved: peopleInvolved,
                          startDate: startDate,
                          dueDate: dueDate,
                          subTasks: [],
                          department: selectedDepartmentForTask!,
                          plant: selectedPlantForTask!,
                        ));
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
  );
}

Widget _buildDropdownRow({required Widget firstDropdown, required Widget secondDropdown}) {
  return Row(
    children: [
      Expanded(child: firstDropdown),
      SizedBox(width: 12),
      Expanded(child: secondDropdown),
    ],
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

Widget _buildPeopleInvolvedSection({
  required List<String> peopleInvolved,
  required VoidCallback onAddPerson,
  required Function(int) onRemovePerson,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'People Involved',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          IconButton(
            icon: Icon(Icons.add, size: 20, color: AppColors.primary),
            onPressed: onAddPerson,
          ),
        ],
      ),
      SizedBox(height: 8),
      Container(
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.veryLightGreen),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: peopleInvolved.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      peopleInvolved[index][0],
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      peopleInvolved[index],
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 16, color: AppColors.textDark),
                    onPressed: () => onRemovePerson(index),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ],
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
    });
  }
}

