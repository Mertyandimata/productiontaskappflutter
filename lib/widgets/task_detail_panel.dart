import 'dart:convert';
import 'dart:io';
import 'dart:html' as html;
import 'package:etsu/widgets/TaskDetailHtmlGenerator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/tasks.dart';
import '../utils/app_colors.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:ui' as ui;





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
  final GlobalKey _globalKey = GlobalKey();


@override
Widget build(BuildContext context) {
  // Ekran genişliğine göre panel genişliğini ayarla
  double panelWidth = MediaQuery.of(context).size.width;
  if (MediaQuery.of(context).size.width > 1200) {
    panelWidth = 1200; // Geniş ekranlar için maksimum genişlik
  } else if (MediaQuery.of(context).size.width > 600) {
    panelWidth = MediaQuery.of(context).size.width * 0.8; // Orta boy ekranlar için
  }

  return RepaintBoundary(
    key: _globalKey,
    child: Container(
      width: panelWidth,
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
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
          Expanded(
            child: Text(
              widget.task.name,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width > 600 ? 20 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.print, color: Colors.white, size: 24),
                onPressed: _generatePrintView,
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 24),
                onPressed: widget.onClose,
              ),
            ],
          ),
        ],
      ),
    );
  }


void _generatePrintView() {
  TaskDetailHtmlGenerator.generateAndOpenHtml(widget.task);
}



void _printTaskDetails() {
  print('Task Name: ${widget.task.name}');
  print('Description: ${widget.task.description}');
  print('Start Date: ${DateFormat('MMM d, yyyy').format(widget.task.startDate)}');
  
  if (widget.task.dueDate != null) {
    print('Due Date: ${DateFormat('MMM d, yyyy').format(widget.task.dueDate!)}');
  }
  
  print('Department: ${widget.task.department}');
  print('Plant: ${widget.task.plant}');
  print('People Involved: ${widget.task.peopleInvolved.join(', ')}');

  print('Subtasks:');
  widget.task.subTasks.forEach((subTask) {
    print('  - ${subTask.name}');
    print('    Assigned to: ${subTask.assignedTo}');
    print('    Due Date: ${DateFormat('MMM d, yyyy').format(subTask.dueDate)}');
    print('    Status: ${_getStatusString(subTask.status)}');
    if (subTask.note != null && subTask.note!.isNotEmpty) {
      print('    Note: ${subTask.note}');
    }
  });

  if (widget.task.imageData != null) {
    print('Task has an image attached.');
  } else {
    print('No image attached to the task.');
  }
}

Widget _buildDetailSection() {
  return Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              // Geniş ekranlar için yan yana layout
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
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
                  SizedBox(width: 32),
                  Expanded(
                    flex: 1,
                    child: widget.task.imageData != null
                        ? _buildTaskImage(widget.task.imageData!)
                        : _buildImageUpload(
                            imageData: null,
                            onImageSelected: (data) {
                              setState(() {
                                widget.task.imageData = data;
                                widget.onTaskUpdated(widget.task);
                              });
                            },
                          ),
                  ),
                ],
              );
            } else {
              // Dar ekranlar için üst üste layout
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
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
                  SizedBox(height: 16),
                  widget.task.imageData != null
                      ? _buildTaskImage(widget.task.imageData!)
                      : _buildImageUpload(
                          imageData: null,
                          onImageSelected: (data) {
                            setState(() {
                              widget.task.imageData = data;
                              widget.onTaskUpdated(widget.task);
                            });
                          },
                        ),
                ],
              );
            }
          },
        ),
      ],
    ),
  );
}


Widget _buildTaskImage(String imageData) {
  return GestureDetector(
    onTap: () => _showEnlargedImage(imageData),
    child: Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: MemoryImage(base64Decode(imageData)),
          fit: BoxFit.cover,
        ),
      ),
    ),
  );
}

void _showEnlargedImage(String imageData) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Stack(
          children: [
            Image.memory(
              base64Decode(imageData),
              fit: BoxFit.contain,
            ),
            Positioned(
              right: 0,
              top: 0,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      );
    },
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'People Involved',
                style: TextStyle(
                  fontSize: constraints.maxWidth > 600 ? 18 : 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: widget.task.peopleInvolved.map((person) => _buildPersonChip(person, constraints)).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

Widget _buildPersonChip(String person, BoxConstraints constraints) {
    double fontSize = constraints.maxWidth > 600 ? 14 : 12;
    double avatarRadius = constraints.maxWidth > 600 ? 14 : 10;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.veryLightGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: AppColors.primary,
            child: Text(person[0], style: TextStyle(fontSize: fontSize, color: Colors.white)),
          ),
          SizedBox(width: 8),
          Text(person, style: TextStyle(fontSize: fontSize, color: AppColors.textDark)),
        ],
      ),
    );
  }

 Widget _buildSubtasksSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtasks',
                    style: TextStyle(
                      fontSize: constraints.maxWidth > 600 ? 18 : 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  _buildCreateSubtaskButton(constraints),
                ],
              ),
              SizedBox(height: 16),
              ...widget.task.subTasks.map((subTask) => _buildSubTaskTile(subTask, constraints)),
            ],
          ),
        );
      },
    );
  }
