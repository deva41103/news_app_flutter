import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import '../../../../features/news/domain/models/article.dart';

const _favoritesBoxName = 'favorites';

/// Manual Notifier (not code-generated) to avoid Riverpod generator
/// issues with List<Article> as a parameterized state type.
class FavoritesNotifier extends Notifier<List<Article>> {
  @override
  List<Article> build() {
    final box = Hive.box(_favoritesBoxName);
    final raw = box.get('articles', defaultValue: <dynamic>[]) as List<dynamic>;
    return raw
        .map((e) => Article.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> add(Article article) async {
    if (state.any((a) => a.url == article.url)) return;
    state = [...state, article];
    await _persist();
  }

  Future<void> remove(Article article) async {
    state = state.where((a) => a.url != article.url).toList();
    await _persist();
  }

  bool isFavorite(String url) => state.any((a) => a.url == url);

  Future<void> _persist() async {
    final box = Hive.box(_favoritesBoxName);
    await box.put('articles', state.map((a) => a.toJson()).toList());
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, List<Article>>(
  FavoritesNotifier.new,
);
