import 'dart:convert';

class LocalItem {
  final int id;
  final String name;
  final String description;
  const LocalItem(
      {required this.id, required this.name, required this.description});

  factory LocalItem.fromJson(Map<String, dynamic> json) {
    if (json['id'] is! int ||
        (json['id'] as int) < 1 ||
        json['name'] is! String ||
        (json['name'] as String).trim().isEmpty ||
        json['description'] is! String) {
      throw const FormatException('Invalid item fields.');
    }
    return LocalItem(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String);
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'description': description};
}

List<LocalItem> parseItems(dynamic decoded) {
  if (decoded is! List) throw const FormatException('Expected an item array.');
  final ids = <int>{};
  return decoded.map((value) {
    if (value is! Map<String, dynamic>)
      throw const FormatException('Expected an item.');
    final item = LocalItem.fromJson(value);
    if (!ids.add(item.id)) throw const FormatException('Duplicate IDs.');
    return item;
  }).toList();
}

// nextId is saved too, so deleting the largest ID does not cause ID reuse.
class ItemDatabase {
  final int nextId;
  final List<LocalItem> items;
  ItemDatabase({required this.nextId, required List<LocalItem> items})
      : items = List.unmodifiable(items);
  factory ItemDatabase.empty() => ItemDatabase(nextId: 1, items: []);

  factory ItemDatabase.fromJson(Map<String, dynamic> json) {
    if (json['version'] != 1 ||
        json['nextId'] is! int ||
        (json['nextId'] as int) < 1) {
      throw const FormatException('Invalid database metadata.');
    }
    final items = parseItems(json['items']);
    final nextId = json['nextId'] as int;
    if (items.any((item) => item.id >= nextId)) {
      throw const FormatException('nextId must be larger than existing IDs.');
    }
    return ItemDatabase(nextId: nextId, items: items);
  }

  Map<String, dynamic> toJson() => {
        'version': 1,
        'nextId': nextId,
        'items': items.map((item) => item.toJson()).toList()
      };
  String encode() => const JsonEncoder.withIndent('  ').convert(toJson());

  ItemDatabase add(String name, String description) =>
      ItemDatabase(nextId: nextId + 1, items: [
        ...items,
        LocalItem(
            id: nextId, name: name.trim(), description: description.trim())
      ]);

  ItemDatabase update(int id, String name, String description) {
    if (!items.any((item) => item.id == id))
      throw StateError('Item not found.');
    return ItemDatabase(
        nextId: nextId,
        items: items
            .map((item) => item.id == id
                ? LocalItem(
                    id: id, name: name.trim(), description: description.trim())
                : item)
            .toList());
  }

  ItemDatabase delete(int id) => ItemDatabase(
      nextId: nextId, items: items.where((item) => item.id != id).toList());

  List<LocalItem> search(String query) {
    final normalized = query.trim().toLowerCase();
    return items
        .where((item) =>
            item.name.toLowerCase().contains(normalized) ||
            item.description.toLowerCase().contains(normalized) ||
            '${item.id}' == normalized)
        .toList();
  }
}
