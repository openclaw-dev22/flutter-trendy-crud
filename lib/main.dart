import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main.g.dart';

// --- Models ---
class Post {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  Post copyWith({String? title, String? content}) {
    return Post(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
    );
  }
}

// --- Providers (Riverpod Generator Style) ---
@riverpod
class Posts extends _$Posts {
  @override
  List<Post> build() => [
        Post(
          id: '1',
          title: 'Welcome to Bento Feed',
          content: 'This is a trendy CRUD example using Riverpod and Flutter.',
          createdAt: DateTime.now(),
        ),
        Post(
          id: '2',
          title: 'Design Trends 2026',
          content: 'Bento Grids and Glassmorphism are everywhere!',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];

  void addPost(String title, String content) {
    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
    );
    state = [newPost, ...state];
  }

  void updatePost(String id, String title, String content) {
    state = [
      for (final post in state)
        if (post.id == id) post.copyWith(title: title, content: content) else post
    ];
  }

  void deletePost(String id) {
    state = state.where((post) => post.id != id).toList();
  }
}

// --- UI Components ---
void main() {
  runApp(const ProviderScope(child: BentoApp()));
}

class BentoApp extends StatelessWidget {
  const BentoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            backgroundColor: Colors.transparent,
            title: const Text('Bento Feed', style: TextStyle(fontWeight: FontWeight.w900)),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
              const SizedBox(width: 8),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = posts[index];
                  // Alternating height for bento feel
                  return BentoCard(post: post);
                },
                childCount: posts.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditDialog(context, ref),
        label: const Text('New Post'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple[900],
        foregroundColor: Colors.white,
      ),
    );
  }
}

class BentoCard extends ConsumerWidget {
  final Post post;
  const BentoCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showEditDialog(context, ref, post: post),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Update',
                style: TextStyle(
                  color: Colors.deepPurple[900],
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            Text(
              post.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              post.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => ref.read(postsProvider.notifier).deletePost(post.id),
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

void _showEditDialog(BuildContext context, WidgetRef ref, {Post? post}) {
  final titleController = TextEditingController(text: post?.title);
  final contentController = TextEditingController(text: post?.content);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 32,
        right: 32,
        top: 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post == null ? 'Create Post' : 'Edit Post',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: 'Title',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: contentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Write something...',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                if (post == null) {
                  ref.read(postsProvider.notifier).addPost(
                    titleController.text,
                    contentController.text,
                  );
                } else {
                  ref.read(postsProvider.notifier).updatePost(
                    post.id,
                    titleController.text,
                    contentController.text,
                  );
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple[900],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Save Post', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    ),
  );
}
