import 'package:flutter/material.dart';

// Lab 6.1–6.3: this single file can be pasted into DartPad (Flutter).
void main() {
  runApp(const ResponsiveMovieApp());
}

class ResponsiveMovieApp extends StatelessWidget {
  const ResponsiveMovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Genre Browsing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        useMaterial3: true,
      ),
      home: const GenreScreen(),
    );
  }
}

class Movie {
  final String title;
  final int year;
  final List<String> genres;
  final String posterUrl;
  final double rating;

  const Movie({
    required this.title,
    required this.year,
    required this.genres,
    required this.posterUrl,
    required this.rating,
  });
}

const List<Movie> allMovies = [
  Movie(
    title: 'Dune: Part Two',
    year: 2024,
    genres: ['Sci-Fi', 'Adventure', 'Drama'],
    posterUrl:
        'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800&auto=format&fit=crop&q=60',
    rating: 8.6,
  ),
  Movie(
    title: 'Deadpool & Wolverine',
    year: 2024,
    genres: ['Action', 'Comedy'],
    posterUrl:
        'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800&auto=format&fit=crop&q=60',
    rating: 8.3,
  ),
  Movie(
    title: 'Interstellar',
    year: 2014,
    genres: ['Sci-Fi', 'Drama', 'Adventure'],
    posterUrl:
        'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800&auto=format&fit=crop&q=60',
    rating: 8.7,
  ),
  Movie(
    title: 'Inception',
    year: 2010,
    genres: ['Sci-Fi', 'Action', 'Thriller'],
    posterUrl:
        'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=800&auto=format&fit=crop&q=60',
    rating: 8.8,
  ),
  Movie(
    title: 'The Grand Budapest Hotel',
    year: 2014,
    genres: ['Comedy', 'Drama'],
    posterUrl:
        'https://images.unsplash.com/photo-1513106580091-1d82408b8cd6?w=800&auto=format&fit=crop&q=60',
    rating: 8.1,
  ),
  Movie(
    title: 'Arrival',
    year: 2016,
    genres: ['Sci-Fi', 'Drama'],
    posterUrl:
        'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800&auto=format&fit=crop&q=60',
    rating: 7.9,
  ),
];

class GenreScreen extends StatefulWidget {
  const GenreScreen({super.key});

  @override
  State<GenreScreen> createState() => _GenreScreenState();
}

// Lab 6.2: search and genres are combined with AND; genres use OR.
// Return a new list so sorting never mutates the sample data.
List<Movie> filterMovies({
  String query = '',
  Set<String> genres = const {},
  String sort = 'A-Z',
}) {
  final search = query.trim().toLowerCase();
  final movies = allMovies.where((movie) {
    return movie.title.toLowerCase().contains(search) &&
        (genres.isEmpty || movie.genres.any(genres.contains));
  }).toList();
  movies.sort((a, b) {
    final int result;
    switch (sort) {
      case 'Z-A':
        result = b.title.toLowerCase().compareTo(a.title.toLowerCase());
      case 'Year':
        result = b.year.compareTo(a.year);
      case 'Rating':
        result = b.rating.compareTo(a.rating);
      default:
        result = a.title.toLowerCase().compareTo(b.title.toLowerCase());
    }
    return result == 0 ? a.title.compareTo(b.title) : result;
  });
  return movies;
}

