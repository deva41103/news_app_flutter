import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/article.dart';
import '../../../../core/network/dio_client.dart';

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepository(ref.read(dioProvider));
});

class NewsRepository {
  final Dio _dio;
  static const _apiKey = 'ce263279b5154dafbb13b6df17d8abf1';

  NewsRepository(this._dio);

  Future<List<Article>> getTopHeadlines({
    String category = 'business',
    int page = 1,
    String? query,
  }) async {
    try {
      final bool isSearch = query != null;
      final response = await _dio.get(
        isSearch ? 'everything' : 'top-headlines',
        queryParameters: {
          if (isSearch)
            'q': query
          else ...{
            'category': category,
            'language': 'en',
          },
          'page': page,
          'pageSize': 20,
          'apiKey': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> articlesJson = response.data['articles'];
        return articlesJson
            .where((json) => json['title'] != '[Removed]')
            .map((json) => Article.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load news');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Network error');
    }
  }
}
