import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/article.dart';
import '../../data/repositories/news_repository.dart';

part 'news_provider.g.dart';

@riverpod
class NewsFeed extends _$NewsFeed {
  @override
  FutureOr<List<Article>> build({String category = 'business'}) async {
    return ref.read(newsRepositoryProvider).getTopHeadlines(category: category);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return ref
          .read(newsRepositoryProvider)
          .getTopHeadlines(category: category);
    });
  }

  Future<void> loadMore() async {
    final previousState = state;
    if (previousState.isLoading || !previousState.hasValue) return;

    final articles = previousState.value!;
    final page = (articles.length / 20).ceil() + 1;

    state = await AsyncValue.guard(() async {
      final newArticles = await ref
          .read(newsRepositoryProvider)
          .getTopHeadlines(category: category, page: page);
      return [...articles, ...newArticles];
    });
  }
}

@riverpod
class SearchNews extends _$SearchNews {
  @override
  FutureOr<List<Article>> build(String query) async {
    if (query.isEmpty) return [];
    return ref.read(newsRepositoryProvider).getTopHeadlines(query: query);
  }
}
