import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tasks.dart';
import '../utils/app_colors.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        
        return GestureDetector(
          onTap: () => onCardSelected(task),
          child: Card(
            margin: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 8 : 16,
              vertical: isSmallScreen ? 6 : 8
            ),
            elevation: isSelected ? 4 : 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isSmallScreen),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  _buildFooter(isSmallScreen),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 14 : 16
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                'Started on ${DateFormat('MMM d, yyyy').format(task.startDate)}',
                style: TextStyle(
                  color: AppColors.mediumGreen,
                  fontSize: isSmallScreen ? 10 : 12
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit, size: isSmallScreen ? 18 : 20, color: AppColors.primary),
              onPressed: () {
                print('Edit button pressed for task: ${task.name}');
                onEditTask(task);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, size: isSmallScreen ? 18 : 20, color: AppColors.primary),
              onPressed: () {
                print('Delete button pressed for task: ${task.name}');
                onDeleteTask(task);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              _buildChip(task.department, Icons.business, isSmallScreen),
              SizedBox(width: isSmallScreen ? 4 : 8),
              _buildChip(task.plant, Icons.factory, isSmallScreen),
            ],
          ),
        ),
        _buildCompletionIndicator(isSmallScreen),
      ],
    );
  }

  Widget _buildChip(String label, IconData icon, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 6 : 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.veryLightGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isSmallScreen ? 12 : 14, color: AppColors.darkGreen),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: isSmallScreen ? 10 : 12, color: AppColors.darkGreen),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionIndicator(bool isSmallScreen) {
    return Container(
      width: isSmallScreen ? 80 : 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${(task.completionRate * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
          SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LinearProgressIndicator(
              value: task.completionRate,
              backgroundColor: AppColors.veryLightGreen,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: isSmallScreen ? 4 : 6,
            ),
          ),
          SizedBox(height: 2),
          Text(
            task.completionString,
            style: TextStyle(color: AppColors.mediumGreen, fontSize: isSmallScreen ? 8 : 10),
          ),
        ],
      ),
    );
  }
}