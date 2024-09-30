import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tasks.dart';
import '../utils/app_colors.dart';
import 'dart:html' as html;

class MainTaskCard extends StatelessWidget {
  final MainTask task;
  final Function(MainTask) onTaskUpdated;
  final Function(MainTask) onCardSelected;
  final Function(MainTask) onEditTask;
  final Function(MainTask) onDeleteTask;
  final bool isSelected;

  const MainTaskCard({
    Key? key,
    required this.task,
    required this.onTaskUpdated,
    required this.onCardSelected,
    required this.onEditTask,
    required this.onDeleteTask,
    required this.isSelected,
  }) : super(key: key);

  @override
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: () => onCardSelected(task),
    child: Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.name,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Started on ${DateFormat('MMM d, yyyy').format(task.startDate)}',
                        style: TextStyle(color: AppColors.mediumGreen, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, size: 20, color: AppColors.primary),
                      onPressed: () => onEditTask(task),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, size: 20, color: AppColors.primary),
                      onPressed: () => onDeleteTask(task),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildChip(task.department, Icons.business),
                    SizedBox(width: 8),
                    _buildChip(task.plant, Icons.factory),
                  ],
                ),
                _buildCompletionIndicator(),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.veryLightGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.darkGreen),
          SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.darkGreen)),
        ],
      ),
    );
  }

  Widget _buildCompletionIndicator() {
    return Container(
      width: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${(task.completionRate * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LinearProgressIndicator(
              value: task.completionRate,
              backgroundColor: AppColors.veryLightGreen,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
          SizedBox(height: 2),
          Text(
            task.completionString,
            style: TextStyle(color: AppColors.mediumGreen, fontSize: 10),
          ),
        ],
      ),
    );
  }
}