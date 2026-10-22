import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Lab 8.1–8.4 and optional POST. Paste into DartPad Flutter with http enabled.
void main() => runApp(const PostApp());

// Lab 8.2: the model validates JSON at the service boundary.
class Post {
  final int id;
  final int userId;
  final String title;
  final String body;

  const Post(
      {required this.id,
      required this.userId,
      required this.title,
      required this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    if (json['id'] is! int ||
        json['userId'] is! int ||
        json['title'] is! String ||
        json['body'] is! String) {
      throw const FormatException('Invalid post fields.');
    }
    return Post(
        id: json['id'] as int,
        userId: json['userId'] as int,
        title: json['title'] as String,
        body: json['body'] as String);
  }
}

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
  @override
  String toString() => message;
}

// Lab 8.4: an injectable http.Client keeps networking independent of widgets.
class ApiService {
  final http.Client _client;
  final Duration timeout;
  static final postsUri = Uri.https('jsonplaceholder.typicode.com', '/posts');

  ApiService({http.Client? client, this.timeout = const Duration(seconds: 15)})
      : _client = client ?? http.Client();

  Future<http.Response> _send(Future<http.Response> request) async {
    try {
      return await request.timeout(timeout);
    } on TimeoutException {
      throw const ApiException('The request timed out. Please try again.');
    } on http.ClientException {
      throw const ApiException(
          'Unable to connect. Check your internet connection and try again.');
    }
  }

  dynamic _decode(http.Response response, int expectedStatus) {
    if (response.statusCode != expectedStatus) {
      throw ApiException('The server returned HTTP ${response.statusCode}. '
          'Please try again later.');
    }
    return json.decode(utf8.decode(response.bodyBytes));
  }

  // Lab 8.1 + 8.2: GET -> decode a JSON array -> List<Post>.
  Future<List<Post>> fetchPosts() async {
    final response = await _send(_client.get(postsUri));
    try {
      final decoded = _decode(response, 200);
      if (decoded is! List) throw const FormatException('Expected a list.');
      return decoded.map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Expected a post object.');
        }
        return Post.fromJson(item);
      }).toList();
    } on FormatException {
      throw const ApiException(
          'The server sent invalid data. Please try again.');
    }
  }

  // Bonus: JSONPlaceholder simulates creation; it does not persist the post.
  Future<Post> createPost({required String title, required String body}) async {
    final response = await _send(_client.post(
      postsUri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json
          .encode({'title': title.trim(), 'body': body.trim(), 'userId': 1}),
    ));
    try {
      final decoded = _decode(response, 201);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected an object.');
      }
      return Post.fromJson(decoded);
    } on FormatException {
      throw const ApiException(
          'The server sent invalid data. Please try again.');
    }
  }

  void close() => _client.close();
}

class PostApp extends StatelessWidget {
  // An injected service is owned by its caller, useful for deterministic tests.
  final ApiService? service;
  const PostApp({super.key, this.service});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Lab 8 • API Posts',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2856BA)),
          scaffoldBackgroundColor: const Color(0xFFF4F6FA),
          inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white),
        ),
        home: PostListScreen(service: service),
      );
}

