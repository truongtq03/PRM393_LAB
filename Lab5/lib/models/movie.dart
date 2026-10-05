// ============================================================================
// Step 2: Define Data Model & Sample Data (Movie Model)
// File: lib/models/movie.dart
// ============================================================================

class Movie {
  final int id;
  final String title;
  final String posterUrl;
  final String overview;
  final List<String> genres;
  final double rating;
  final List<String> trailers;
  bool isFavorite;

  Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.overview,
    required this.genres,
    required this.rating,
    required this.trailers,
    this.isFavorite = false,
  });
}

// Danh sách dữ liệu mẫu mô phỏng y hệt các phim trong đề bài (Ảnh 1 & Ảnh 2)
final List<Movie> sampleMovies = [
  Movie(
    id: 1,
    title: 'Dune: Part Two',
    posterUrl:
        'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800&auto=format&fit=crop&q=60',
    overview:
        'Paul Atreides unites with Chani and the Fremen while seeking revenge against the conspirators who destroyed his family.',
    genres: ['Sci-Fi', 'Adventure', 'Drama'],
    rating: 8.6,
    trailers: ['Official Trailer #1', 'IMAX Sneak Peek'],
  ),
  Movie(
    id: 2,
    title: 'Deadpool & Wolverine',
    posterUrl:
        'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800&auto=format&fit=crop&q=60',
    overview:
        'The multiverse gets messy when Wade Wilson teams up with Wolverine for a not-so-family-friendly mission.',
    genres: ['Action', 'Comedy'],
    rating: 8.3,
    trailers: ['Red Band Trailer', 'Behind the Scenes'],
  ),
  Movie(
    id: 3,
    title: 'Interstellar',
    posterUrl:
        'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800&auto=format&fit=crop&q=60',
    overview:
        'When Earth becomes uninhabitable in the future, a farmer and ex-NASA pilot is tasked to pilot a spacecraft along with a team of researchers to find a new planet.',
    genres: ['Sci-Fi', 'Drama', 'Adventure'],
    rating: 8.7,
    trailers: ['Teaser Trailer', 'Official Trailer #2'],
  ),
];
