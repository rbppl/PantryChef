import 'package:pantry_chef/data/api/api_client.dart';
import 'package:pantry_chef/data/local/hive_database.dart';

class MealDbService {
  final ApiClient apiClient;
  final HiveDatabase hiveDatabase;
  final Map<String, Map<String, dynamic>> _recipeCache = {};
  MealDbService(this.apiClient, this.hiveDatabase);

  Future<Map<String, dynamic>> fetchCategories() async {
    final response = await apiClient.get('/categories.php');
    return response.data;
  }

  Future<Map<String, dynamic>> filterByIngredient(String ingredient) async {
    final response =
        await apiClient.get('/filter.php', queryParameters: {'i': ingredient});
    return response.data;
  }

  Future<Map<String, dynamic>> lookupRecipeById(String id) async {
    if (_recipeCache.containsKey(id)) {
      return _recipeCache[id]!;
    }
    final response =
        await apiClient.get('/lookup.php', queryParameters: {'i': id});
    _recipeCache[id] = response.data;
    return response.data;
  }

  Future<List<Map<String, dynamic>>> lookupRecipesByIds(
      List<String> ids) async {
    final futures = ids.map<Future<Map<String, dynamic>>>((id) async {
      if (_recipeCache.containsKey(id)) {
        return _recipeCache[id]!;
      }
      final response =
          await apiClient.get('/lookup.php', queryParameters: {'i': id});
      _recipeCache[id] = response.data;
      return response.data;
    });
    return await Future.wait(futures);
  }

  Future<List<String>> getIngredients() async {
    final cached = await hiveDatabase.getCachedIngredients();
    if (cached.isNotEmpty) {
      return cached;
    }
    final response =
        await apiClient.get('/list.php', queryParameters: {'i': 'list'});
    final data = response.data;
    List<String> ingredients = [];
    if (data['meals'] != null) {
      ingredients = (data['meals'] as List)
          .map((ing) => ing['strIngredient'] as String)
          .toList();
      await hiveDatabase.cacheIngredients(ingredients);
    }
    return ingredients;
  }

  Future<String?> getRecipeInstructions(String id) async {
    final data = await lookupRecipeById(id);
    final meal = data['meals']?.first;
    return meal?['strInstructions'];
  }
}
