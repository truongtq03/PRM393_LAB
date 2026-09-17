// Lab 3 - Advanced Dart Practice Exercises

import 'dart:async';
import 'dart:convert';

Future<void> main() async {
  await exercise1ProductRepository();
  await exercise2UserRepositoryWithJson();
  await exercise3AsyncAndMicrotasks();
  await exercise4StreamTransformation();
  exercise5FactoryConstructorAndCache();
}

// Exercise 1: a repository exposes both a Future and a live product stream.
Future<void> exercise1ProductRepository() async {
  print('\n=== Exercise 1: Product Model & Repository ===');

  ProductRepository repository = ProductRepository([
    Product(id: 1, name: 'Keyboard', price: 45.0),
    Product(id: 2, name: 'Mouse', price: 20.0),
  ]);

  StreamSubscription<Product> subscription =
      repository.liveAdded().listen((product) {
    print('Live product added: ${product.name} - \$${product.price}');
  });

  List<Product> products = await repository.getAll();
  print('All products: ${products.map((product) => product.name).join(', ')}');

  repository.add(Product(id: 3, name: 'Monitor', price: 180.0));
  await Future<void>.delayed(Duration.zero);

  await subscription.cancel();
  await repository.dispose();
}

class Product {
  final int id;
  final String name;
  final double price;

  Product({required this.id, required this.name, required this.price});
}

class ProductRepository {
  final List<Product> _products;
  final StreamController<Product> _addedController =
      StreamController<Product>.broadcast();

  ProductRepository(this._products);

  Future<List<Product>> getAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return List<Product>.unmodifiable(_products);
  }

  Stream<Product> liveAdded() => _addedController.stream;

  void add(Product product) {
    _products.add(product);
    _addedController.add(product);
  }

  Future<void> dispose() => _addedController.close();
}

// Exercise 2: decode simulated API JSON and build typed User objects.
Future<void> exercise2UserRepositoryWithJson() async {
  print('\n=== Exercise 2: User Repository with JSON ===');

  UserRepository repository = UserRepository();
  List<User> users = await repository.fetchUsers();

  for (User user in users) {
    print('User: ${user.name} <${user.email}>');
  }
}

class User {
  final String name;
  final String email;

  User({required this.name, required this.email});

  User.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        email = json['email'] as String;
}

class UserRepository {
  Future<List<User>> fetchUsers() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    const String jsonResponse = '''
      [
        {"name": "Alice", "email": "alice@example.com"},
        {"name": "Bob", "email": "bob@example.com"}
      ]
    ''';

    List<dynamic> decoded = jsonDecode(jsonResponse) as List<dynamic>;
    return decoded
        .map((item) => User.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

// Exercise 3: microtasks run before event-queue callbacks.
Future<void> exercise3AsyncAndMicrotasks() async {
  print('\n=== Exercise 3: Async + Microtask Debugging ===');
  List<String> order = [];

  order.add('synchronous');
  scheduleMicrotask(() => order.add('microtask'));
  Future<void>(() => order.add('event callback'));

  await Future<void>.delayed(Duration.zero);
  print('Execution order: ${order.join(' -> ')}');
  print('Microtasks run before event callbacks in the event loop.');
}

// Exercise 4: map each number to its square, then keep only even squares.
Future<void> exercise4StreamTransformation() async {
  print('\n=== Exercise 4: Stream Transformation ===');

  Stream<int> transformed = Stream<int>.fromIterable([1, 2, 3, 4, 5])
      .map((number) => number * number)
      .where((square) => square.isEven);

  await for (int value in transformed) {
    print('Even square: $value');
  }
}

// Exercise 5: a factory constructor returns one cached Settings instance.
void exercise5FactoryConstructorAndCache() {
  print('\n=== Exercise 5: Factory Constructors & Cache ===');

  Settings first = Settings();
  Settings second = Settings();

  print('Same singleton instance: ${identical(first, second)}');
  print('Theme: ${first.theme}');
}

class Settings {
  static final Settings _instance = Settings._internal();

  final String theme;

  Settings._internal() : theme = 'light';

  factory Settings() => _instance;
}