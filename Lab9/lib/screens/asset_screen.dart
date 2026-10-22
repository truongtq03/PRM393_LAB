import 'package:flutter/material.dart';
import '../models/local_item.dart';
import '../services/json_repository.dart';

class AssetScreen extends StatefulWidget {
  const AssetScreen({super.key});
  @override
  State<AssetScreen> createState() => _AssetScreenState();
}

class _AssetScreenState extends State<AssetScreen> {
  final _service = AssetItemService();
  late Future<List<LocalItem>> _future;
  @override
  void initState() {
    super.initState();
    _future = _service.load();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<LocalItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError)
            return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Không đọc được JSON từ assets.'),
              TextButton(
                  onPressed: () => setState(() {
                        _future = _service.load();
                      }),
                  child: const Text('Thử lại'))
            ]));
          final items = snapshot.data ?? [];
          return ListView(padding: const EdgeInsets.all(20), children: [
            Text('9.1 • JSON từ assets',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text(
                'Đọc tệp có sẵn bằng rootBundle.loadString(), chuyển JSON thành List<LocalItem>.'),
            const SizedBox(height: 12),
            const SelectableText('assets/data/items.json'),
            const SizedBox(height: 16),
            Text('${items.length} mục • dữ liệu nhúng chỉ đọc',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            if (items.isEmpty)
              const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Tệp assets chưa có mục nào.')),
            ...items.map((item) => Card(
                elevation: 0,
                color: Colors.white,
                child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(child: Text('${item.id}')),
                    title: Text(item.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(item.description))))),
          ]);
        },
      );
}
