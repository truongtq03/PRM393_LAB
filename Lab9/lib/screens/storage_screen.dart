import 'package:flutter/material.dart';
import '../models/local_item.dart';
import '../services/json_repository.dart';
import 'item_editor.dart';

class StorageScreen extends StatefulWidget {
  final JsonRepository repository;
  final bool autoSave;
  const StorageScreen(
      {super.key, required this.repository, required this.autoSave});
  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  ItemDatabase? _database;
  bool _loading = true;
  bool _busy = false;
  bool _dirty = false;
  String? _error;
  String _location = '';
  final _search = TextEditingController();
  final _messenger = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _message(String message) {
    final messenger = _messenger.currentState!;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final database = await widget.repository.load();
      final location = await widget.repository.location();
      if (!mounted) return;
      setState(() {
        _database = database;
        _location = location;
        _dirty = false;
      });
    } catch (error) {
      if (mounted)
        setState(() {
          _error = error.toString();
        });
    } finally {
      if (mounted)
        setState(() {
          _loading = false;
        });
    }
  }

  Future<void> _reload() async {
    if (_loading || _busy) return;
    if (_dirty) {
      final discard = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
                  title: const Text('Bỏ thay đổi chưa lưu?'),
                  content: const Text(
                      'Tải lại sẽ khôi phục nội dung đã lưu và bỏ các mục chưa lưu.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Giữ lại')),
                    FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Tải lại'))
                  ]));
      if (discard != true || !mounted) return;
    }
    await _load();
    if (mounted && _error == null) _message('Đã tải lại dữ liệu đã lưu.');
  }

  Future<void> _commit(ItemDatabase candidate, String message) async {
    if (_busy || _loading) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.repository.save(candidate);
      if (!mounted) return;
      // Commit the visible CRUD result only after persistence succeeds.
      setState(() {
        _database = candidate;
        _dirty = false;
      });
      _message(message);
    } catch (error) {
      if (mounted)
        setState(() {
          _error = error.toString();
        });
    } finally {
      if (mounted)
        setState(() {
          _busy = false;
        });
    }
  }

  Future<void> _add() async {
    final input = await editItem(context);
    if (input == null || !mounted) return;
    final candidate = _database!.add(input.name, input.description);
    if (widget.autoSave) {
      await _commit(candidate, 'Đã thêm mục và tự động lưu JSON.');
    } else {
      setState(() {
        _database = candidate;
        _dirty = true;
      });
      _message('Đã thêm vào danh sách. Nhấn Lưu JSON để lưu lâu dài.');
    }
  }

  Future<void> _edit(LocalItem item) async {
    final input = await editItem(context, item: item);
    if (input == null || !mounted) return;
    await _commit(_database!.update(item.id, input.name, input.description),
        'Đã sửa mục #${item.id} và lưu JSON.');
  }

  Future<void> _delete(LocalItem item) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: Text('Xóa mục #${item.id}?'),
                content: Text(item.name),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Hủy')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Xóa'))
                ]));
    if (confirmed != true || !mounted) return;
    await _commit(
        _database!.delete(item.id), 'Đã xóa mục #${item.id} và lưu JSON.');
  }

  Future<void> _showJson() async {
    try {
      final saved = await widget.repository.load();
      if (!mounted) return;
      await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
                  title: const Text('JSON đã lưu'),
                  scrollable: true,
                  content: SizedBox(
                      width: 520,
                      child: SelectableText(saved.encode(),
                          style: const TextStyle(
                              fontFamily: 'monospace', fontSize: 13))),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Đóng'))
                  ]));
    } catch (error) {
      if (mounted) _message(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = !_loading && !_busy && _database != null;
    final items =
        _database?.search(widget.autoSave ? _search.text : '') ?? <LocalItem>[];
    return ScaffoldMessenger(
      key: _messenger,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
            onPressed: enabled ? _add : null,
            icon: const Icon(Icons.add),
            label: const Text('Thêm mục')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                children: [
                  Text(
                      widget.autoSave
                          ? '9.3 • JSON CRUD + Search'
                          : '9.2 • Save & Load JSON',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(widget.autoSave
                      ? 'Thêm, sửa, xóa và tìm kiếm. Mỗi thay đổi được tự động lưu.'
                      : 'Thêm mục, nhấn Lưu JSON rồi tải lại hoặc mở lại ứng dụng để kiểm tra.'),
                  const SizedBox(height: 16),
                  if (_location.isNotEmpty)
                    SelectableText(_location,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF536275))),
                  const SizedBox(height: 12),
                  if (_busy)
                    const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: LinearProgressIndicator()),
                  if (_error != null)
                    Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Semantics(
                                  liveRegion: true,
                                  child: Text(_error!,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error))),
                              if (_database == null)
                                TextButton(
                                    onPressed: _load,
                                    child: const Text('Thử lại')),
                            ])),
                  if (_database != null) ...[
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      if (!widget.autoSave)
                        FilledButton.icon(
                            onPressed: enabled
                                ? () => _commit(
                                    _database!, 'Đã lưu JSON thành công.')
                                : null,
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('Lưu JSON')),
                      OutlinedButton.icon(
                          onPressed: enabled ? _reload : null,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tải lại')),
                      TextButton.icon(
                          onPressed: enabled ? _showJson : null,
                          icon: const Icon(Icons.data_object),
                          label: const Text('Xem JSON đã lưu')),
                    ]),
                    const SizedBox(height: 12),
                    Text(
                        _dirty ? 'Có thay đổi chưa lưu' : 'Dữ liệu đã được lưu',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _dirty
                                ? const Color(0xFF8A5400)
                                : const Color(0xFF176B45))),
                    if (widget.autoSave)
                      Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: TextField(
                              controller: _search,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                  labelText: 'Tìm theo tên, ghi chú hoặc ID',
                                  prefixIcon: Icon(Icons.search)))),
                    const SizedBox(height: 16),
                    Text('${items.length} / ${_database!.items.length} mục',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    if (items.isEmpty)
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 36),
                          child: Column(children: [
                            const Icon(Icons.inbox_outlined, size: 44),
                            const SizedBox(height: 12),
                            Text(_database!.items.isEmpty
                                ? 'Chưa có dữ liệu. Nhấn Thêm mục để bắt đầu.'
                                : 'Không có kết quả phù hợp.')
                          ]))
                    else
                      ...items.map((item) => Card(
                          elevation: 0,
                          color: Colors.white,
                          child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(child: Text('${item.id}')),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text(item.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700)),
                                        const SizedBox(height: 6),
                                        Text(item.description.isEmpty
                                            ? 'Không có ghi chú'
                                            : item.description),
                                        if (widget.autoSave)
                                          Wrap(children: [
                                            TextButton.icon(
                                                onPressed: enabled
                                                    ? () => _edit(item)
                                                    : null,
                                                icon: const Icon(
                                                    Icons.edit_outlined,
                                                    size: 18),
                                                label: const Text('Sửa')),
                                            TextButton.icon(
                                                onPressed: enabled
                                                    ? () => _delete(item)
                                                    : null,
                                                icon: const Icon(
                                                    Icons.delete_outline,
                                                    size: 18),
                                                label: const Text('Xóa')),
                                          ]),
                                      ])),
                                ],
                              )))),
                  ],
                ],
              ),
      ),
    );
  }
}
