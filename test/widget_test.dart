import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:quanlysinhvien/app.dart';
import 'package:quanlysinhvien/core/config/app_bootstrap.dart';
import 'package:quanlysinhvien/data/repositories/in_memory_class_repository.dart';
import 'package:quanlysinhvien/data/repositories/in_memory_grade_repository.dart';
import 'package:quanlysinhvien/data/repositories/in_memory_student_repository.dart';
import 'package:quanlysinhvien/data/repositories/in_memory_subject_repository.dart';
import 'package:quanlysinhvien/data/repositories/mock_auth_repository.dart';
import 'package:quanlysinhvien/data/services/mock_supabase_storage_service.dart';

void main() {
  testWidgets('renders sign in screen by default', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      StudentManagerApp(
        dependencies: AppDependencies(
          authRepository: MockAuthRepository(),
          studentRepository: InMemoryStudentRepository(),
          classRepository: InMemoryClassRepository(),
          subjectRepository: InMemorySubjectRepository(),
          gradeRepository: InMemoryGradeRepository(),
          storageService: MockSupabaseStorageService(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Student Manager'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsWidgets);
  });
}
