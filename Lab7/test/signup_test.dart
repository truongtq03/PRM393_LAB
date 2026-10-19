import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab7_signup/main.dart';

void main() {
  test(
    'required fields, email format, password boundaries and confirmation',
    () {
      expect(SignupValidators.fullName('  '), isNotNull);
      expect(SignupValidators.fullName('Nguyễn Văn An'), isNull);
      for (final email in [
        '',
        'abc',
        'a@b',
        'a@@b.com',
        'a b@c.com',
        'a@b..com',
      ]) {
        expect(SignupValidators.email(email), isNotNull, reason: email);
      }
      expect(SignupValidators.email(' an+lab@example.com '), isNull);
      expect(SignupValidators.password(''), isNotNull);
      expect(SignupValidators.password('1234567'), isNotNull);
      expect(SignupValidators.password('abcdefgh'), isNotNull);
      expect(SignupValidators.password('abcdefg1'), isNull);
      expect(SignupValidators.confirmPassword('', 'abcdefg1'), isNotNull);
      expect(
        SignupValidators.confirmPassword('abcdefg2', 'abcdefg1'),
        isNotNull,
      );
      expect(SignupValidators.confirmPassword('abcdefg1', 'abcdefg1'), isNull);
    },
  );

  Future<void> openForm(WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const SignupApp());
  }

  Future<void> fill(
    WidgetTester tester, {
    String email = 'an@example.com',
  }) async {
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Nguyen Van An');
    await tester.enterText(fields.at(1), email);
    await tester.enterText(fields.at(2), 'Flutter123!');
    await tester.enterText(fields.at(3), 'Flutter123!');
    await tester.pump();
  }

  Future<void> submit(WidgetTester tester) async {
    final button = find.byType(FilledButton);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
  }

  testWidgets('empty form blocks submission and focuses first invalid field', (
    tester,
  ) async {
    await openForm(tester);
    await submit(tester);
    expect(find.text('Full name is required.'), findsOneWidget);
    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);
    expect(find.text('Confirm your password.'), findsOneWidget);
    expect(find.text('Checking email…'), findsNothing);
    expect(
      tester
          .widget<TextField>(find.byType(TextField).first)
          .focusNode!
          .hasFocus,
      isTrue,
    );
  });

  testWidgets('valid form locks inputs during check then saves and succeeds', (
    tester,
  ) async {
    await openForm(tester);
    await fill(tester);
    await submit(tester);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    for (final field in tester.widgetList<TextField>(
      find.byType(TextField),
    )) {
      expect(field.readOnly, isTrue);
    }
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.textContaining('Signup successful! Welcome, Nguyen Van An.'),
      findsOneWidget,
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('taken email fails, clears after editing, then allows retry', (
    tester,
  ) async {
    await openForm(tester);
    await fill(tester, email: ' Taken.user@example.com ');
    await submit(tester);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('This email is already taken.'), findsWidgets);
    expect(find.textContaining('Signup successful!'), findsNothing);
    final emailField = find.byType(TextFormField).at(1);
    await tester.enterText(emailField, 'available@example.com');
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextFormField>(emailField).validator!(
        'available@example.com',
      ),
      isNull,
    );
    await submit(tester);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.textContaining('Signup successful!'), findsOneWidget);
  });

  testWidgets('keyboard Next traverses all fields and Done submits', (
    tester,
  ) async {
    await openForm(tester);
    await fill(tester);
    final fields = find.byType(TextFormField);
    await tester.tap(fields.first);
    for (var index = 1; index < 4; index++) {
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();
      expect(
        tester
            .widget<TextField>(find.byType(TextField).at(index))
            .focusNode!
            .hasFocus,
        isTrue,
      );
    }
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.text('Checking email…'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.textContaining('Signup successful!'), findsOneWidget);
  });

  testWidgets(
    'password visibility and changed password revalidate confirmation',
    (tester) async {
      await openForm(tester);
      await fill(tester);
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField).at(2)).obscureText,
        isFalse,
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'Changed123!');
      await tester.pumpAndSettle();
      expect(find.text('Passwords do not match.'), findsOneWidget);
    },
  );

  testWidgets(
    'small screen and open keyboard can scroll to submit without overflow',
    (tester) async {
      await openForm(tester);
      tester.view.physicalSize = const Size(320, 568);
      tester.view.viewInsets = const FakeViewPadding(bottom: 250);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byType(FilledButton),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.byType(FilledButton).hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('leaving during async check does not update disposed state', (
    tester,
  ) async {
    await openForm(tester);
    await fill(tester);
    await submit(tester);
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });
}
