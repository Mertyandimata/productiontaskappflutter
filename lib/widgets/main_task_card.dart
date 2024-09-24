import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tasks.dart';
import '../utils/app_colors.dart';

class MainTaskCard extends StatelessWidget {
  final MainTask task;
  final Function(MainTask) onTaskUpdated;
  final Function(MainTask) onCardSelected;
  final bool isSelected;

  const MainTaskCard({
    Key? key,
    required this.task,
    required this.onTaskUpdated,
    required this.onCardSelected,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onCardSelected(task),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Started on ${DateFormat('MMM d, yyyy').format(task.startDate)}',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _buildChip(task.department, Icons.business),
                      SizedBox(width: 8),
                      _buildChip(task.plant, Icons.factory),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),
              _buildCompletionIndicator(),
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
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black),
          SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildCompletionIndicator() {
    return Container(
      width: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircularProgressIndicator(
            value: task.completionRate,
            backgroundColor: AppColors.backgroundLight,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            strokeWidth: 8,
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(task.completionRate * 100).toStringAsFixed(0)}%',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              Text(
                task.completionString,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
