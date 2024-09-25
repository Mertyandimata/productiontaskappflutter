import 'package:flutter/material.dart';
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
  String selectedDepartment = 'Hot Water';
  List<String> departments = ['Hot Water', 'Cold Water', 'Machining', 'Pressing'];
  String selectedPlant = 'DM1';
  List<String> plants = ['DM1', 'DS5', 'DC3', 'DB4'];
  
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
      task.department == selectedDepartment && task.plant == selectedPlant
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Management'),
        backgroundColor: AppColors.primary,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                '$selectedPlant / $selectedDepartment',
                style: TextStyle(fontSize: 16),
              ),
            ),
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
            _buildSelectionHeaders(),
            _buildSelectionChips(),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Main Tasks',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showCreateTaskDialog,
                    icon: Icon(Icons.add),
                    label: Text('Create Tasking'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: selectedTask != null ? 1 : 2,
                    child: filteredTasks.isEmpty
                      ? Center(
                          child: Text(
                            'No tasks for the selected department and plant.',
                            style: TextStyle(fontSize: 16, color: AppColors.primary),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            return MainTaskCard(
                              task: filteredTasks[index],
                              onTaskUpdated: _updateTask,
                              onCardSelected: _selectTask,
                              isSelected: filteredTasks[index] == selectedTask,
                            );
                          },
                        ),
                  ),
                  if (selectedTask != null)
                    Expanded(
                      flex: 1,
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

  Widget _buildSelectionHeaders() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Select Department',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Text(
              'Select Plant',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: departments.map((department) => _buildChip(
                department,
                selectedDepartment == department,
                () => setState(() => selectedDepartment = department),
                AppColors.primary,
              )).toList(),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: plants.map((plant) => _buildChip(
                plant,
                selectedPlant == plant,
                () => setState(() => selectedPlant = plant),
                AppColors.secondary,
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        backgroundColor: isSelected ? color : color.withOpacity(0.1),
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
    String selectedDepartmentForTask = selectedDepartment;
    String selectedPlantForTask = selectedPlant;
    DateTime startDate = DateTime.now();
    DateTime? dueDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.add_task, color: AppColors.primary, size: 24),
                  SizedBox(width: 8),
                  Text('Create New Task', style: TextStyle(color: AppColors.primary)),
                ],
              ),
              content: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        icon: Icons.title,
                        label: 'Task Name',
                        onChanged: (value) => taskName = value,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        icon: Icons.description,
                        label: 'Description',
                        onChanged: (value) => taskDescription = value,
                        maxLines: 3,
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              icon: Icons.business,
                              label: 'Department',
                              value: selectedDepartmentForTask,
                              items: departments,
                              onChanged: (value) {
                                setState(() {
                                  selectedDepartmentForTask = value!;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown(
                              icon: Icons.factory,
                              label: 'Plant',
                              value: selectedPlantForTask,
                              items: plants,
                              onChanged: (value) {
                                setState(() {
                                  selectedPlantForTask = value!;
                                });
                              },
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
                                  setState(() {
                                    startDate = picked;
                                  });
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
                                  setState(() {
                                    dueDate = picked;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Text(
                        'People Involved',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Add Person',
                              style: TextStyle(fontSize: 16, color: AppColors.primary),
                            ),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              _showAddPersonDialog(context, (person) {
                                setState(() {
                                  peopleInvolved.add(person);
                                });
                              });
                            },
                            child: Icon(Icons.add, color: Colors.white),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.separated(
                          padding: EdgeInsets.all(8),
                          itemCount: peopleInvolved.length,
                          separatorBuilder: (context, index) => Divider(height: 1),
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(peopleInvolved[index][0]),
                                backgroundColor: AppColors.primary.withOpacity(0.2),
                              ),
                              title: Text(peopleInvolved[index]),
                              trailing: IconButton(
                                icon: Icon(Icons.close, size: 18),
                                onPressed: () {
                                  setState(() {
                                    peopleInvolved.removeAt(index);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel', style: TextStyle(color: AppColors.primary)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: Text('Create', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () {
                    if (taskName.isNotEmpty && taskDescription.isNotEmpty) {
                      Navigator.of(context).pop();
                      _addNewTask(MainTask(
                        name: taskName,
                        description: taskDescription,
                        peopleInvolved: peopleInvolved,
                        startDate: startDate,
                        dueDate: dueDate,
                        subTasks: [],
                        department: selectedDepartmentForTask,
                        plant: selectedPlantForTask,
                      ));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill in all required fields')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      onChanged: onChanged,
      maxLines: maxLines,
    );
  }

  Widget _buildDropdown({
    required IconData icon,
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primary),
          ),
        ),
        child: Text(
          date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Select Date',
          style: TextStyle(fontSize: 16),
        ),
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
            ),
            onChanged: (value) => newPerson = value,
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Add'),
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