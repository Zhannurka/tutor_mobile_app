import 'package:flutter/material.dart';

// ========================================================
// MODELS
// ========================================================

class Author {
  final String name;
  final String title;
  final String avatarUrl;

  const Author({
    required this.name,
    required this.title,
    required this.avatarUrl,
  });
}

class Article {
  final String id;
  final Author author;
  final String title;
  final String excerpt;
  final String imageUrl;
  final String timeAgo;
  final int likes;
  final int comments;
  final bool isLiked;

  const Article({
    required this.id,
    required this.author,
    required this.title,
    required this.excerpt,
    required this.imageUrl,
    required this.timeAgo,
    required this.likes,
    required this.comments,
    this.isLiked = false,
  });
}

class Comment {
  final String id;
  final String authorName;
  final String authorAvatarUrl;
  final String text;
  final String timeAgo;
  final int likes;

  const Comment({
    required this.id,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.text,
    required this.timeAgo,
    required this.likes,
  });
}

// ========================================================
// MOCK DATA
// ========================================================

const Author tailaqMadina = Author(
  name: 'Тайлақ Мадина',
  title: 'Математика пәні репетиторы',
  avatarUrl: 'assets/madina.jpeg',
);

const Author toleybaiAyauzhan = Author(
  name: 'Төлеубай Аяужан',
  title: 'Социология маманы',
  avatarUrl: 'assets/ayauzhan.jpeg',
);

final List<Article> mockArticles = [
  Article(
    id: 'a1',
    author: tailaqMadina,
    title: 'Математика — түсінікті және қызықты',
    excerpt:
        'Математиканы нөлден бастап үйренгісі келетіндерге арналған тиімді тәсілдер. Оқуды жеңіл әрі қызықты ету жолдары.',
    imageUrl: 'assets/madina.jpeg',
    timeAgo: '3 апта бұрын',
    likes: 24,
    comments: 5,
  ),
  Article(
    id: 'a2',
    author: toleybaiAyauzhan,
    title: 'Социология әлеміне саяхат',
    excerpt:
        'Қоғамды зерттеу арқылы өзіңді түсінуге мүмкіндік беретін ғылым — социология. Бұл мақалада негізгі бағыттар қарастырылады.',
    imageUrl: 'assets/ayauzhan.jpeg',
    timeAgo: '2 апта бұрын',
    likes: 12,
    comments: 3,
  ),
];

final List<Comment> mockComments = [
  const Comment(
    id: 'c1',
    authorName: 'Тайлақ Мадина',
    authorAvatarUrl: 'assets/madina.jpeg',
    text: 'Тамаша!',
    timeAgo: '3 апта бұрын',
    likes: 10,
  ),
  const Comment(
    id: 'c2',
    authorName: 'Төлеубай Аяужан',
    authorAvatarUrl: 'assets/ayauzhan.jpeg',
    text: 'Рахмет!',
    timeAgo: '5 мин бұрын',
    likes: 4,
  ),
];

// ========================================================
// ARTICLES SCREEN (UI)
// ========================================================

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  int _currentIndex = 3; // "Статьи" индексі

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/studentHome');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/mentorSearch');
        break;
      case 2:
        // Чат қажет болмаса, бұл жерде ештеңе жазудың қажеті жоқ
        break;
      case 3:
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }

    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text(
          'Мақалалар',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.builder(
        itemCount: mockArticles.length,
        itemBuilder: (context, index) {
          final article = mockArticles[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ArticleDetailScreen(article: article),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      article.imageUrl,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            article.excerpt,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: AssetImage(
                                  article.author.avatarUrl,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  article.author.name,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              Text(
                                article.timeAgo,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),

      // ✅ ТӨМЕНГІ НАВИГАЦИЯ ПАНЕЛІ
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: const Color(0xFF4C75FF),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Репетиторы',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Чаты'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Статьи'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }
}

// ========================================================
// ARTICLE DETAIL SCREEN
// ========================================================

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          article.title,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              article.imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: AssetImage(article.author.avatarUrl),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        article.author.name,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const Spacer(),
                      Text(
                        article.timeAgo,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "${article.excerpt}\n\n${article.excerpt}",
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const Text(
                    'Пікірлер',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...mockComments.map((c) => _buildComment(c)).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComment(Comment c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage(c.authorAvatarUrl),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.authorName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(c.text),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      c.timeAgo,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.thumb_up_alt_outlined,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${c.likes}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
