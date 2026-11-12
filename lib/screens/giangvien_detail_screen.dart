import 'package:flutter/material.dart';

import '../models/giang_vien.dart';
import '../services/api_service.dart';
import '../widgets/common.dart';
import '../widgets/giangvien_avatar.dart';
import 'giangvien_form_screen.dart';

class GiangVienDetailScreen extends StatefulWidget {
  final GiangVien giangVien;
  const GiangVienDetailScreen({super.key, required this.giangVien});

  @override
  State<GiangVienDetailScreen> createState() => _GiangVienDetailScreenState();
}

class _GiangVienDetailScreenState extends State<GiangVienDetailScreen> {
  late GiangVien _g = widget.giangVien;
  bool _changed = false;
  bool _deleting = false;

  Future<void> _edit() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => GiangVienFormScreen(giangVien: _g)),
    );
    if (ok == true) {
      _changed = true;
      try {
        final g = await ApiService.getOne(_g.id);
        if (!mounted) return;
        setState(() => _g = g);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Đã lưu thay đổi')));
      } catch (_) {}
    }
  }

  Future<void> _delete() async {
    if (!await confirmDelete(context, _g.fullname, _g.idgv)) return;
    setState(() => _deleting = true);
    try {
      await ApiService.delete(_g.id);
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _deleting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _changed);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Thông tin giảng viên')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Hero(
                        tag: 'avatar-${_g.id}',
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: scheme.primaryContainer, width: 4),
                          ),
                          child: GiangVienAvatar(
                              image: _g.image, name: _g.fullname, radius: 72),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(_g.fullname,
                          textAlign: TextAlign.center, style: text.headlineSmall),
                      const SizedBox(height: 8),
                      Chip(
                        avatar: const Icon(Icons.badge_outlined, size: 18),
                        label: Text(_g.idgv),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      _InfoRow(
                          icon: Icons.badge_outlined,
                          label: 'Mã giảng viên',
                          value: _g.idgv),
                      _InfoRow(
                          icon: Icons.person_outline,
                          label: 'Họ và tên',
                          value: _g.fullname),
                      _InfoRow(
                          icon: Icons.class_outlined,
                          label: 'Tổng số lớp',
                          value: '${_g.sumClass} lớp'),
                      const Divider(),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: scheme.error,
                                side: BorderSide(color: scheme.error.withValues(alpha: 0.5)),
                              ),
                              onPressed: _deleting ? null : _delete,
                              icon: _deleting
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.delete_outline),
                              label: const Text('Xóa'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _deleting ? null : _edit,
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Sửa'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: scheme.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: scheme.primary),
      ),
      title: Text(label,
          style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
      subtitle: Text(value,
          style: TextStyle(fontSize: 16, color: scheme.onSurface, fontWeight: FontWeight.w500)),
    );
  }
}
