import 'package:etsu/screens/TaskManagementPage.dart';
import 'package:flutter/material.dart';
import 'utils/app_colors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('Uygulama başlatılıyor...');
    return MaterialApp(
      title: 'Task Management App',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.backgroundLight,
      ),
      home: TaskManagementPage(),
    );
  }
}
