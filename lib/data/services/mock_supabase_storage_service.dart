class MockSupabaseStorageService {
  Future<String> uploadStudentAvatar(String studentId, String fileName) async {
    final time = DateTime.now().millisecondsSinceEpoch;
    return 'https://supabase.mock/storage/v1/object/public/student-avatars/$studentId-$time-$fileName';
  }
}
