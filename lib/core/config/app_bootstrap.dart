import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../data/repositories/firebase_auth_repository.dart';
import '../../data/repositories/firestore_class_repository.dart';
import '../../data/repositories/firestore_grade_repository.dart';
import '../../data/repositories/firestore_student_repository.dart';
import '../../data/repositories/firestore_subject_repository.dart';
import '../../data/repositories/in_memory_class_repository.dart';
import '../../data/repositories/in_memory_grade_repository.dart';
import '../../data/repositories/in_memory_student_repository.dart';
import '../../data/repositories/in_memory_subject_repository.dart';
import '../../data/repositories/mock_auth_repository.dart';
import '../../data/services/mock_supabase_storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/class_repository.dart';
import '../../domain/repositories/grade_repository.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/repositories/subject_repository.dart';
import 'app_config.dart';

class AppBootstrap {
  static Future<AppDependencies> createDependencies() async {
  final firebaseReady = await _ensureFirebaseReady();
  final authRepository = await _createAuthRepository(firebaseReady: firebaseReady);

  final useFirestore = AppConfig.useFirestoreData && firebaseReady;
  final classRepository = useFirestore
    ? FirestoreClassRepository()
    : InMemoryClassRepository();
  final studentRepository = useFirestore
    ? FirestoreStudentRepository()
    : InMemoryStudentRepository();
  final subjectRepository = useFirestore
    ? FirestoreSubjectRepository()
    : InMemorySubjectRepository();
  final gradeRepository = useFirestore
    ? FirestoreGradeRepository()
    : InMemoryGradeRepository();
    final storageService = MockSupabaseStorageService();

    return AppDependencies(
      authRepository: authRepository,
      studentRepository: studentRepository,
      classRepository: classRepository,
      subjectRepository: subjectRepository,
      gradeRepository: gradeRepository,
      storageService: storageService,
    );
  }

  static Future<AuthRepository> _createAuthRepository({
    required bool firebaseReady,
  }) async {
    if (AppConfig.useFirebaseAuth && firebaseReady) {
      return FirebaseAuthRepository.initialize(
        firebaseOptions: AppConfig.firebaseOptions,
      );
    }

    return MockAuthRepository();
  }

  static Future<bool> _ensureFirebaseReady() async {
    if (!AppConfig.useFirebaseAuth && !AppConfig.useFirestoreData) {
      return false;
    }

    if (Firebase.apps.isNotEmpty) {
      return true;
    }

    try {
      await Firebase.initializeApp(options: AppConfig.firebaseOptions);
      return true;
    } catch (error) {
      debugPrint('Firebase init failed. Fallback to in-memory data: $error');
      return false;
    }
  }
}

class AppDependencies {
  const AppDependencies({
    required this.authRepository,
    required this.studentRepository,
    required this.classRepository,
    required this.subjectRepository,
    required this.gradeRepository,
    required this.storageService,
  });

  final AuthRepository authRepository;
  final StudentRepository studentRepository;
  final ClassRepository classRepository;
  final SubjectRepository subjectRepository;
  final GradeRepository gradeRepository;
  final MockSupabaseStorageService storageService;
}
