import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pantry_chef/domain/entities/recipe.dart';

part 'hive_database.g.dart';

@HiveType(typeId: 0)
class RecipeHive extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String? thumbnail;
  @HiveField(3)
  int matchCount;
  @HiveField(4)
  List<String> ingredients;
  @HiveField(5)
  String? instructions;
  @HiveField(6)
  String? category;
  @HiveField(7)
  String? youtubeLink;
  @HiveField(8)
  List<String>? measures;
  @HiveField(9)
  DateTime? lastAccessed;

  RecipeHive({
    required this.id,
    required this.name,
    this.thumbnail,
    this.matchCount = 0,
    this.ingredients = const [],
    this.instructions,
    this.category,
    this.youtubeLink,
    this.measures,
    this.lastAccessed,
  });

  factory RecipeHive.fromRecipe(Recipe recipe) => RecipeHive(
        id: recipe.id,
        name: recipe.name,
        thumbnail: recipe.thumbnail,
        matchCount: recipe.matchCount,
        ingredients: recipe.ingredients,
        instructions: recipe.instructions,
        category: recipe.category,
        youtubeLink: recipe.youtubeLink,
        measures: recipe.measures,
        lastAccessed: DateTime.now(),
      );

  Recipe toRecipe() => Recipe(
        id: id,
        name: name,
        thumbnail: thumbnail,
        matchCount: matchCount,
        ingredients: ingredients,
        instructions: instructions,
        category: category,
        youtubeLink: youtubeLink,
        measures: measures,
      );
}

class HiveDatabase {
  static const String recipeBoxName = 'recipesBox';
  static const String favoritesBoxName = 'favoritesBox';
  static const String ingredientsBoxName = 'ingredientsBox';
  static const String selectedIngredientsKey = 'selectedIngredients';
  static const String cuisinesBoxName = 'cuisinesBox';
  static const String categoriesBoxName = 'categoriesBox';
  static const int maxCacheSize = 100;
  static const int cacheExpirationDays = 7;

  final Map<String, RecipeHive> _inMemoryCache = {};

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(RecipeHiveAdapter());
    await Hive.openBox<RecipeHive>(recipeBoxName);
    await Hive.openBox(favoritesBoxName);
    await Hive.openBox<List<String>>(ingredientsBoxName);
    await Hive.openBox<List<String>>(cuisinesBoxName);
    await Hive.openBox<List<String>>(categoriesBoxName);
    _scheduleCacheCleanup();
  }

  Box<RecipeHive> get recipeBox => Hive.box<RecipeHive>(recipeBoxName);
  Box get favoritesBox => Hive.box(favoritesBoxName);
  Box<List<String>> get ingredientsBox =>
      Hive.box<List<String>>(ingredientsBoxName);
  Box<List<String>> get cuisinesBox => Hive.box<List<String>>(cuisinesBoxName);
  Box<List<String>> get categoriesBox =>
      Hive.box<List<String>>(categoriesBoxName);

  Future<void> cacheRecipe(Recipe recipe) async {
    final recipeHive = RecipeHive.fromRecipe(recipe);
    _inMemoryCache[recipe.id] = recipeHive;
    if (recipeBox.length >= maxCacheSize) {
      _evictLeastRecentlyUsed();
    }
    await recipeBox.put(recipe.id, recipeHive);
  }

  void _evictLeastRecentlyUsed() {
    final recipes = recipeBox.values.toList();
    if (recipes.isEmpty) return;
    recipes.sort((a, b) => (a.lastAccessed ?? DateTime(2000))
        .compareTo(b.lastAccessed ?? DateTime(2000)));
    final oldest = recipes.first;
    if (!favoritesBox.containsKey(oldest.id)) {
      recipeBox.delete(oldest.id);
      _inMemoryCache.remove(oldest.id);
    }
  }

  Future<void> _clearOldCache() async {
    final now = DateTime.now();
    final recipesToDelete = recipeBox.values.where((recipe) =>
        recipe.lastAccessed != null &&
        now.difference(recipe.lastAccessed!).inDays > cacheExpirationDays &&
        !favoritesBox.containsKey(recipe.id));
    for (var recipe in recipesToDelete) {
      await recipeBox.delete(recipe.id);
      _inMemoryCache.remove(recipe.id);
    }
  }

  void _scheduleCacheCleanup() {
    Timer.periodic(const Duration(hours: 1), (timer) async {
      await _clearOldCache();
    });
  }

  Future<Recipe?> getCachedRecipe(String id) async {
    if (_inMemoryCache.containsKey(id)) {
      final recipeHive = _inMemoryCache[id]!;
      recipeHive.lastAccessed = DateTime.now();
      return recipeHive.toRecipe();
    }
    final recipeHive = recipeBox.get(id);
    if (recipeHive != null) {
      recipeHive.lastAccessed = DateTime.now();
      _inMemoryCache[id] = recipeHive;
      await recipeHive.save();
      return recipeHive.toRecipe();
    }
    return null;
  }

  List<Recipe> getCachedRecipes() {
    return recipeBox.values.map((recipeHive) => recipeHive.toRecipe()).toList();
  }

  Future<void> removeCachedRecipe(String recipeId) async {
    await recipeBox.delete(recipeId);
    _inMemoryCache.remove(recipeId);
  }

  Future<void> addFavorite(Recipe recipe) async {
    await favoritesBox.put(recipe.id, null);
    await cacheRecipe(recipe);
  }

  List<Recipe> getFavorites() {
    final favoriteIds = favoritesBox.keys.toList();
    return recipeBox.values
        .where((recipeHive) => favoriteIds.contains(recipeHive.id))
        .map((recipeHive) => recipeHive.toRecipe())
        .toList();
  }

  Future<void> removeFavorite(String recipeId) async {
    await favoritesBox.delete(recipeId);
  }

  Future<List<String>> getCachedIngredients() async {
    return ingredientsBox.get('ingredients') ?? [];
  }

  Future<void> cacheIngredients(List<String> ingredients) async {
    await ingredientsBox.put('ingredients', ingredients);
  }

  Future<void> saveSelectedIngredients(List<String> ingredients) async {
    await ingredientsBox.put(selectedIngredientsKey, ingredients);
  }

  List<String> loadSelectedIngredients() {
    return ingredientsBox.get(selectedIngredientsKey) ?? [];
  }

  Future<void> cacheCategories(List<String> categories) async {
    await categoriesBox.put('categories', categories);
  }

  Future<List<String>> getCachedCategories() async {
    return categoriesBox.get('categories') ?? [];
  }
}
