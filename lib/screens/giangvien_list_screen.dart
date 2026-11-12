import 'dart:async';

import 'package:flutter/material.dart';

import '../models/giang_vien.dart';
import '../services/api_service.dart';
import '../services/token_storage.dart';
import '../widgets/common.dart';
import '../widgets/giangvien_avatar.dart';
import 'giangvien_detail_screen.dart';
import 'giangvien_form_screen.dart';
import 'login_screen.dart';

class GiangVienListScreen extends StatefulWidget {
  final String username;
  const GiangVienListScreen({super.key, required this.username});

  @override
  State<GiangVienListScreen> createState() => _GiangVienListScreenState();
}

class _GiangVienListScreenState extends State<GiangVienListScreen> {
  static const _limit = 10;
  final _searchCtl = TextEditingController();
  Timer? _debounce;

  List<GiangVien> _items = [];
  int _page = 1;
  int _totalPages = 1;
  int _total = 0;
  int _totalSumClass = 0;
  bool _loading = true;
  bool _loadedOnce = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtl.dispose();
    super.dispose();
  }

  Future<void> _load({int? page}) async {
    setState(() {
      _loading = true;
      _error = null;
      if (page != null) _page = page;
    });
    try {
      final r = await ApiService.getGiangVien(
          search: _searchCtl.text.trim(), page: _page, limit: _limit);
      if (!mounted) return;
      if (r.data.isEmpty && _page > 1) {
        await _load(page: _page - 1);
        return;
      }
      setState(() {
        _items = r.data;
        _totalPages = r.totalPages;
        _total = r.total;
        _totalSumClass = r.totalSumClass;
        _loading = false;
        _loadedOnce = true;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
    }
  }

  void _onSearchChanged(String _) {
    setState(() {}); // cập nhật nút xóa tìm kiếm
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _load(page: 1));
  }

  void _clearSearch() {
    _searchCtl.clear();
    _load(page: 1);
  }

  Future<void> _add() async {
    final ok = await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (_) => const GiangVienFormScreen()));
    if (ok == true) {
      _snack('Đã thêm giảng viên');
      _load();
    }
  }

  Future<void> _edit(GiangVien g) async {
    final ok = await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (_) => GiangVienFormScreen(giangVien: g)));
    if (ok == true) {
      _snack('Đã lưu thay đổi');
      _load();
    }
  }

  Future<void> _view(GiangVien g) async {
    final changed = await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (_) => GiangVienDetailScreen(giangVien: g)));
    if (changed == true) _load();
  }

  Future<void> _delete(GiangVien g) async {
    if (!await confirmDelete(context, g.fullname, g.idgv)) return;
    try {
      await ApiService.delete(g.id);
      _snack('Đã xóa giảng viên ${g.fullname}');
      _load();
    } on ApiException catch (e) {
      _snack(e.message);
    }
  }

  void _snack(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _logout() async {
    await TokenStorage.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý giảng viên'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: _loading
              ? const LinearProgressIndicator(minHeight: 2)
              : const SizedBox(height: 2),
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Tài khoản',
            onSelected: (v) {
              if (v == 'logout') _logout();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                child: Text('Đăng nhập: ${widget.username}'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.logout),
                  title: Text('Đăng xuất'),
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: scheme.primaryContainer,
                child: Icon(Icons.admin_panel_settings,
                    size: 18, color: scheme.onPrimaryContainer),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Thêm giảng viên'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchCtl,
                  onChanged: _onSearchChanged,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Tìm theo mã giảng viên hoặc họ tên',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchCtl.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Xóa tìm kiếm',
                            icon: const Icon(Icons.close),
                            onPressed: _clearSearch,
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.groups_outlined,
                        label: 'Giảng viên',
                        value: '$_total',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.class_outlined,
                        label: 'Tổng số lớp',
                        value: '$_totalSumClass',
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _buildBody(),
                ),
              ),
              if (_items.isNotEmpty) _buildPager(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return StatusView(
        key: const ValueKey('error'),
        isError: true,
        icon: Icons.cloud_off_outlined,
        title: 'Không tải được danh sách',
        message: '$_error\nKiểm tra máy chủ đã chạy chưa rồi thử lại.',
        actionLabel: 'Thử lại',
        actionIcon: Icons.refresh,
        onAction: _load,
      );
    }
    if (!_loadedOnce) {
      return const Center(key: ValueKey('loading'), child: CircularProgressIndicator());
    }
    if (_items.isEmpty) {
      final q = _searchCtl.text.trim();
      if (q.isNotEmpty) {
        return StatusView(
          key: const ValueKey('no-result'),
          icon: Icons.search_off,
          title: "Không tìm thấy kết quả cho '$q'",
          message: 'Thử tìm bằng mã giảng viên hoặc một phần họ tên.',
          actionLabel: 'Xóa tìm kiếm',
          actionIcon: Icons.close,
          onAction: _clearSearch,
        );
      }
      return StatusView(
        key: const ValueKey('empty'),
        icon: Icons.person_add_alt_1_outlined,
        title: 'Chưa có giảng viên nào',
        message: 'Bắt đầu bằng cách thêm giảng viên đầu tiên vào học phần.',
        actionLabel: 'Thêm giảng viên đầu tiên',
        onAction: _add,
      );
    }
    return LayoutBuilder(
      key: const ValueKey('data'),
      builder: (context, c) => c.maxWidth >= 800 ? _buildTable() : _buildCards(),
    );
  }

  Widget _buildTable() {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            headingRowColor: WidgetStatePropertyAll(scheme.surfaceContainerHighest),
            headingTextStyle:
                TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurface),
            dataRowMinHeight: 64,
            dataRowMaxHeight: 64,
            showCheckboxColumn: false,
            columns: const [
              DataColumn(label: Text('Ảnh')),
              DataColumn(label: Text('Mã GV')),
              DataColumn(label: Text('Họ và tên')),
              DataColumn(label: Text('Số lớp'), numeric: true),
              DataColumn(label: Text('Thao tác')),
            ],
            rows: [
              for (var i = 0; i < _items.length; i++)
                _row(_items[i], i.isOdd ? scheme.surfaceContainerLowest : null),
            ],
          ),
        ),
      ),
    );
  }

  DataRow _row(GiangVien g, Color? bg) {
    return DataRow(
      color: bg == null ? null : WidgetStatePropertyAll(bg),
      onSelectChanged: (_) => _view(g),
      cells: [
        DataCell(Hero(
          tag: 'avatar-${g.id}',
          child: GiangVienAvatar(image: g.image, name: g.fullname, radius: 20),
        )),
        DataCell(Text(g.idgv, style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Text(g.fullname, overflow: TextOverflow.ellipsis),
        )),
        DataCell(_ClassChip(g.sumClass)),
        DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
              tooltip: 'Xem chi tiết',
              icon: const Icon(Icons.visibility_outlined),
              onPressed: () => _view(g)),
          IconButton(
              tooltip: 'Sửa',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _edit(g)),
          IconButton(
              tooltip: 'Xóa',
              icon: Icon(Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error),
              onPressed: () => _delete(g)),
        ])),
      ],
    );
  }

  Widget _buildCards() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: _items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final g = _items[i];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            minVerticalPadding: 16,
            contentPadding: const EdgeInsets.only(left: 16, right: 8),
            leading: Hero(
              tag: 'avatar-${g.id}',
              child: GiangVienAvatar(image: g.image, name: g.fullname),
            ),
            title: Text(g.fullname,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('${g.idgv}  •  ${g.sumClass} lớp',
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            onTap: () => _view(g),
            trailing: PopupMenuButton<String>(
              tooltip: 'Thao tác',
              onSelected: (v) => v == 'edit' ? _edit(g) : _delete(g),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Sửa'),
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.delete_outline,
                        color: Theme.of(context).colorScheme.error),
                    title: Text('Xóa',
                        style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPager() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton.outlined(
            tooltip: 'Trang trước',
            icon: const Icon(Icons.chevron_left),
            onPressed: _page > 1 && !_loading ? () => _load(page: _page - 1) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Trang $_page / $_totalPages',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          IconButton.outlined(
            tooltip: 'Trang sau',
            icon: const Icon(Icons.chevron_right),
            onPressed:
                _page < _totalPages && !_loading ? () => _load(page: _page + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: scheme.onPrimaryContainer),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
                  Text(value, style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassChip extends StatelessWidget {
  final int count;
  const _ClassChip(this.count);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('$count lớp',
          style: TextStyle(
              color: scheme.onSecondaryContainer, fontWeight: FontWeight.w600)),
    );
  }
}
