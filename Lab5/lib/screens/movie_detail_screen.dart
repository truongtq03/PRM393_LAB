// ============================================================================
// Step 4: Build Movie Detail Screen (Hero banner, Chips, Overview, Actions, Trailers)
// File: lib/screens/movie_detail_screen.dart
// ============================================================================

import 'package:flutter/material.dart';
import '../models/movie.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.movie.isFavorite;
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
      widget.movie.isFavorite = _isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite
              ? 'Đã thêm "${widget.movie.title}" vào mục Yêu thích! ❤️'
              : 'Đã bỏ "${widget.movie.title}" khỏi mục Yêu thích.',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(movie.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Banner (Stack + Image.network + Gradient)
            Stack(
              children: [
                Image.network(
                  movie.posterUrl,
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 240,
                    color: Colors.grey.shade400,
                    child: const Icon(Icons.broken_image, size: 60),
                  ),
                ),
                // Lớp gradient chuyển dần sang tối ở đáy
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black87],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                // Tên phim nằm đè lên góc dưới banner
                Positioned(
                  left: 16,
                  bottom: 16,
                  right: 16,
                  child: Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(color: Colors.black, blurRadius: 4),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Title & Genres displayed as chips (Wrap + Chip)
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: movie.genres
                        .map(
                          (genre) => Chip(
                            label: Text(
                              genre,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: const Color(0xFFF3F4F9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),

                  // 3. Overview text with Padding
                  Text(
                    movie.overview,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. Row of Action Buttons (Favorite, Rate, Share)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Nút Yêu thích có cập nhật trạng thái (Stateful)
                      InkWell(
                        onTap: _toggleFavorite,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Column(
                            children: [
                              Icon(
                                _isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: _isFavorite ? Colors.red : Colors.grey.shade700,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Favorite',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _isFavorite ? Colors.red : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Nút Đánh giá (Rate)
                      InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đánh giá cho phim: ${movie.rating} ⭐')),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Column(
                            children: [
                              Icon(Icons.star, color: Colors.grey.shade700),
                              const SizedBox(height: 4),
                              Text(
                                'Rate',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Nút Chia sẻ (Share)
                      InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Chia sẻ liên kết phim "${movie.title}"')),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Column(
                            children: [
                              Icon(Icons.share, color: Colors.grey.shade700),
                              const SizedBox(height: 4),
                              Text(
                                'Share',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  // 5. Section: List of trailers
                  const Text(
                    'Trailers',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: movie.trailers.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.play_circle_fill,
                          color: Colors.black87,
                          size: 26,
                        ),
                        title: Text(
                          movie.trailers[index],
                          style: const TextStyle(fontSize: 14),
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đang phát: ${movie.trailers[index]}')),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
