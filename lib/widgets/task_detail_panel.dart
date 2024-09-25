import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/tasks.dart';
import '../utils/app_colors.dart';

class TaskDetailPanel extends StatefulWidget {
  final MainTask task;
  final Function() onClose;
  final Function(MainTask) onTaskUpdated;

  const TaskDetailPanel({
    Key? key,
    required this.task,
    required this.onClose,
    required this.onTaskUpdated,
  }) : super(key: key);

  @override
  _TaskDetailPanelState createState() => _TaskDetailPanelState();
}

class _TaskDetailPanelState extends State<TaskDetailPanel> {
  int touchedIndex = -1;
@override
Widget build(BuildContext context) {
  return Container(
    width: MediaQuery.of(context).size.width * 1,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        bottomLeft: Radius.circular(20),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 5,
          offset: Offset(-2, 0),
        ),
      ],
    ),
    child: Column(
      children: [
        _buildHeader(),
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 8),
            children: [
              _buildDetailSection(),
              _buildDivider(),
              _buildPeopleInvolvedSection(),
              _buildDivider(),
              _buildSubtasksSection(),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.task.name,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.white, size: 20),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Details',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Description', widget.task.description),
                      _buildDetailRow('Start Date', DateFormat('MMM d, yyyy').format(widget.task.startDate)),
                      if (widget.task.dueDate != null)
                        _buildDetailRow('Due Date', DateFormat('MMM d, yyyy').format(widget.task.dueDate!)),
                      _buildDetailRow('Department', widget.task.department),
                      _buildDetailRow('Plant', widget.task.plant),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildStatusDonutChart(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.mediumGreen),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 12, color: AppColors.textDark)),
          ),
        ],
      ),
    );
  }

 Widget _buildStatusDonutChart() {
    final Map<SubTaskStatus, int> statusCounts = {
      for (var status in SubTaskStatus.values) status: 0
    };
    for (var subTask in widget.task.subTasks) {
      statusCounts[subTask.status] = (statusCounts[subTask.status] ?? 0) + 1;
    }

    final bool allZero = statusCounts.values.every((count) => count == 0);

    return AspectRatio(
      aspectRatio: 1.3,
      child: Column(
        children: <Widget>[
          Expanded(
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 0,
                centerSpaceRadius: 0,
                sections: allZero ? _getDefaultSections() : showingSections(statusCounts),
              ),
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _buildLegends(statusCounts),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getDefaultSections() {
    return SubTaskStatus.values.map((status) {
      return PieChartSectionData(
        color: _getStatusColor(status),
        value: 1,
        title: '',
        radius: 50,
        titleStyle: TextStyle(fontSize: 0),
      );
    }).toList();
  }

  List<PieChartSectionData> showingSections(Map<SubTaskStatus, int> statusCounts) {
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 110.0 : 100.0;
      final widgetSize = isTouched ? 55.0 : 40.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      final status = SubTaskStatus.values[i];
      final value = statusCounts[status]!.toDouble();

      return PieChartSectionData(
        color: _getStatusColor(status),
        value: value == 0 ? 1 : value, // Eğer değer 0 ise, 1 olarak ayarla
        title: value == 0 ? '' : value.toStringAsFixed(0),
        radius: radius,
        titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white, shadows: shadows),
      );
    });
  }

  List<Widget> _buildLegends(Map<SubTaskStatus, int> statusCounts) {
    return SubTaskStatus.values.map((status) {
      final isSelected = SubTaskStatus.values.indexOf(status) == touchedIndex;
      return _buildIndicator(
        color: _getStatusColor(status),
        text: '${_getStatusString(status)}: ${statusCounts[status]}',
        isSquare: false,
        size: 6, // Legend noktalarının boyutunu 6 olarak ayarladık
        textColor: isSelected ? Colors.black : Colors.grey,
      );
    }).toList();
  }

  Widget _buildIndicator({
    required Color color,
    required String text,
    required bool isSquare,
    double size = 6, // Varsayılan boyutu 6 olarak ayarladık
    Color textColor = Colors.grey,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 6,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        )
      ],
    );
  }
  Color _getStatusColor(SubTaskStatus status) {
    switch (status) {
      case SubTaskStatus.backlog:
        return Colors.grey;
      case SubTaskStatus.waiting:
        return AppColors.chartWaiting;
      case SubTaskStatus.inProgress:
        return AppColors.chartInProgress;
      case SubTaskStatus.done:
        return AppColors.chartDone;
    }
  }

  String _getStatusString(SubTaskStatus status) {
    switch (status) {
      case SubTaskStatus.backlog:
        return 'Backlog';
      case SubTaskStatus.inProgress:
        return 'In Progress';
      case SubTaskStatus.waiting:
        return 'Waiting';
      case SubTaskStatus.done:
        return 'Done';
    }
  }

  Widget _buildPeopleInvolvedSection() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'People Involved',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.task.peopleInvolved.map((person) => _buildPersonChip(person)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonChip(String person) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.veryLightGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: AppColors.primary,
            child: Text(person[0], style: TextStyle(fontSize: 10, color: Colors.white)),
          ),
          SizedBox(width: 6),
          Text(person, style: TextStyle(fontSize: 12, color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _buildSubtasksSection() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtasks',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              _buildCreateSubtaskButton(),
            ],
          ),
          SizedBox(height: 8),
          ...widget.task.subTasks.map((subTask) => _buildSubTaskTile(subTask)),
        ],
      ),
    );
  }

  Widget _buildSubTaskTile(SubTask subTask) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.almostWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: _getStatusIcon(subTask.status),
        title: Text(subTask.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        subtitle: Text(
          '${subTask.assignedTo} • Due: ${DateFormat('MMM d').format(subTask.dueDate)}',
          style: TextStyle(fontSize: 11),
        ),
        trailing: PopupMenuButton<SubTaskStatus>(
          icon: Icon(Icons.more_vert, size: 18),
          onSelected: (SubTaskStatus result) {
            setState(() {
              subTask.status = result;
              widget.onTaskUpdated(widget.task);
            });
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<SubTaskStatus>>[
            for (var status in SubTaskStatus.values)
              PopupMenuItem<SubTaskStatus>(
                value: status,
                child: Text(_getStatusString(status), style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateSubtaskButton() {
    return TextButton.icon(
      onPressed: () {
        // TODO: Implement create subtask functionality
      },
      icon: Icon(Icons.add, size: 16, color: AppColors.primary),
      label: Text('Add', style: TextStyle(fontSize: 12, color: AppColors.primary)),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: AppColors.veryLightGreen);
  }
Widget _getStatusIcon(SubTaskStatus status) {
    IconData iconData;
    Color color;

    switch (status) {
      case SubTaskStatus.backlog:
        iconData = Icons.watch_later;
        color = Colors.grey;
        break;
      case SubTaskStatus.inProgress:
        iconData = Icons.play_circle_outline;
        color = Colors.blue;
        break;
      case SubTaskStatus.waiting:
        iconData = Icons.pause_circle_outline;
        color = Colors.orange;
        break;
      case SubTaskStatus.done:
        iconData = Icons.check_circle_outline;
        color = Colors.green;
        break;
    }

    return Icon(iconData, color: color, size: 18);
  }

  // Eksik olan diğer fonksiyonlar:

  void _handleSubTaskStatusChange(SubTask subTask, SubTaskStatus newStatus) {
    setState(() {
      subTask.status = newStatus;
      widget.onTaskUpdated(widget.task);
    });
  }

  void _handleCreateSubTask() {
    // Bu fonksiyon, yeni bir alt görev oluşturma işlemini gerçekleştirecek
    // Örnek bir implementasyon:
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newSubTaskName = '';
        return AlertDialog(
          title: Text('Create New Subtask'),
          content: TextField(
            onChanged: (value) {
              newSubTaskName = value;
            },
            decoration: InputDecoration(hintText: "Enter subtask name"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Create'),
              onPressed: () {
                if (newSubTaskName.isNotEmpty) {
                  setState(() {
                    widget.task.subTasks.add(SubTask(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: newSubTaskName,
                      status: SubTaskStatus.backlog,
                      assignedTo: 'Unassigned',
                      dueDate: DateTime.now().add(Duration(days: 7)), note: '',
                    ));
                    widget.onTaskUpdated(widget.task);
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _handleEditSubTask(SubTask subTask) {
    // Bu fonksiyon, mevcut bir alt görevi düzenleme işlemini gerçekleştirecek
    // Örnek bir implementasyon:
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String editedSubTaskName = subTask.name;
        return AlertDialog(
          title: Text('Edit Subtask'),
          content: TextField(
            onChanged: (value) {
              editedSubTaskName = value;
            },
            decoration: InputDecoration(hintText: "Enter new subtask name"),
            controller: TextEditingController(text: subTask.name),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                if (editedSubTaskName.isNotEmpty) {
                  setState(() {
                    subTask.name = editedSubTaskName;
                    widget.onTaskUpdated(widget.task);
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _handleDeleteSubTask(SubTask subTask) {
    // Bu fonksiyon, bir alt görevi silme işlemini gerçekleştirecek
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Subtask'),
          content: Text('Are you sure you want to delete this subtask?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                setState(() {
                  widget.task.subTasks.remove(subTask);
                  widget.onTaskUpdated(widget.task);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }  }