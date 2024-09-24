// task_detail_panel.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tasks.dart';
import '../utils/app_colors.dart';

class TaskDetailPanel extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection(),
                    SizedBox(height: 16),
                    _buildPeopleInvolvedSection(),
                    SizedBox(height: 16),
                    _buildSubtasksSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            task.name,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        _buildDetailRow('Description', task.description),
        _buildDetailRow('Start Date', DateFormat('MMM d, yyyy').format(task.startDate)),
        if (task.dueDate != null)
          _buildDetailRow('Due Date', DateFormat('MMM d, yyyy').format(task.dueDate!)),
        _buildDetailRow('Department', task.department),
        _buildDetailRow('Plant', task.plant),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildPeopleInvolvedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'People Involved',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: task.peopleInvolved.map((person) => Chip(
            avatar: CircleAvatar(
              child: Text(person[0]),
              backgroundColor: AppColors.primary.withOpacity(0.2),
            ),
            label: Text(person),
            backgroundColor: AppColors.backgroundLight,
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildSubtasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subtasks',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ...task.subTasks.map((subTask) => _buildSubTaskTile(subTask)),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            // Implement create subtask functionality
          },
          child: Text('Create Subtask'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildSubTaskTile(SubTask subTask) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: _getStatusIcon(subTask.status),
      title: Text(subTask.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Assigned to: ${subTask.assignedTo}'),
          Text('Due: ${DateFormat('MMM d, yyyy').format(subTask.dueDate)}'),
          Text('Note: ${subTask.note}'),
        ],
      ),
      trailing: PopupMenuButton<SubTaskStatus>(
        onSelected: (SubTaskStatus result) {
          subTask.status = result;
          onTaskUpdated(task);
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<SubTaskStatus>>[
          for (var status in SubTaskStatus.values)
            PopupMenuItem<SubTaskStatus>(
              value: status,
              child: Text(_getStatusString(status)),
            ),
        ],
      ),
    );
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

    return Icon(iconData, color: color);
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
}
