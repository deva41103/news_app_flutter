# 📰 News Intelligence — Developer Reference

> **Version:** 1.0.0+1 | **Flutter SDK:** ^3.11.0 | **Last Updated:** March 2026

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Architecture](#2-architecture)
3. [Technology Stack & Libraries](#3-technology-stack--libraries)
4. [Project Structure](#4-project-structure)
5. [File-by-File Reference](#5-file-by-file-reference)
   - [Entry Point](#51-entry-point)
   - [Core Layer](#52-core-layer)
   - [Auth Feature](#53-feature-auth)
   - [News Feature](#54-feature-news)
   - [Favorites Feature](#55-feature-favorites)
6. [Data & State Flow](#6-data--state-flow)
7. [Navigation Flow](#7-navigation-flow)
8. [Local Persistence (Hive)](#8-local-persistence-hive)
9. [API Integration (NewsAPI)](#9-api-integration-newsapi)
10. [Code Generation](#10-code-generation)
11. [Running the Project](#11-running-the-project)

---

## 1. Project Overview

**News Intelligence** is a Flutter application that delivers curated news articles from the [NewsAPI.org](https://newsapi.org) REST API. Users log in with any credentials (demo auth backed by Hive), browse news by category, search globally, bookmark articles for offline reading, and open the full article in the system browser.

| Feature | Details |
|---|---|
| Authentication | Mock login persisted via Hive |
| News Feed | Category tabs (Business, Technology, Science, Health, Entertainment, Sports) |
| Infinite Scroll | Lazy-loads additional pages on scroll-end detection |
| Pull-to-Refresh | Swipe down to refetch the current category |
| Search | Full-text search via NewsAPI's `/everything` endpoint |
| Favorites | Bookmark articles — persisted locally in Hive, no network required |
| Article Detail | Hero image, metadata, content preview, and external link |
| Theming | Material 3, system-adaptive light/dark, Inter font via Google Fonts |

---

## 2. Architecture

The project follows **Clean Architecture** with a **Feature-First** folder structure.

```
lib/
├── core/           # Shared infrastructure (theme, network, navigation, errors)
└── features/       # Self-contained vertical slices
    ├── auth/
    ├── news/
    └── favorites/
```

Each feature is sub-divided into the classic Clean Architecture layers:

```
feature/
├── data/
│   └── repositories/   # Network / persistence calls
├── domain/
│   └── models/         # Pure Dart entities
└── presentation/
    ├── providers/       # Riverpod state notifiers
    ├── screens/         # Full-page UI widgets
    └── widgets/         # Reusable UI components
```

**State management** is handled entirely by **Riverpod 2** (code-generated with `riverpod_annotation` + `riverpod_generator`).

---

## 3. Technology Stack & Libraries

### Production Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter` | SDK | UI framework |
| `flutter_riverpod` | any | Reactive state management |
| `riverpod_annotation` | any | Annotations for code generation (`@riverpod`) |
| `dio` | any | HTTP client for the NewsAPI REST calls |
| `hive_ce` | any | Lightweight NoSQL key-value store (community edition) |
| `hive_ce_flutter` | any | Flutter integration for Hive CE |
| `intl` | any | Date formatting (`DateFormat.yMMMd()`) |
| `url_launcher` | any | Opens article URLs in the external browser |
| `google_fonts` | any | `Inter` typeface loaded from Google CDN |
| `shimmer` | any | *(imported, available for future loading skeletons)* |
| `flutter_spinkit` | any | *(imported, available for future loaders)* |
| `cached_network_image` | any | Disk-cached image loading with placeholder/error states |
| `freezed_annotation` | any | Immutability annotations *(available, not yet applied to Article)* |
| `json_annotation` | any | JSON serialization annotations |
| `cupertino_icons` | ^1.0.8 | iOS-style icon set |

### Dev Dependencies

| Package | Purpose |
|---|---|
| `riverpod_generator` | Generates `*.g.dart` boilerplate from `@riverpod` classes |
| `build_runner` | Orchestrates all code generators |
| `hive_ce_generator` | Generates Hive type adapters |
| `freezed` | Generates immutable data classes |
| `json_serializable` | Generates `fromJson`/`toJson` code |
| `build_verify` | CI assertion that generated files are up-to-date |
| `flutter_lints` | Lint rule set |

---

## 4. Project Structure

```
news_app/
├── lib/
│   ├── main.dart                                   ← App entry point
│   ├── core/
│   │   ├── error/
│   │   │   └── failures.dart                       ← Failure base classes
│   │   ├── navigation/
│   │   │   └── home_shell.dart                     ← Bottom nav scaffold
│   │   ├── network/
│   │   │   └── dio_client.dart                     ← Singleton Dio provider
│   │   └── theme/
│   │       └── app_theme.dart                      ← Light + Dark ThemeData
│   └── features/
│       ├── auth/
│       │   └── presentation/
│       │       ├── providers/
│       │       │   ├── auth_provider.dart           ← Auth state notifier
│       │       │   └── auth_provider.g.dart         ← [generated]
│       │       └── screens/
│       │           └── login_screen.dart            ← Login UI
│       ├── news/
│       │   ├── data/
│       │   │   └── repositories/
│       │   │       └── news_repository.dart         ← NewsAPI HTTP calls
│       │   ├── domain/
│       │   │   └── models/
│       │   │       └── article.dart                 ← Article & Source models
│       │   └── presentation/
│       │       ├── providers/
│       │       │   ├── news_provider.dart           ← NewsFeed + SearchNews notifiers
│       │       │   └── news_provider.g.dart         ← [generated]
│       │       ├── screens/
│       │       │   ├── news_feed_screen.dart        ← Category tabs + feed list
│       │       │   ├── article_detail_screen.dart   ← Full article view
│       │       │   └── search_screen.dart           ← Search UI
│       │       └── widgets/
│       │           └── article_card.dart            ← Reusable card widget
│       └── favorites/
│           └── presentation/
│               ├── providers/
│               │   └── favorites_provider.dart      ← Bookmarks notifier (Hive-backed)
│               └── screens/
│                   └── favorites_screen.dart        ← Saved articles list
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

## 5. File-by-File Reference

### 5.1 Entry Point

#### `lib/main.dart`

**Role:** Bootstraps the entire application.

**What it does:**
1. Calls `WidgetsFlutterBinding.ensureInitialized()` before any async work.
2. Initializes Hive and opens three boxes — `auth`, `favorites`, `settings`.
3. Wraps the widget tree in `ProviderScope` (required by Riverpod).
4. Builds `NewsApp` — a `ConsumerWidget` that:
   - Watches `authProvider` to determine the current auth state.
   - Conditionally renders `HomeShell` (authenticated) or `LoginScreen` (unauthenticated).
   - Applies `AppTheme.lightTheme` / `AppTheme.darkTheme` respecting `ThemeMode.system`.

**Key connections:**
- → `core/theme/app_theme.dart` for `AppTheme`
- → `core/navigation/home_shell.dart` for `HomeShell`
- → `features/auth/presentation/providers/auth_provider.dart` for `authProvider`
- → `features/auth/presentation/screens/login_screen.dart` for `LoginScreen`

---

### 5.2 Core Layer

#### `lib/core/error/failures.dart`

**Role:** Defines a typed failure hierarchy for structured error handling.

| Class | Default Message |
|---|---|
| `Failure` (abstract) | — base class |
| `ServerFailure` | `'Server Error'` |
| `CacheFailure` | `'Cache Error'` |
| `NetworkFailure` | `'No Internet Connection'` |
| `AuthFailure` | `'Authentication Failed'` |

These failure types can be thrown or returned by repositories and caught in providers to show user-facing error messages. The news repository currently throws raw `Exception`s; these classes are available to extend the error surface.

---

#### `lib/core/network/dio_client.dart`

**Role:** Creates and exposes a single, configured `Dio` HTTP client as a Riverpod provider.

**Configuration:**
- `baseUrl`: `https://newsapi.org/v2/`
- `connectTimeout` / `receiveTimeout`: 10 seconds each
- Adds `LogInterceptor` (logs request/response bodies to debug console)

**Provider:** `dioProvider` — a simple `Provider<Dio>`.

**Key connections:**
- ← consumed by `news_repository.dart` via `ref.read(dioProvider)`.

---

#### `lib/core/navigation/home_shell.dart`

**Role:** The root scaffold shown after successful login. Hosts the bottom navigation bar and page switching.

**Implementation details:**
- `ConsumerStatefulWidget` with `_selectedIndex` state.
- Uses `IndexedStack` to keep page state alive across tab switches (avoids re-fetching on tab change).
- Two destinations: **Feed** (`NewsFeedScreen`) and **Saved** (`FavoritesScreen`).

**Key connections:**
- → `features/news/presentation/screens/news_feed_screen.dart`
- → `features/favorites/presentation/screens/favorites_screen.dart`
- ← rendered by `main.dart` when `authProvider` is `true`

---

#### `lib/core/theme/app_theme.dart`

**Role:** Centralizes all theming — colors, typography, card shapes, and AppBar style.

**Design tokens:**
| Token | Light | Dark |
|---|---|---|
| Primary | `#1A1A1A` (near-black) | `Colors.white` |
| Secondary / Accent | `#E50914` (bold red) | `#E50914` |
| Surface | `Colors.white` | `#121212` |
| Font | Inter (Google Fonts) | Inter (Google Fonts) |
| Card radius | 16 px | 16 px |
| Material version | Material 3 | Material 3 |

**Key connections:**
- ← used in `main.dart` as `theme:` and `darkTheme:`.
- `GoogleFonts.interTextTheme()` pulls the Inter font from Google CDN at runtime.

---

### 5.3 Feature: Auth

#### `lib/features/auth/presentation/providers/auth_provider.dart`

**Role:** Manages the global authentication boolean state, persisted in Hive.

**State type:** `bool` (is the user logged in?)

**Behaviour:**
- `build()` — reads `isLoggedIn` from the `auth` Hive box (defaults `false` on first run).
- `login(email, password)` — any non-empty credentials are accepted (demo); sets `isLoggedIn = true` in Hive and updates `state`.
- `logout()` — sets `isLoggedIn = false` in Hive and updates `state`.

**Code generation:** `@riverpod` → generates `auth_provider.g.dart` containing `authProvider` (a `NotifierProvider<Auth, bool>`).

**Key connections:**
- → `hive_ce_flutter` (reads/writes `auth` box)
- ← watched in `main.dart` to decide root widget
- ← logout triggered from `news_feed_screen.dart` AppBar action

---

#### `lib/features/auth/presentation/screens/login_screen.dart`

**Role:** The app's entry screen for unauthenticated users.

**UI elements:**
- Newspaper icon logo, app title, subtitle.
- Email `TextFormField` (validates non-empty).
- Password `TextFormField` with show/hide toggle (validates non-empty).
- `FilledButton` — shows `CircularProgressIndicator` while logging in.
- A note reminding the user that any credentials work (demo).

**Behaviour:**
- `_handleLogin()`: validates the form, shows a 600 ms simulated delay, then calls `authProvider.notifier.login(...)`. On success, `main.dart` rebuilds with `HomeShell`.

**Key connections:**
- → `auth_provider.dart` for `authProvider`

---

### 5.4 Feature: News

#### `lib/features/news/domain/models/article.dart`

**Role:** The core domain entity. Completely pure Dart — no framework dependencies.

**`Article` fields:**

| Field | Type | Notes |
|---|---|---|
| `title` | `String` | Required |
| `description` | `String?` | Optional lead text |
| `url` | `String` | Required — used as the unique identity key |
| `urlToImage` | `String?` | Hero image URL |
| `publishedAt` | `DateTime` | Required |
| `content` | `String?` | Truncated body from API |
| `source` | `Source?` | Nested source info |
| `author` | `String?` | Byline |

**`Source` fields:** `id` (`String?`), `name` (`String`).

**Key methods:**
- `Article.fromJson(Map)` — hand-written JSON deserializer.
- `toJson()` — used to serialize articles to Hive storage.
- `copyWith(...)` — creates a modified copy (immutable update pattern).
- `operator ==` / `hashCode` — identity is based on `url`, preventing duplicate bookmarks.

---

#### `lib/features/news/data/repositories/news_repository.dart`

**Role:** Encapsulates all network I/O with the NewsAPI. Acts as the single source of truth for remote article data.

**Provider:** `newsRepositoryProvider` — `Provider<NewsRepository>` that injects the `dioProvider`.

**`getTopHeadlines({category, page, query})`:**
- If `query` is provided → calls `GET /everything?q=<query>&page=<n>&pageSize=20&apiKey=...`
- Otherwise → calls `GET /top-headlines?category=<cat>&language=en&page=<n>&pageSize=20&apiKey=...`
- Filters out articles with title `[Removed]` (a NewsAPI artifact).
- Maps the JSON array to `List<Article>` via `Article.fromJson`.
- Throws `Exception` on non-200 or `DioException`.

**API Key:** Hardcoded as `_apiKey` in the class (constant string).

**Key connections:**
- → `core/network/dio_client.dart` (consumes `dioProvider`)
- → `domain/models/article.dart` (produces `List<Article>`)
- ← consumed by `news_provider.dart`

---

#### `lib/features/news/presentation/providers/news_provider.dart`

**Role:** Provides reactive state for both the paginated category feed and the search results.

**`NewsFeed` notifier** (`@riverpod`, family parameter: `category`):
- `build({category})` — fetches page 1 for the given category on first watch.
- `refresh()` — resets state to loading and re-fetches page 1.
- `loadMore()` — computes the next page number from `articles.length / 20 + 1`, fetches it, and appends to the existing list.
- State type: `AsyncValue<List<Article>>`

**`SearchNews` notifier** (`@riverpod`, required parameter: `query`):
- `build(query)` — returns `[]` if query is empty; otherwise fires a search request.
- State type: `AsyncValue<List<Article>>`

**Code generation:** `@riverpod` → generates `news_provider.g.dart`.

**Key connections:**
- → `news_repository.dart` (via `ref.read(newsRepositoryProvider)`)
- ← watched by `news_feed_screen.dart` and `search_screen.dart`

---

#### `lib/features/news/presentation/screens/news_feed_screen.dart`

**Role:** The main home screen — a tabbed news reader.

**Two widgets in this file:**

1. **`NewsFeedScreen`** (`ConsumerStatefulWidget`):
   - Owns a `TabController` with 6 tabs: Business, Technology, Science, Health, Entertainment, Sports.
   - AppBar actions: search icon (→ `SearchScreen`) and logout icon (calls `authProvider.notifier.logout()`).
   - `TabBarView` renders one `_CategoryFeedList` per category.

2. **`_CategoryFeedList`** (private `ConsumerStatefulWidget`):
   - Owns a `ScrollController` — listens for scroll position within 200 px of the bottom and calls `loadMore()`.
   - Watches `newsFeedProvider(category: ...)` and renders:
     - **Loading:** `CircularProgressIndicator`
     - **Error:** Wi-Fi off icon + error message + Retry button (calls `ref.invalidate`)
     - **Data:** `RefreshIndicator` wrapping a `ListView.builder` of `ArticleCard`s. Tapping navigates to `ArticleDetailScreen`.
     - An extra loading indicator cell appended at the bottom while `_isLoadingMore`.

**Key connections:**
- → `news_provider.dart` (`newsFeedProvider`)
- → `article_card.dart`
- → `search_screen.dart`
- → `article_detail_screen.dart`
- → `auth_provider.dart` (logout)

---

#### `lib/features/news/presentation/screens/article_detail_screen.dart`

**Role:** Full article view screen with bookmark toggle and external link launcher.

**Layout:**
- `CustomScrollView` with a `SliverAppBar` (expandedHeight 280 px).
- Hero image via `CachedNetworkImage` (grey placeholder if no image).
- Bookmark `IconButton` in the AppBar action area — uses `AnimatedSwitcher` for a smooth icon swap.
- Source badge, formatted date, title (large), author avatar + byline, divider, description, content body, and a full-width "Read Full Article" button.

**Key behaviours:**
- Reads `favoritesProvider` to determine `isFav` state for the bookmark icon colour.
- Calls `favoritesProvider.notifier.add/remove(article)` and shows a `SnackBar`.
- `_cleanContent()` strips the `[+XXXX chars]` suffix that NewsAPI appends.
- `_launchUrl()` opens the article URL with `LaunchMode.externalApplication`.

**Key connections:**
- → `favorites_provider.dart` (bookmark toggle)
- → `url_launcher` (open in browser)
- → `cached_network_image` (hero image)
- → `intl` (date formatting)
- ← navigated to from `news_feed_screen.dart`, `search_screen.dart`, `favorites_screen.dart`

---

#### `lib/features/news/presentation/screens/search_screen.dart`

**Role:** Full-text search screen pushed modally from the news feed AppBar.

**UI:**
- AppBar contains an auto-focused `TextField` (borderless, with clear button when `_query` is non-empty).
- Body shows an idle placeholder (magnifier icon) until the user submits a query.
- On submit → `setState(() => _query = value.trim())` → Riverpod rebuilds via `searchNewsProvider(_query)`.
- Results rendered with the same `ArticleCard` and navigation to `ArticleDetailScreen`.

**Key connections:**
- → `news_provider.dart` (`searchNewsProvider`)
- → `article_card.dart`
- → `article_detail_screen.dart`

---

#### `lib/features/news/presentation/widgets/article_card.dart`

**Role:** Reusable card widget shared across `NewsFeedScreen`, `SearchScreen`, and `FavoritesScreen`.

**Layout (top → bottom):**
1. `CachedNetworkImage` — 200 px tall hero, full width (shown only if `urlToImage != null`).
2. Padding block:
   - Row: Red source badge (`Flexible` to prevent overflow) + formatted date.
   - Title (max 2 lines, ellipsis).
   - Description (max 3 lines, ellipsis, shown if non-null).

**Props:**
- `article` — the `Article` to display.
- `onTap` — `VoidCallback` — caller decides navigation.

**Key connections:**
- → `article.dart` (reads all fields)
- → `cached_network_image` (thumbnail)
- → `intl` (date formatting)

---

### 5.5 Feature: Favorites

#### `lib/features/favorites/presentation/providers/favorites_provider.dart`

**Role:** Manages the user's saved article list with real-time Hive persistence.

**Why not `@riverpod`?** The file comment explains: Riverpod's code generator has issues with `List<Article>` as a parameterized state type, so `FavoritesNotifier` is written manually as a `Notifier<List<Article>>`.

**`FavoritesNotifier` methods:**
- `build()` — reads `articles` from the `favorites` Hive box, deserializes each map to `Article.fromJson`.
- `add(article)` — deduplicates by URL before adding; appends and persists.
- `remove(article)` — filters out by URL; persists.
- `isFavorite(url)` — synchronous boolean lookup.
- `_persist()` — writes `state.map((a) => a.toJson()).toList()` to Hive.

**Provider:** `favoritesProvider` — `NotifierProvider<FavoritesNotifier, List<Article>>`.

**Key connections:**
- → `hive_ce_flutter` (reads/writes `favorites` box)
- → `domain/models/article.dart` (`Article.fromJson`, `Article.toJson`)
- ← watched and mutated in `article_detail_screen.dart`
- ← watched in `favorites_screen.dart`

---

#### `lib/features/favorites/presentation/screens/favorites_screen.dart`

**Role:** Displays the user's bookmarked articles.

**States:**
- **Empty:** Scaffold with a bookmark icon and "No saved articles" message.
- **With articles:** `ListView.builder` wrapping each article in a `Dismissible` widget.
  - Swipe left → red delete background → calls `favoritesProvider.notifier.remove(article)` → `SnackBar` confirmation.
  - Tap → navigates to `ArticleDetailScreen`.
  - Article count shown in AppBar title: `Saved (N)`.

**Key connections:**
- → `favorites_provider.dart` (`favoritesProvider`)
- → `article_card.dart`
- → `article_detail_screen.dart`

---

## 6. Data & State Flow

```
NewsAPI (newsapi.org)
        │  HTTP GET (Dio)
        ▼
  NewsRepository
  ┌─────────────────────────────────┐
  │  getTopHeadlines(category/query)│ → List<Article>
  └─────────────────────────────────┘
        │  ref.read(newsRepositoryProvider)
        ▼
  NewsFeed / SearchNews (Riverpod Notifiers)
  ┌──────────────────────────────────────────────┐
  │  AsyncValue<List<Article>>                   │
  │  • build() → initial fetch                   │
  │  • refresh() → pull-to-refresh               │
  │  • loadMore() → infinite scroll              │
  └──────────────────────────────────────────────┘
        │  ref.watch(newsFeedProvider / searchNewsProvider)
        ▼
  NewsFeedScreen / SearchScreen
  └─► ArticleCard (tap)
            │  Navigator.push
            ▼
        ArticleDetailScreen
            │  ref.read(favoritesProvider.notifier).add/remove
            ▼
  FavoritesNotifier → Hive.box('favorites')
            │  ref.watch(favoritesProvider)
            ▼
        FavoritesScreen
```

---

## 7. Navigation Flow

```
App Start
    │
    ├── authProvider == false ──► LoginScreen
    │                                │ login()
    │                                ▼
    └── authProvider == true  ──► HomeShell (BottomNavigationBar)
                                      │
                              ┌───────┴────────┐
                              ▼                ▼
                        NewsFeedScreen    FavoritesScreen
                              │                │
                    ┌─────────┤                │
                    ▼         ▼                ▼
               SearchScreen  ArticleDetailScreen ◄──────┘
                    │              │
                    └──────────────┘
                              │
                        url_launcher → System Browser
```

Navigation is **imperative** (`Navigator.push` / `pop`), not declarative (no Router / GoRouter). Modal screens (Search, ArticleDetail) are pushed on top of the existing stack.

---

## 8. Local Persistence (Hive)

Three Hive boxes are opened at startup in `main.dart`:

| Box Name | Key(s) | Type | Used By |
|---|---|---|---|
| `auth` | `isLoggedIn` | `bool` | `auth_provider.dart` |
| `favorites` | `articles` | `List<dynamic>` (JSON maps) | `favorites_provider.dart` |
| `settings` | *(reserved)* | — | future use |

Hive CE does **not** require type adapters here — the `articles` list is stored as raw JSON-serializable maps using `Article.toJson()` / `Article.fromJson()`.

---

## 9. API Integration (NewsAPI)

- **Base URL:** `https://newsapi.org/v2/`
- **API Key:** Stored as a constant `_apiKey` in `news_repository.dart`
- **Endpoints used:**

| Endpoint | Used when | Key Parameters |
|---|---|---|
| `GET /top-headlines` | Browsing a category | `category`, `language=en`, `page`, `pageSize=20` |
| `GET /everything` | Searching | `q=<query>`, `page`, `pageSize=20` |

- **Page size:** 20 articles per page.
- **Pagination logic:** `page = (articles.length / 20).ceil() + 1` in `NewsFeed.loadMore()`.
- **Filtering:** Articles with `title == '[Removed]'` are dropped before mapping.

> ⚠️ The free NewsAPI plan only returns filtered results on `top-headlines`. Consider upgrading for production use.

---

## 10. Code Generation

Two Riverpod providers use `riverpod_generator` (`@riverpod` annotation):

| Source File | Generated File | Provider(s) |
|---|---|---|
| `auth_provider.dart` | `auth_provider.g.dart` | `authProvider` |
| `news_provider.dart` | `news_provider.g.dart` | `newsFeedProvider`, `searchNewsProvider` |

`favorites_provider.dart` is **manual** (no `@riverpod`) to avoid generator limitations with parameterized list types.

### Regenerating Code

```bash
dart run build_runner build --delete-conflicting-outputs
```

For continuous generation during development:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

> Generated `*.g.dart` files **must be committed** to version control and must not be edited manually.

---

## 11. Running the Project

### Prerequisites

- Flutter SDK ≥ 3.11.0
- Dart SDK ≥ 3.11.0
- A valid [NewsAPI](https://newsapi.org) API key (free tier available)

### Steps

```bash
# 1. Clone the repository
git clone <repo-url>
cd news_app

# 2. Install dependencies
flutter pub get

# 3. Regenerate code (if .g.dart files are missing)
dart run build_runner build --delete-conflicting-outputs

# 4. Run on a connected device or emulator
flutter run

# 5. Build release APK (Android)
flutter build apk --release

# 6. Build release IPA (iOS — requires macOS + Xcode)
flutter build ios --release
```

### Supported Platforms

The project scaffolds exist for: Android, iOS, Web, Windows, macOS, Linux.

---

*This document is maintained by the development team. Update it whenever new files, libraries, or architectural patterns are introduced.*
