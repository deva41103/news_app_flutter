// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NewsFeed)
final newsFeedProvider = NewsFeedFamily._();

final class NewsFeedProvider
    extends $AsyncNotifierProvider<NewsFeed, List<Article>> {
  NewsFeedProvider._({
    required NewsFeedFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'newsFeedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$newsFeedHash();

  @override
  String toString() {
    return r'newsFeedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  NewsFeed create() => NewsFeed();

  @override
  bool operator ==(Object other) {
    return other is NewsFeedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$newsFeedHash() => r'42cd9bf7d0596fc964ddc03fc00620d5b6b9b1de';

final class NewsFeedFamily extends $Family
    with
        $ClassFamilyOverride<
          NewsFeed,
          AsyncValue<List<Article>>,
          List<Article>,
          FutureOr<List<Article>>,
          String
        > {
  NewsFeedFamily._()
    : super(
        retry: null,
        name: r'newsFeedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NewsFeedProvider call({String category = 'business'}) =>
      NewsFeedProvider._(argument: category, from: this);

  @override
  String toString() => r'newsFeedProvider';
}

abstract class _$NewsFeed extends $AsyncNotifier<List<Article>> {
  late final _$args = ref.$arg as String;
  String get category => _$args;

  FutureOr<List<Article>> build({String category = 'business'});
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Article>>, List<Article>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Article>>, List<Article>>,
              AsyncValue<List<Article>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(category: _$args));
  }
}

@ProviderFor(SearchNews)
final searchNewsProvider = SearchNewsFamily._();

final class SearchNewsProvider
    extends $AsyncNotifierProvider<SearchNews, List<Article>> {
  SearchNewsProvider._({
    required SearchNewsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchNewsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchNewsHash();

  @override
  String toString() {
    return r'searchNewsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SearchNews create() => SearchNews();

  @override
  bool operator ==(Object other) {
    return other is SearchNewsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchNewsHash() => r'81175e36634c3216aed88cc0fd01d176cb81056e';

final class SearchNewsFamily extends $Family
    with
        $ClassFamilyOverride<
          SearchNews,
          AsyncValue<List<Article>>,
          List<Article>,
          FutureOr<List<Article>>,
          String
        > {
  SearchNewsFamily._()
    : super(
        retry: null,
        name: r'searchNewsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchNewsProvider call(String query) =>
      SearchNewsProvider._(argument: query, from: this);

  @override
  String toString() => r'searchNewsProvider';
}

abstract class _$SearchNews extends $AsyncNotifier<List<Article>> {
  late final _$args = ref.$arg as String;
  String get query => _$args;

  FutureOr<List<Article>> build(String query);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Article>>, List<Article>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Article>>, List<Article>>,
              AsyncValue<List<Article>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
