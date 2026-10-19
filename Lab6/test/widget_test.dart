import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_genre_browsing_lab6/main.dart';

void main() {
  test('search ignores case and surrounding spaces', () {
    expect(filterMovies(query: '  InTeR  ').single.title, 'Interstellar');
    expect(filterMovies(query: 'not a movie'), isEmpty);
    expect(filterMovies().length, 6);
  });

  test('genres use OR and combine with search using AND', () {
    final movies = filterMovies(genres: {'Comedy', 'Thriller'});
    expect(movies.map((movie) => movie.title), [
      'Deadpool & Wolverine',
      'Inception',
      'The Grand Budapest Hotel',
    ]);
    expect(filterMovies(query: 'dune', genres: {'Comedy'}), isEmpty);
    expect(
        filterMovies(query: 'dune', genres: {'Comedy', 'Drama'}).single.title,
        'Dune: Part Two');
  });

  test('all four sorts work without modifying the sample data', () {
    final original = allMovies.map((movie) => movie.title).toList();
    expect(filterMovies(sort: 'A-Z').first.title, 'Arrival');
    expect(filterMovies(sort: 'Z-A').first.title, 'The Grand Budapest Hotel');
    final byYear = filterMovies(sort: 'Year');
    final byRating = filterMovies(sort: 'Rating');
    for (var i = 1; i < byYear.length; i++) {
      expect(byYear[i - 1].year >= byYear[i].year, isTrue);
      expect(byRating[i - 1].rating >= byRating[i].rating, isTrue);
    }
    expect(byRating.first.title, 'Inception');
    expect(allMovies.map((movie) => movie.title), original);
  });

  Future<void> open(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const ResponsiveMovieApp());
    await tester.pumpAndSettle();
  }

  testWidgets('typing filters results and Clear filters clears actual input',
      (tester) async {
    await open(tester, const Size(430, 1000));
    await tester.enterText(find.byType(TextField), 'dune');
    await tester.pumpAndSettle();
    expect(find.text('1 movie found'), findsOneWidget);
    expect(find.byType(MovieCard), findsOneWidget);
    expect(find.text('Dune: Part Two'), findsOneWidget);
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text, '');
    expect(find.text('6 movies found'), findsOneWidget);
  });

  testWidgets(
      'genre chips toggle independently and reset clears chips and sort',
      (tester) async {
    await open(tester, const Size(1000, 900));
    final action = find.widgetWithText(FilterChip, 'Action');
    final comedy = find.widgetWithText(FilterChip, 'Comedy');
    await tester.tap(action);
    await tester.tap(comedy);
    await tester.pumpAndSettle();
    expect(find.text('2 selected'), findsOneWidget);
    expect(find.text('3 movies found'), findsOneWidget);
    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(find.text('2 movies found'), findsOneWidget);
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rating').last);
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<DropdownButton<String>>(find.byType(DropdownButton<String>))
            .value,
        'Rating');
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    expect(tester.widget<FilterChip>(comedy).selected, isFalse);
    expect(
        tester
            .widget<DropdownButton<String>>(find.byType(DropdownButton<String>))
            .value,
        'A-Z');
    expect(find.text('6 movies found'), findsOneWidget);
  });

  testWidgets('sort changes the displayed order', (tester) async {
    await open(tester, const Size(1000, 900));
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Z-A').last);
    await tester.pumpAndSettle();
    expect(
        tester.widgetList<MovieCard>(find.byType(MovieCard)).first.movie.title,
        'The Grand Budapest Hotel');
  });

  testWidgets('empty state can restore the full list', (tester) async {
    await open(tester, const Size(430, 1000));
    await tester.enterText(find.byType(TextField), 'no such movie');
    await tester.pumpAndSettle();
    expect(find.text('No movies match your filters'), findsOneWidget);
    await tester.tap(find.text('Reset filters'));
    await tester.pumpAndSettle();
    expect(find.text('6 movies found'), findsOneWidget);
  });

  for (final width in [320.0, 430.0, 799.0, 800.0, 1024.0]) {
    testWidgets(
        'layout at width $width uses the correct breakpoint without overflow',
        (tester) async {
      await open(tester, Size(width, 1000));
      if (width < 800) {
        expect(find.byType(SliverGrid), findsNothing);
        expect(find.byType(SliverList), findsOneWidget);
      } else {
        final grid = tester.widget<SliverGrid>(find.byType(SliverGrid));
        expect(
            (grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
                .crossAxisCount,
            2);
      }
      final cards = tester.widgetList<MovieCard>(find.byType(MovieCard));
      expect(cards, isNotEmpty);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('landscape with keyboard keeps filters and results scrollable',
      (tester) async {
    await open(tester, const Size(568, 320));
    tester.view.viewInsets = const FakeViewPadding(bottom: 150);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.byWidgetPredicate(
            (widget) => widget is MovieCard && widget.movie.title == 'Arrival'),
        120,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    expect(find.byType(MovieCard).first.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tablet grid supports enlarged accessibility text',
      (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await open(tester, const Size(800, 1000));
    await tester.scrollUntilVisible(find.text('The Grand Budapest Hotel'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('poster failure displays a fallback', (tester) async {
    await open(tester, const Size(430, 1000));
    // Flutter widget tests return HTTP 400 for real network images.
    expect(find.byIcon(Icons.movie_outlined), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