Widget _buildSubTaskTile(SubTask subTask, BoxConstraints constraints) {
  double fontSize = constraints.maxWidth > 600 ? 14 : 12;
  
  return Container(
    margin: EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: AppColors.almostWhite,
      borderRadius: BorderRadius.circular(8),
    ),
    child: ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _getStatusIcon(subTask.status),
          SizedBox(width: 8),
          if (subTask.imageData != null)
            Container(
              width: constraints.maxWidth > 600 ? 50 : 40,
              height: constraints.maxWidth > 600 ? 50 : 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: MemoryImage(base64Decode(subTask.imageData!)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subTask.name, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500)),
          SizedBox(height: 2),
          Text(
            '${subTask.assignedTo} • Due: ${DateFormat('MMM d').format(subTask.dueDate)}',
            style: TextStyle(fontSize: fontSize - 2),
          ),
        ],
      ),
      subtitle: subTask.note != null && subTask.note!.isNotEmpty
        ? Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              subTask.note!,
              style: TextStyle(fontSize: fontSize - 3, color: AppColors.textDark),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          )
        : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit, size: constraints.maxWidth > 600 ? 24 : 18),
            onPressed: () => _handleEditSubTask(subTask),
          ),
          IconButton(
            icon: Icon(Icons.delete, size: constraints.maxWidth > 600 ? 24 : 18),
            onPressed: () => _handleDeleteSubTask(subTask),
          ),
          PopupMenuButton<SubTaskStatus>(
            icon: Icon(Icons.more_vert, size: constraints.maxWidth > 600 ? 24 : 18),
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
                  child: Text(_getStatusString(status), style: TextStyle(fontSize: fontSize)),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

void _generateAndDownloadPdf() async {
    final pdf = pw.Document();

    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  widget.task.name,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    font: fontBold,
                    color: PdfColors.blue,
                  ),
                ),
                pw.SizedBox(height: 16),
                _buildPdfDetailRow('Description', widget.task.description, fontRegular),
                _buildPdfDetailRow('Start Date', DateFormat('MMM d, yyyy').format(widget.task.startDate), fontRegular),
                if (widget.task.dueDate != null)
                  _buildPdfDetailRow('Due Date', DateFormat('MMM d, yyyy').format(widget.task.dueDate!), fontRegular),
                _buildPdfDetailRow('Department', widget.task.department, fontRegular),
                _buildPdfDetailRow('Plant', widget.task.plant, fontRegular),
                pw.SizedBox(height: 20),
                pw.Text(
                  'People Involved',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    font: fontBold,
                    color: PdfColors.blueGrey,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Bullet(
                  text: widget.task.peopleInvolved.join(', '),
                  style: pw.TextStyle(fontSize: 14, font: fontRegular),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Subtasks',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    font: fontBold,
                    color: PdfColors.blueGrey,
                  ),
                ),
                ...widget.task.subTasks.map((subTask) => _buildPdfSubTask(subTask, fontRegular, fontBold)),
                if (widget.task.imageData != null) pw.SizedBox(height: 16),
                if (widget.task.imageData != null) _buildPdfImage(widget.task.imageData!),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  pw.Widget _buildPdfDetailRow(String label, String value, pw.Font font) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '$label: ',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: font),
        ),
        pw.Expanded(
          child: pw.Text(value, style: pw.TextStyle(font: font)),
        ),
      ],
    );
  }

  pw.Widget _buildPdfSubTask(SubTask subTask, pw.Font fontRegular, pw.Font fontBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            subTask.name,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, font: fontBold),
          ),
          pw.Text('Assigned to: ${subTask.assignedTo}', style: pw.TextStyle(font: fontRegular)),
          pw.Text('Due Date: ${DateFormat('MMM d, yyyy').format(subTask.dueDate)}', style: pw.TextStyle(font: fontRegular)),
          pw.Text('Status: ${_getStatusString(subTask.status)}', style: pw.TextStyle(font: fontRegular)),
          if (subTask.note != null && subTask.note!.isNotEmpty)
            pw.Text('Note: ${subTask.note}', style: pw.TextStyle(font: fontRegular)),
        ],
      ),
    );
  }

  pw.Widget _buildPdfImage(String imageData) {
    final image = pw.MemoryImage(base64Decode(imageData));
    return pw.Container(
      width: 150,
      height: 150,
      decoration: pw.BoxDecoration(
        image: pw.DecorationImage(image: image, fit: pw.BoxFit.cover),
      ),
    );
  }

 Widget _buildCreateSubtaskButton(BoxConstraints constraints) {
    return TextButton.icon(
      onPressed: _handleCreateSubTask,
      icon: Icon(Icons.add, size: constraints.maxWidth > 600 ? 20 : 16, color: AppColors.primary),
      label: Text(
        'Add',
        style: TextStyle(
          fontSize: constraints.maxWidth > 600 ? 14 : 12,
          color: AppColors.primary,
        ),
      ),
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
  _showSubTaskDialog();
}
  void _handleEditSubTask(SubTask subTask) {
  _showSubTaskDialog(subTask: subTask);
}

  void _showSubTaskDialog({SubTask? subTask}) {
    String name = subTask?.name ?? '';
    String? assignedTo = subTask?.assignedTo;
    DateTime dueDate = subTask?.dueDate ?? DateTime.now().add(Duration(days: 7));
    String note = subTask?.note ?? '';
    SubTaskStatus status = subTask?.status ?? SubTaskStatus.backlog;
    String? imageData = subTask?.imageData;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(subTask == null ? 'Create New Subtask' : 'Edit Subtask'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) => name = value,
                      decoration: InputDecoration(labelText: 'Subtask Name'),
                      controller: TextEditingController(text: name),
                    ),
                    DropdownButtonFormField<String>(
                      value: assignedTo,
                      items: widget.task.peopleInvolved.map((String person) {
                        return DropdownMenuItem<String>(
                          value: person,
                          child: Text(person),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          assignedTo = newValue;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Assigned To'),
                    ),
                    ListTile(
                      title: Text('Due Date'),
                      subtitle: Text(DateFormat('MMM d, yyyy').format(dueDate)),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: dueDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        );
                        if (picked != null && picked != dueDate) {
                          setState(() {
                            dueDate = picked;
                          });
                        }
                      },
                    ),
                    TextField(
                      onChanged: (value) => note = value,
                      decoration: InputDecoration(labelText: 'Note'),
                      controller: TextEditingController(text: note),
                      maxLines: 3,
                    ),
                    DropdownButtonFormField<SubTaskStatus>(
                      value: status,
                      items: SubTaskStatus.values.map((SubTaskStatus status) {
                        return DropdownMenuItem<SubTaskStatus>(
                          value: status,
                          child: Text(_getStatusString(status)),
                        );
                      }).toList(),
                      onChanged: (SubTaskStatus? newValue) {
                        setState(() {
                          status = newValue!;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Status'),
                    ),
                    SizedBox(height: 16),
                    _buildImageUpload(
                      imageData: imageData,
                      onImageSelected: (data) => setState(() => imageData = data),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text(subTask == null ? 'Create' : 'Save'),
                  onPressed: () {
                    if (name.isNotEmpty && assignedTo != null) {
                      SubTask newSubTask = SubTask(
                        id: subTask?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        assignedTo: assignedTo!,
                        dueDate: dueDate,
                        note: note,
                        status: status,
                        imageData: imageData, mainTaskId: '',
                      );
                      setState(() {
                        if (subTask == null) {
                          widget.task.subTasks.add(newSubTask);
                        } else {
                          int index = widget.task.subTasks.indexWhere((task) => task.id == subTask.id);
                          if (index != -1) {
                            widget.task.subTasks[index] = newSubTask;
                          }
                        }
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
      },
    );
  }
  
   Widget _buildImageUpload({String? imageData, required Function(String?) onImageSelected}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Task Image',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
      SizedBox(height: 8),
      InkWell(
        onTap: () async {
          final html.FileUploadInputElement input = html.FileUploadInputElement()..accept = 'image/*';
          input.click();

          input.onChange.listen((event) {
            final file = input.files!.first;
            final reader = html.FileReader();

            reader.onLoadEnd.listen((event) {
              setState(() {
                final result = reader.result as String;
                final base64Image = result.split(',').last;
                onImageSelected(base64Image);
              });
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
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    base64Decode(imageData),
                    fit: BoxFit.cover,
                  ),
                )
              : Center(
                  child: Icon(
                    Icons.add_photo_alternate,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
        ),
      ),
    ],
  );
}



   
   void _handleDeleteSubTask(SubTask subTask) {




  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Delete Subtask'),
        content: Text('Are you sure you want to delete this subtask?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () {
              setState(() {
                widget.task.subTasks.removeWhere((task) => task.id == subTask.id);
                widget.onTaskUpdated(widget.task);
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
} }