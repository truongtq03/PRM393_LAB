// Lab 2 - Dart Essentials Practice Lab

Future<void> main() async {
  exercise1BasicSyntaxAndDataTypes();
  exercise2CollectionsAndOperators();
  exercise3ControlFlowAndFunctions();
  exercise4IntroToOop();
  await exercise5AsyncNullSafetyAndStreams();
}

// Exercise 1: declare basic data types and use string interpolation.
void exercise1BasicSyntaxAndDataTypes() {
  print('\n=== Exercise 1: Basic Syntax & Data Types ===');

  int age = 20;
  double averageScore = 8.5;
  String studentName = 'Alex';
  bool isStudent = true;

  print('Name: $studentName');
  print('Age: $age');
  print('Average score: $averageScore');
  print('Is student: $isStudent');
  print('Next year age: ${age + 1}');
}

// Exercise 2: manipulate lists, sets, maps, and common operators.
void exercise2CollectionsAndOperators() {
  print('\n=== Exercise 2: Collections & Operators ===');

  List<int> numbers = [10, 20, 20, 30];
  numbers.add(40);
  numbers.remove(20);

  Set<int> uniqueNumbers = numbers.toSet();
  Map<String, dynamic> student = {
    'name': 'Alex',
    'score': 85,
  };

  int sum = numbers[0] + numbers[1];
  int difference = numbers[2] - numbers[0];
  bool passed = student['score'] >= 50;
  bool hasManyNumbers = numbers.length > 3 && uniqueNumbers.length > 2;
  String result = passed ? 'Pass' : 'Fail';

  print('List: $numbers');
  print('First item: ${numbers[0]}');
  print('Set of unique values: $uniqueNumbers');
  print('Student name from map: ${student['name']}');
  print('Sum: $sum, difference: $difference');
  print('Has many numbers: $hasManyNumbers');
  print('Result: $result');
  print('Lists are equal: ${numbers == [10, 20, 30, 40]}');
}

// Exercise 3: use conditions, switch, loops, and two function syntaxes.
void exercise3ControlFlowAndFunctions() {
  print('\n=== Exercise 3: Control Flow & Functions ===');

  int score = 85;
  if (score >= 50) {
    print('Score check: passed');
  } else {
    print('Score check: failed');
  }

  String day = 'Monday';
  switch (day) {
    case 'Saturday':
    case 'Sunday':
      print('$day is a weekend');
    default:
      print('$day is a weekday');
  }

  List<String> subjects = ['Dart', 'Flutter', 'Database'];
  for (int index = 0; index < subjects.length; index++) {
    print('for loop: ${subjects[index]}');
  }
  for (String subject in subjects) {
    print('for-in loop: $subject');
  }
  subjects.forEach((subject) => print('forEach loop: $subject'));

  print('Normal function result: ${addNumbers(4, 6)}');
  print('Arrow function result: ${doubleNumber(5)}');
}

// A normal function with a block body.
int addNumbers(int first, int second) {
  return first + second;
}

// An arrow function for a single expression.
int doubleNumber(int number) => number * 2;

// Exercise 4: create a class, named constructor, inheritance, and overriding.
void exercise4IntroToOop() {
  print('\n=== Exercise 4: Intro to OOP ===');

  Car car = Car('Toyota');
  Car namedCar = Car.named('Honda');
  ElectricCar electricCar = ElectricCar('Tesla', 100);

  print(car.describe());
  print(namedCar.describe());
  print(electricCar.describe());
}

class Car {
  final String brand;

  Car(this.brand);

  Car.named(this.brand);

  String describe() => '$brand car is driving.';
}

class ElectricCar extends Car {
  final int batteryPercentage;

  ElectricCar(super.brand, this.batteryPercentage);

  @override
  String describe() =>
      '$brand electric car is driving with $batteryPercentage% battery.';
}

// Exercise 5: use Future, await, null safety, and a stream.
Future<void> exercise5AsyncNullSafetyAndStreams() async {
  print('\n=== Exercise 5: Async, Null Safety & Streams ===');

  String loadedMessage = await loadMessage();
  print('Async result: $loadedMessage');

  String? optionalName = getOptionalName();
  String displayName = optionalName ?? 'Guest';
  print('Null-aware access: ${optionalName?.toUpperCase()}');
  print('Default value with ?? : $displayName');

  String? confirmedName = getConfirmedName();
  print('Non-null assertion: ${confirmedName!.toUpperCase()}');

  print('Stream values:');
  await numberStream().listen((value) {
    print('Received $value');
  }).asFuture<void>();
}

Future<String> loadMessage() async {
  await Future<void>.delayed(const Duration(milliseconds: 100));
  return 'Data loaded successfully';
}

String? getOptionalName() => null;

String? getConfirmedName() => 'Dart student';

Stream<int> numberStream() async* {
  for (int number = 1; number <= 3; number++) {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    yield number;
  }
}