import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../domain/entities/app_user.dart';
import '../../../domain/entities/student.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/student_view_model.dart';
import 'student_detail_screen.dart';
import 'student_form_screen.dart';

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authUser = context.watch<AuthViewModel>().user;
    final canEdit = authUser?.role.canEditAcademicData ?? false;

    return Consumer<StudentViewModel>(
      builder: (context, vm, child) {
        return Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 220,
                  title: const Text('Quản lý sinh viên'),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF0F766E), Color(0xFF155E75)],
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Xin chào ${authUser?.displayName ?? 'bạn'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Có ${vm.filteredStudents.length}sinh viên đang hiển thị.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            hintText: 'Tìm theo tên, MSSV, email...',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: vm.setStudentSearchQuery,
                        ),
                        const SizedBox(height: 12),
                        _FilterPanel(vm: vm),
                      ],
                    ),
                  ),
                ),
                if (vm.isLoading)
                  SliverList.builder(
                    itemCount: 6,
                    itemBuilder: (context, index) => const _ShimmerCard(),
                  )
                else if (vm.filteredStudents.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(),
                  )
                else
                  SliverList.builder(
                    itemCount: vm.filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = vm.filteredStudents[index];
                      return _StudentCard(student: student);
                    },
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton.extended(
                onPressed: () {
                  if (!canEdit) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bạn không có quyền thêm sinh viên.'),
                      ),
                    );
                    return;
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const StudentFormScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Thêm SV'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({required this.vm});

  final StudentViewModel vm;

  @override
  Widget build(BuildContext context) {
    final classItems = [
      const DropdownMenuItem<String?>(
        value: null,
        child: Text('Tất cả lớp'),
      ),
      ...vm.classes.map(
        (classRoom) => DropdownMenuItem<String?>(
          value: classRoom.id,
          child: Text(classRoom.name),
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String?>(
          initialValue: vm.classFilterId,
          decoration: const InputDecoration(
            labelText: 'Lọc theo lớp',
            prefixIcon: Icon(Icons.filter_list),
          ),
          items: classItems,
          onChanged: vm.setClassFilterId,
        ),
      ],
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    final vm = context.read<StudentViewModel>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          leading: Hero(
            tag: 'student-avatar-${student.id}',
            child: CircleAvatar(
              backgroundImage: student.hasAvatar
                  ? NetworkImage(student.avatarUrl!)
                  : null,
              child: student.hasAvatar
                  ? null
                  : Text(
                      student.displayInitial,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
          title: Text(student.fullName),
          subtitle: Text(
            '${student.mssv} • ${vm.classNameOf(student.classId)}',
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => StudentDetailScreen(studentId: student.id),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1F2937)
            : const Color(0xFFE4E4E7),
        highlightColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF374151)
            : const Color(0xFFF4F4F5),
        child: Container(
          height: 78,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 72),
            const SizedBox(height: 12),
            Text(
              'Chưa có sinh viên phù hợp',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy thử bỏ bớt bộ lọc hoặc thêm sinh viên mới để bắt đầu.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
