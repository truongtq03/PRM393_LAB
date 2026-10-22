import 'package:flutter/material.dart';
import '../models/local_item.dart';

class ItemInput {
  final String name;
  final String description;
  const ItemInput(this.name, this.description);
}

Future<ItemInput?> editItem(BuildContext context, {LocalItem? item}) =>
    showDialog<ItemInput>(
        context: context, builder: (_) => ItemEditor(item: item));

class ItemEditor extends StatefulWidget {
  final LocalItem? item;
  const ItemEditor({super.key, this.item});
  @override
  State<ItemEditor> createState() => _ItemEditorState();
}

class _ItemEditorState extends State<ItemEditor> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.item?.name ?? '');
  late final _description =
      TextEditingController(text: widget.item?.description ?? '');
  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _submit() {
    if (_form.currentState!.validate()) {
      Navigator.pop(
          context, ItemInput(_name.text.trim(), _description.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.item == null
            ? 'Thêm mục mới'
            : 'Sửa mục #${widget.item!.id}'),
        scrollable: true,
        content: SizedBox(
            width: 420,
            child: Form(
                key: _form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                        controller: _name,
                        autofocus: true,
                        maxLength: 80,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Tên mục'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Vui lòng nhập tên mục.'
                                : null),
                    const SizedBox(height: 12),
                    TextFormField(
                        controller: _description,
                        minLines: 2,
                        maxLines: 5,
                        maxLength: 300,
                        decoration: const InputDecoration(
                            labelText: 'Ghi chú', alignLabelWithHint: true)),
                  ],
                ))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy')),
          FilledButton(
              onPressed: _submit,
              child: Text(widget.item == null ? 'Thêm' : 'Lưu thay đổi'))
        ],
      );
}