class _GenreScreenState extends State<GenreScreen> {
  static const genres = [
    'Action',
    'Comedy',
    'Drama',
    'Sci-Fi',
    'Adventure',
    'Thriller',
  ];
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final Set<String> selectedGenres = {};
  String selectedSort = 'A-Z';

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateResults(VoidCallback update) {
    setState(update);
    // Keep the updated results reachable after changing a filter.
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  void clearFilters() {
    FocusScope.of(context).unfocus();
    _updateResults(() {
      _searchController.clear();
      selectedGenres.clear();
      selectedSort = 'A-Z';
    });
  }

  Widget _filters(int count) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lab 6.1: heading wraps naturally instead of using a fixed height.
          const Text('Find a Movie',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827))),
          const SizedBox(height: 6),
          const Text(
              'Discover your next favorite. Search, filter, and explore.',
              style: TextStyle(color: Color(0xFF596579))),
          const SizedBox(height: 22),
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            onChanged: (_) => _updateResults(() {}),
            decoration: InputDecoration(
              labelText: 'Search movie title',
              hintText: 'Try Dune or Interstellar',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () => _updateResults(_searchController.clear),
                      icon: const Icon(Icons.close),
                    ),
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Genres',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              if (selectedGenres.isNotEmpty)
                Chip(
                    label: Text('${selectedGenres.length} selected'),
                    backgroundColor: const Color(0xFFEEF2FF)),
            ],
          ),
          const SizedBox(height: 10),
          // Lab 6.2: multiple genres can be toggled independently.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: genres
                .map((genre) => FilterChip(
                      label: Text(genre),
                      selected: selectedGenres.contains(genre),
                      onSelected: (selected) => _updateResults(() {
                        if (selected) {
                          selectedGenres.add(genre);
                        } else {
                          selectedGenres.remove(genre);
                        }
                      }),
                      selectedColor: const Color(0xFFE0E7FF),
                      backgroundColor: Colors.white,
                    ))
                .toList(),
          ),
          const SizedBox(height: 18),
          // Wrap keeps the sort controls usable on narrow screens / large text.
          Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Sort by',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              DecoratedBox(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD1D5DB))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedSort,
                      borderRadius: BorderRadius.circular(12),
                      items: ['A-Z', 'Z-A', 'Year', 'Rating']
                          .map((sort) =>
                              DropdownMenuItem(value: sort, child: Text(sort)))
                          .toList(),
                      onChanged: (sort) {
                        if (sort != null)
                          _updateResults(() => selectedSort = sort);
                      },
                    ),
                  ),
                ),
              ),
              if (selectedGenres.isNotEmpty ||
                  _searchController.text.isNotEmpty ||
                  selectedSort != 'A-Z')
                TextButton.icon(
                  onPressed: clearFilters,
                  icon: const Icon(Icons.filter_alt_off_outlined),
                  label: const Text('Clear filters'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Semantics(
            liveRegion: true,
            child: Text('$count ${count == 1 ? 'movie' : 'movies'} found',
                style: const TextStyle(color: Color(0xFF596579))),
          ),
          const SizedBox(height: 16),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final movies = filterMovies(
        query: _searchController.text,
        genres: selectedGenres,
        sort: selectedSort);
    final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          // Lab 6.3: one consistent breakpoint BEFORE applying page padding.
          final wide = constraints.maxWidth >= 800;
          final padding = wide ? 28.0 : 16.0;
          // One scroll view includes the filters, so a short landscape viewport
          // or an open mobile keyboard cannot overflow a fixed header Column.
          return CustomScrollView(
            controller: _scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(padding, 24, padding, 0),
                sliver: SliverToBoxAdapter(child: _filters(movies.length)),
              ),
              if (movies.isEmpty)
                SliverPadding(
                  padding: EdgeInsets.all(padding),
                  sliver: SliverToBoxAdapter(
                    child: Column(children: [
                      const Icon(Icons.movie_filter_outlined,
                          size: 48, color: Color(0xFF6B7280)),
                      const SizedBox(height: 12),
                      const Text('No movies match your filters',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      const Text(
                          'Try another title or clear the selected genres.',
                          textAlign: TextAlign.center),
                      TextButton(
                          onPressed: clearFilters,
                          child: const Text('Reset filters')),
                    ]),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(padding, 0, padding, 24),
                  sliver: wide
                      ? SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            mainAxisExtent:
                                220 * (textScale < 1 ? 1 : textScale),
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => MovieCard(movie: movies[index]),
                            childCount: movies.length,
                          ),
                        )
                      : SliverList.separated(
                          itemCount: movies.length,
                          itemBuilder: (context, index) =>
                              MovieCard(movie: movies[index]),
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 14),
                        ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final Movie movie;
  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) => Card(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(builder: (context, constraints) {
            // Poster size follows the actual card width, including in the grid.
            final posterWidth = constraints.maxWidth < 320
                ? 80.0
                : constraints.maxWidth < 480
                    ? 104.0
                    : 140.0;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    movie.posterUrl,
                    width: posterWidth,
                    height: posterWidth * 1.5,
                    fit: BoxFit.cover,
                    semanticLabel: 'Illustrative poster for ${movie.title}',
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: posterWidth,
                      height: posterWidth * 1.5,
                      color: const Color(0xFFE0E7FF),
                      child: const Center(
                          child: Icon(Icons.movie_outlined,
                              size: 36, semanticLabel: 'Poster unavailable')),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(movie.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          Text('${movie.year}',
                              style: const TextStyle(color: Color(0xFF596579))),
                          Semantics(
                              label: 'Rating ${movie.rating} out of 10',
                              child: Text(
                                  '★ ${movie.rating.toStringAsFixed(1)}',
                                  style: const TextStyle(
                                      color: Color(0xFF8A5700),
                                      fontWeight: FontWeight.w700))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(movie.genres.join(' · '),
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF596579))),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      );
}
