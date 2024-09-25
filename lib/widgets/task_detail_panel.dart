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
      width: MediaQuery.of(context).size.width * 0.4,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(-2, 0))],
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
            task.name,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.white, size: 20),
            onPressed: onClose,
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
          _buildDetailRow('Description', task.description),
          _buildDetailRow('Start Date', DateFormat('MMM d, yyyy').format(task.startDate)),
          if (task.dueDate != null)
            _buildDetailRow('Due Date', DateFormat('MMM d, yyyy').format(task.dueDate!)),
          _buildDetailRow('Department', task.department),
          _buildDetailRow('Plant', task.plant),
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
            children: task.peopleInvolved.map((person) => _buildPersonChip(person)).toList(),
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
          ...task.subTasks.map((subTask) => _buildSubTaskTile(subTask)),
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
            subTask.status = result;
            onTaskUpdated(task);
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
        // Implement create subtask functionality
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