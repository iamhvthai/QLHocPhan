import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/giang_vien.dart';
import '../services/api_service.dart';
import '../widgets/common.dart';
import '../widgets/giangvien_avatar.dart';

/// Dùng chung cho Thêm (giangVien == null) và Sửa.
class GiangVienFormScreen extends StatefulWidget {
  final GiangVien? giangVien;
  const GiangVienFormScreen({super.key, this.giangVien});

  @override
  State<GiangVienFormScreen> createState() => _GiangVienFormScreenState();
}

class _GiangVienFormScreenState extends State<GiangVienFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _idCtl;
  late final TextEditingController _nameCtl;
  late final TextEditingController _classCtl;
  String _image = '';
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.giangVien != null;

  @override
  void initState() {
    super.initState();
    final g = widget.giangVien;
    _idCtl = TextEditingController(text: g?.idgv ?? '');
    _nameCtl = TextEditingController(text: g?.fullname ?? '');
    _classCtl = TextEditingController(text: '${g?.sumClass ?? 0}');
    _image = g?.image ?? '';
    _nameCtl.addListener(() => setState(() {})); // cập nhật chữ cái đầu ở avatar
  }

  @override
  void dispose() {
    _idCtl.dispose();
    _nameCtl.dispose();
    _classCtl.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final f = await ImagePicker()
        .pickImage(source: source, maxWidth: 512, maxHeight: 512, imageQuality: 70);
    if (f == null) return;
    final bytes = await f.readAsBytes();
    if (bytes.length > 1500000) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Ảnh quá lớn (tối đa khoảng 1,5 MB), hãy chọn ảnh nhỏ hơn')));
      }
      return;
    }
    final mime = f.mimeType ?? 'image/jpeg';
    setState(() => _image = 'data:$mime;base64,${base64Encode(bytes)}');
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final g = GiangVien(
      id: widget.giangVien?.id ?? '',
      idgv: _idCtl.text.trim(),
      fullname: _nameCtl.text.trim(),
      image: _image,
      sumClass: int.parse(_classCtl.text.trim()),
    );
    try {
      if (_isEdit) {
        await ApiService.update(g.id, g);
      } else {
        await ApiService.create(g);
      }
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Sửa giảng viên' : 'Thêm giảng viên')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Nhóm 1: hình ảnh
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              GiangVienAvatar(
                                  image: _image, name: _nameCtl.text, radius: 56),
                              if (_image.isNotEmpty)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: IconButton.filledTonal(
                                    tooltip: 'Xóa ảnh',
                                    icon: const Icon(Icons.close, size: 18),
                                    onPressed: () => setState(() => _image = ''),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _pick(ImageSource.gallery),
                                icon: const Icon(Icons.photo_library_outlined),
                                label: Text(_image.isEmpty
                                    ? 'Chọn từ thư viện'
                                    : 'Đổi ảnh'),
                              ),
                              if (!kIsWeb)
                                OutlinedButton.icon(
                                  onPressed: () => _pick(ImageSource.camera),
                                  icon: const Icon(Icons.photo_camera_outlined),
                                  label: const Text('Chụp ảnh'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Ảnh không bắt buộc. Chưa có ảnh sẽ hiện chữ cái đầu của tên.',
                              textAlign: TextAlign.center,
                              style: text.bodySmall
                                  ?.copyWith(color: scheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Nhóm 2: thông tin
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Thông tin giảng viên', style: text.titleMedium),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _idCtl,
                            textCapitalization: TextCapitalization.characters,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Mã giảng viên',
                              hintText: 'Ví dụ: GV006',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Vui lòng nhập mã giảng viên, ví dụ GV006'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameCtl,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Họ và tên',
                              hintText: 'Ví dụ: Nguyễn Văn An',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Vui lòng nhập họ và tên giảng viên'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _classCtl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _save(),
                            decoration: const InputDecoration(
                              labelText: 'Tổng số lớp',
                              hintText: 'Số lớp giảng viên phụ trách',
                              prefixIcon: Icon(Icons.class_outlined),
                            ),
                            validator: (v) {
                              final n = int.tryParse((v ?? '').trim());
                              if (n == null || n < 0) {
                                return 'Tổng số lớp phải là số nguyên từ 0 trở lên';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    ErrorBanner(_error!),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _saving ? null : () => Navigator.pop(context),
                          child: const Text('Hủy'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: _saving ? null : _save,
                          icon: _saving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2))
                              : Icon(_isEdit ? Icons.save_outlined : Icons.add),
                          label: Text(_isEdit ? 'Lưu thay đổi' : 'Thêm giảng viên'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
