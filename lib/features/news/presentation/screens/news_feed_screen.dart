import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/news_provider.dart';
import '../widgets/article_card.dart';
import 'search_screen.dart';
import 'article_detail_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class NewsFeedScreen extends ConsumerStatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  ConsumerState<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends ConsumerState<NewsFeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = [
    'business',
    'technology',
    'science',
    'health',
    'entertainment',
    'sports',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Intelligence',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: const Color(0xFFE50914),
          labelColor: Theme.of(context).colorScheme.onSurface,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: _categories
              .map((c) => Tab(text: c[0].toUpperCase() + c.substring(1)))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _categories
            .map((cat) => _CategoryFeedList(category: cat))
            .toList(),
      ),
    );
  }
}

class _CategoryFeedList extends ConsumerStatefulWidget {
  final String category;
  const _CategoryFeedList({required this.category});

  @override
  ConsumerState<_CategoryFeedList> createState() => _CategoryFeedListState();
}

class _CategoryFeedListState extends ConsumerState<_CategoryFeedList> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    await ref
        .read(newsFeedProvider(category: widget.category).notifier)
        .loadMore();
    if (mounted) setState(() => _isLoadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    final newsAsync = ref.watch(newsFeedProvider(category: widget.category));

    return newsAsync.when(
      data: (articles) {
        if (articles.isEmpty) {
          return const Center(child: Text('No articles found.'));
        }
        return RefreshIndicator(
          onRefresh: () => ref
              .read(newsFeedProvider(category: widget.category).notifier)
              .refresh(),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: articles.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == articles.length) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final article = articles[index];
              return ArticleCard(
                article: article,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArticleDetailScreen(article: article),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Failed to load news',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(newsFeedProvider(category: widget.category)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
