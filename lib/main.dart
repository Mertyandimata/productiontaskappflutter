import 'package:etsu/screens/TaskManagementPage.dart';
import 'package:flutter/material.dart';
import 'utils/app_colors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Management App',
      theme: ThemeData(
        primarySwatch: AppColors.primarySwatch,
        scaffoldBackgroundColor: AppColors.backgroundLight,
      ),
      home: TaskManagementPage(),
    );
  }
}