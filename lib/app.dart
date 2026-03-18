import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/app_bootstrap.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/auth/auth_gate.dart';
import 'presentation/viewmodels/auth_view_model.dart';
import 'presentation/viewmodels/class_provider.dart';
import 'presentation/viewmodels/grade_provider.dart';
import 'presentation/viewmodels/settings_view_model.dart';
import 'presentation/viewmodels/student_view_model.dart';
import 'presentation/viewmodels/subject_provider.dart';

class StudentManagerApp extends StatelessWidget {
  const StudentManagerApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsViewModel()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              AuthViewModel(authRepository: dependencies.authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ClassProvider(
            classRepository: dependencies.classRepository,
            studentRepository: dependencies.studentRepository,
          )..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => SubjectProvider(
            subjectRepository: dependencies.subjectRepository,
          )..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              GradeProvider(gradeRepository: dependencies.gradeRepository)
                ..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => StudentViewModel(
            studentRepository: dependencies.studentRepository,
            classRepository: dependencies.classRepository,
            subjectRepository: dependencies.subjectRepository,
            gradeRepository: dependencies.gradeRepository,
            storageService: dependencies.storageService,
          )..initialize(),
        ),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Student Manager',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}
