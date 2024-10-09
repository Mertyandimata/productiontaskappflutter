import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/tasks.dart';
import 'dart:html' as html;
import '../utils/app_colors.dart';
import 'package:flutter/services.dart' show ByteData, Color, Uint8List, rootBundle;

class TaskDetailHtmlGenerator {
  static void generateAndOpenHtml(MainTask task) async {
    final String currentDate = DateFormat('d MMMM yyyy').format(DateTime.now());
    final String logoBase64 = base64Encode(await _getLogoBytes());
    
    final String htmlContent = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${task.name} - Task Details</title>
    <style>
        @page {
            size: A4;
            margin: 0;
        }
        :root {
            --dark-green: ${_colorToHex(AppColors.darkGreen)};
            --medium-green: ${_colorToHex(AppColors.mediumGreen)};
            --light-green: ${_colorToHex(AppColors.lightGreen)};
            --very-light-green: ${_colorToHex(AppColors.veryLightGreen)};
            --almost-white: ${_colorToHex(AppColors.almostWhite)};
        }
        body {
            font-family: Arial, sans-serif;
            line-height: 1.4;
            color: var(--dark-green);
            max-width: 210mm; /* A4 width */
            margin: 0 auto;
            padding: 20px;
            background-color: var(--almost-white);
            font-size: 12px;
        }
        .header {
            background-color: var(--dark-green);
            color: var(--almost-white);
            padding: 15px;
            border-radius: 8px 8px 0 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .logo {
            height: 40px;
        }
        .content {
            padding: 15px;
            border: 1px solid var(--light-green);
            border-top: none;
            border-radius: 0 0 8px 8px;
            background-color: white;
        }
        h1 {
            margin: 0;
            font-size: 20px;
        }
        h2 {
            color: var(--medium-green);
            border-bottom: 2px solid var(--medium-green);
            padding-bottom: 5px;
            margin-top: 20px;
            font-size: 16px;
        }
        .task-details {
            display: flex;
            gap: 20px;
            margin-top: 15px;
        }
        .task-info {
            flex: 2;
        }
        .task-image-container {
            flex: 1;
            max-width: 200px;
        }
        .task-image {
            max-width: 100%;
            height: auto;
            border-radius: 4px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
        .subtask-image {
            max-width: 100px;
            height: auto;
            border-radius: 4px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
        .detail-row {
            margin-bottom: 8px;
            display: flex;
        }
        .detail-label {
            font-weight: bold;
            width: 100px;
            flex-shrink: 0;
        }
        .detail-value {
            flex-grow: 1;
        }
        .people-involved {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: 10px;
        }
        .person-chip {
            background-color: var(--very-light-green);
            color: var(--dark-green);
            padding: 3px 10px;
            border-radius: 12px;
            font-size: 11px;
        }
        .subtask {
            background-color: var(--almost-white);
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 10px;
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
        }
        .subtask-image-container {
            width: 100px;
            flex-shrink: 0;
            padding-left: 15px; /* Add left padding */
        }
        .subtask-content {
            display: flex;
            flex-direction: column;
            flex: 1;
            min-width: 0; /* Allow content to shrink if necessary */
        }
        .subtask-info {
            flex: 1;
        }
        .subtask h3 {
            margin-top: 0;
            color: var(--medium-green);
            font-size: 14px;
        }
        .note {
            margin-top: 8px;
            font-style: italic;
            width: 100%;
            word-wrap: break-word;
        }
        @media print {
            body {
                width: 210mm;
                height: 297mm;
                padding: 0;
                background-color: white;
            }
            .header {
                background-color: var(--dark-green) !important;
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
            }
            .content {
                border: none;
            }
            .task-image {
                max-width: 200px;
            }
            .subtask-image {
                max-width: 100px;
            }
            .subtask {
                page-break-inside: avoid;
            }
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>${task.name}</h1>
        <div style="display: flex; align-items: center; gap: 15px;">
            <span>${currentDate}</span>
            <img src="data:image/png;base64,${logoBase64}" alt="Logo" class="logo">
        </div>
    </div>
    <div class="content">
        <h2>Task Details</h2>
        <div class="task-details">
            <div class="task-info">
                <div class="detail-row">
                    <span class="detail-label">Description:</span>
                    <span class="detail-value">${task.description}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Start Date:</span>
                    <span class="detail-value">${DateFormat('MMM d, yyyy').format(task.startDate)}</span>
                </div>
                ${task.dueDate != null ? '''
                <div class="detail-row">
                    <span class="detail-label">Due Date:</span>
                    <span class="detail-value">${DateFormat('MMM d, yyyy').format(task.dueDate!)}</span>
                </div>
                ''' : ''}
                <div class="detail-row">
                    <span class="detail-label">Department:</span>
                    <span class="detail-value">${task.department}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Plant:</span>
                    <span class="detail-value">${task.plant}</span>
                </div>
            </div>
            ${task.imageData != null ? '''
            <div class="task-image-container">
                <img src="data:image/png;base64,${task.imageData}" alt="Task Image" class="task-image">
            </div>
            ''' : ''}
        </div>
        
        <h2>People Involved</h2>
        <div class="people-involved">
            ${task.peopleInvolved.map((person) => '<div class="person-chip">$person</div>').join('')}
        </div>
        
        <h2>Subtasks</h2>
        ${task.subTasks.map((subTask) => '''
            <div class="subtask">
                <div class="subtask-content">
                    <div class="subtask-info">
                        <h3>${subTask.name}</h3>
                        <div class="detail-row">
                            <span class="detail-label">Assigned to:</span>
                            <span class="detail-value">${subTask.assignedTo}</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Due Date:</span>
                            <span class="detail-value">${DateFormat('MMM d, yyyy').format(subTask.dueDate)}</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Status:</span>
                            <span class="detail-value">${_getStatusString(subTask.status)}</span>
                        </div>
                    </div>
                    ${subTask.note != null && subTask.note!.isNotEmpty ? '''
                    <div class="note">
                        <strong>Notes:</strong> ${subTask.note}
                    </div>
                    ''' : ''}
                </div>
                ${subTask.imageData != null ? '''
                <div class="subtask-image-container">
                    <img src="data:image/png;base64,${subTask.imageData}" alt="Subtask Image" class="subtask-image">
                </div>
                ''' : ''}
            </div>
        ''').join('')}
    </div>
</body>
</html>
    ''';

    // HTML içeriğini yeni bir sekmede aç
    final blob = html.Blob([htmlContent], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, 'Task Details');
  }

  static String _getStatusString(SubTaskStatus status) {
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

  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }

  static Future<Uint8List> _getLogoBytes() async {
    ByteData data = await rootBundle.load('assets/logo2.png');
    return data.buffer.asUint8List();
  }
}