// ============================================================================
// Step 3: Build Home Screen (Displays scrollable list of movies)
// File: lib/screens/home_screen.dart
// ============================================================================

import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Movie> _filteredMovies = sampleMovies;
  final TextEditingController _searchController = TextEditingController();

  void _filterMovies(String query) {
    setState(() {
      _filteredMovies = sampleMovies
          .where((movie) =>
              movie.title.toLowerCase().contains(query.toLowerCase()) ||
              movie.genres.any((g) => g.toLowerCase().contains(query.toLowerCase())))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: const Text(
          'Movies',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm phim (Tính năng tùy chọn nâng cao theo đề bài)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _filterMovies,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm tên phim hoặc thể loại...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),

          // Danh sách phim sử dụng ListView.separated
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredMovies.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final movie = _filteredMovies[index];
                return Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    // Yêu cầu kỹ thuật: Navigator.push truyền đối tượng Movie sang màn hình chi tiết
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetailScreen(movie: movie),
                        ),
                      ).then((_) {
                        // Cập nhật lại UI nếu trạng thái Favorite thay đổi
                        setState(() {});
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          // Ảnh Thumbnail của phim
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              movie.posterUrl,
                              width: 65,
                              height: 65,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 65,
                                height: 65,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.movie, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Thông tin tiêu đề, rating, thể loại
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '☆ ${movie.rating} • ${movie.genres.join(', ')}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Biểu tượng chuyển trang
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
