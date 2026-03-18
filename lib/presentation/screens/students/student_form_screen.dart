import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/app_user.dart';
import '../../../domain/entities/student.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/class_provider.dart';
import '../../viewmodels/student_view_model.dart';

class StudentFormScreen extends StatefulWidget {
  const StudentFormScreen({this.initialStudent, super.key});

  final Student? initialStudent;

  bool get isEditing => initialStudent != null;

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _mssvController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  DateTime? _birthDate;
  String? _classId;

  @override
  void initState() {
    super.initState();
    final student = widget.initialStudent;
    if (student != null) {
      _mssvController.text = student.mssv;
      _nameController.text = student.fullName;
      _emailController.text = student.email;
      _birthDate = student.birthDate;
      _classId = student.classId;
    }
  }

  @override
  void dispose() {
    _mssvController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 20),
      firstDate: DateTime(1980),
      lastDate: DateTime(now.year - 15),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _birthDate = selectedDate;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_birthDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ngày sinh.')));
      return;
    }
    if (_classId == null || _classId!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn lớp học.')));
      return;
    }

    final vm = context.read<StudentViewModel>();
    final authVm = context.read<AuthViewModel>();
    final classVm = context.read<ClassProvider>();
    final old = widget.initialStudent;
    final student = Student(
      id: old?.id ?? '',
      mssv: _mssvController.text.trim(),
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      birthDate: _birthDate!,
      classId: _classId!,
      isFavorite: old?.isFavorite ?? false,
    );

    try {
      if (widget.isEditing) {
        await vm.updateStudent(student);
      } else {
        await vm.addStudent(student);
        if (authVm.user?.role == AppRole.admin) {
          final createdByAdmin = await authVm.provisionStudentAccountByAdmin(
            mssv: student.mssv,
            displayName: student.fullName,
          );
          if (!createdByAdmin && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  authVm.errorMessage ??
                      'Đã thêm sinh viên, nhưng chưa tạo được tài khoản đăng nhập tự động.',
                ),
              ),
            );
          }
        }
      }

      await classVm.refresh();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể lưu sinh viên: $error')));
      return;
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isEditing ? 'Cập nhật thành công.' : 'Thêm thành công.',
        ),
      ),
    );
    Navigator.of(context).pop(true);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final classes = context.watch<StudentViewModel>().classes;
    _classId ??= classes.isNotEmpty ? classes.first.id : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Chỉnh sửa sinh viên' : 'Thêm sinh viên',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _mssvController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'MSSV'),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return 'Không được bỏ trống MSSV.';
                  }
                  if (!RegExp(r'^\d+$').hasMatch(text)) {
                    return 'MSSV phải là số.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Họ và tên'),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Không được bỏ trống họ tên.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return 'Không được bỏ trống email.';
                  }
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
                    return 'Email không đúng định dạng.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _classId,
                decoration: const InputDecoration(labelText: 'Lớp học'),
                items: classes
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item.id,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _classId = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Ngày sinh'),
                subtitle: Text(
                  _birthDate != null
                      ? _formatDate(_birthDate!)
                      : 'Chưa chọn ngày sinh',
                ),
                trailing: IconButton(
                  onPressed: _pickBirthDate,
                  icon: const Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  child: Text(
                    widget.isEditing ? 'Lưu thay đổi' : 'Thêm sinh viên',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