class PostListScreen extends StatefulWidget {
  final ApiService? service;
  const PostListScreen({super.key, this.service});
  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  late final ApiService _service;
  late Future<List<Post>> _postsFuture;
  final List<Post> _createdPosts = [];

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? ApiService();
    // Cache the Future here: ordinary rebuilds must not issue another GET.
    _postsFuture = _service.fetchPosts();
  }

  @override
  void dispose() {
    if (widget.service == null) _service.close();
    super.dispose();
  }

  Future<void> _reload() async {
    final request = _service.fetchPosts();
    setState(() {
      _postsFuture = request;
    });
    // FutureBuilder renders errors; RefreshIndicator still needs to finish.
    try {
      await request;
    } catch (_) {/* Handled in the builder below. */}
  }

  Future<void> _createPost() async {
    final result = await Navigator.of(context).push<Post>(MaterialPageRoute(
      builder: (_) => CreatePostScreen(service: _service),
    ));
    if (!mounted || result == null) return;
    setState(() => _createdPosts.insert(0, result));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          'POST succeeded • ID ${result.id}. Saved locally for this session.'),
    ));
  }

  Widget _status(
          {required IconData icon,
          required String title,
          required String message,
          required String action}) =>
      ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 64),
        children: [
          Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 20),
          Text(title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Center(
              child: FilledButton.icon(
                  onPressed: _reload,
                  icon: const Icon(Icons.refresh),
                  label: Text(action))),
        ],
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('API Posts'), actions: [
          IconButton(
              tooltip: 'New post',
              onPressed: _createPost,
              icon: const Icon(Icons.add_circle_outline)),
        ]),
        body: SafeArea(
            child: Center(
                child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          // Lab 8.3: loading, error, empty and success are explicit states.
          child: FutureBuilder<List<Post>>(
            future: _postsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 18),
                    Text('Loading posts…')
                  ],
                ));
              }
              if (snapshot.hasError) {
                return RefreshIndicator(
                    onRefresh: _reload,
                    child: _status(
                      icon: Icons.cloud_off_outlined,
                      title: 'Could not load posts',
                      message: snapshot.error is ApiException
                          ? (snapshot.error as ApiException).message
                          : 'Something went wrong. Please try again.',
                      action: 'Retry',
                    ));
              }
              final posts = [..._createdPosts, ...?snapshot.data];
              if (posts.isEmpty) {
                return RefreshIndicator(
                    onRefresh: _reload,
                    child: _status(
                      icon: Icons.inbox_outlined,
                      title: 'No posts yet',
                      message: 'The API returned an empty list.',
                      action: 'Reload',
                    ));
              }
              return Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
                  child: Row(children: [
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${posts.length} ${posts.length == 1 ? 'post' : 'posts'}',
                            style: Theme.of(context).textTheme.titleLarge),
                        const Text('JSONPlaceholder • REST API',
                            style: TextStyle(color: Color(0xFF576579)))
                      ],
                    )),
                    IconButton(
                        tooltip: 'Refresh posts',
                        onPressed: _reload,
                        icon: const Icon(Icons.refresh)),
                  ]),
                ),
                Expanded(
                    child: RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return Card(
                        elevation: 0,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(child: Text('${post.id}')),
                          title: Text(post.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                  _createdPosts.contains(post)
                                      ? 'Created locally • User ${post.userId}'
                                      : post.body.replaceAll('\n', ' '),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      PostDetailScreen(post: post))),
                        ),
                      );
                    },
                  ),
                )),
              ]);
            },
          ),
        ))),
      );
}

class PostDetailScreen extends StatelessWidget {
  final Post post;
  const PostDetailScreen({super.key, required this.post});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Post #${post.id}')),
        body: SafeArea(
            child: Center(
                child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(padding: const EdgeInsets.all(24), children: [
            Text('POST ${post.id} • USER ${post.userId}',
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 18),
            Text(post.title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            Text(post.body, style: const TextStyle(fontSize: 17, height: 1.6)),
          ]),
        ))),
      );
}

class CreatePostScreen extends StatefulWidget {
  final ApiService service;
  const CreatePostScreen({super.key, required this.service});
  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _body = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final created =
          await widget.service.createPost(title: _title.text, body: _body.text);
      if (mounted) Navigator.of(context).pop(created);
    } catch (error) {
      if (mounted)
        setState(() {
          _saving = false;
          _error = error is ApiException
              ? error.message
              : 'Could not create the post. Try again.';
        });
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_saving,
        child: Scaffold(
          appBar: AppBar(title: const Text('Create a post')),
          body: SafeArea(
              child: Center(
                  child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const Text('Demo API: posts are not saved on the server. '
                        'Created items stay in your list only during this session.'),
                    const SizedBox(height: 24),
                    TextFormField(
                        controller: _title,
                        readOnly: _saving,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Enter a title.'
                                : null),
                    const SizedBox(height: 20),
                    TextFormField(
                        controller: _body,
                        readOnly: _saving,
                        minLines: 5,
                        maxLines: 10,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                            labelText: 'Body', alignLabelWithHint: true),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Enter the post body.'
                                : null),
                    if (_error != null)
                      Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Semantics(
                              liveRegion: true,
                              child: Text(_error!,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error)))),
                    const SizedBox(height: 24),
                    FilledButton(
                        onPressed: _saving ? null : _submit,
                        child: _saving
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)),
                              )
                            : const Text('Create post')),
                  ],
                )),
          ))),
        ),
      );
}
