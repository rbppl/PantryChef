import 'package:pantry_chef/domain/entities/recipe.dart';
import 'package:pantry_chef/domain/repositories/i_recipes_repository.dart';
import 'package:pantry_chef/data/api/mealdb_service.dart';
import 'package:pantry_chef/data/local/hive_database.dart';

class RecipesRepository implements IRecipesRepository {
  final MealDbService mealDbService;
  final HiveDatabase hiveDatabase;

  RecipesRepository({
    required this.mealDbService,
    required this.hiveDatabase,
  });

  @override
  Future<List<Recipe>> getRecipesByIngredients(
      List<String> selectedIngredients, bool onlyBasicInfo) async {
    final Map<String, Recipe> recipeMap = {};
    final cachedRecipes = await _loadCachedRecipes();
    final newIds = <String>{};

    for (var ingredient in selectedIngredients) {
      final data = await mealDbService.filterByIngredient(ingredient);
      if (data['meals'] != null) {
        for (var meal in data['meals']) {
          final id = meal['idMeal'];
          if (cachedRecipes.containsKey(id)) {
            recipeMap[id] = cachedRecipes[id]!;
          } else if (!recipeMap.containsKey(id)) {
            recipeMap[id] = Recipe(
              id: id,
              name: meal['strMeal'],
              thumbnail: meal['strMealThumb'],
              ingredients: [],
              matchCount: 0,
              matchedIngredients: [],
              instructions: null,
              category: null,
              youtubeLink: null,
              measures: null,
            );
            if (!onlyBasicInfo) newIds.add(id);
          }
          if (!recipeMap[id]!.matchedIngredients.contains(ingredient)) {
            recipeMap[id]!.matchedIngredients.add(ingredient);
          }
          recipeMap[id]!.matchCount = selectedIngredients
              .where((ing) => recipeMap[id]!.matchedIngredients.contains(ing))
              .length;
        }
      }
    }

    if (!onlyBasicInfo && newIds.isNotEmpty) {
      final fullDataList =
          await mealDbService.lookupRecipesByIds(newIds.toList());
      for (var fullData in fullDataList) {
        final fullMeal = fullData['meals']?.first;
        if (fullMeal != null) {
          final id = fullMeal['idMeal'];
          recipeMap[id] = Recipe(
            id: id,
            name: fullMeal['strMeal'],
            thumbnail: fullMeal['strMealThumb'],
            ingredients: _extractIngredientsFromMeal(fullMeal),
            matchCount: recipeMap[id]!.matchCount,
            matchedIngredients: recipeMap[id]!.matchedIngredients,
            instructions: fullMeal['strInstructions'],
            category: fullMeal['strCategory'],
            youtubeLink: fullMeal['strYoutube'],
            measures: _extractMeasuresFromMeal(fullMeal),
          );
          await hiveDatabase.cacheRecipe(recipeMap[id]!);
        }
      }
    }

    final recipes = recipeMap.values.toList();
    recipes.sort((a, b) => b.matchCount.compareTo(a.matchCount));
    return recipes;
  }

  Future<Map<String, Recipe>> _loadCachedRecipes() async {
    final cached = hiveDatabase.getCachedRecipes();
    return {for (var recipe in cached) recipe.id: recipe};
  }

  List<String> _extractIngredientsFromMeal(Map<String, dynamic> meal) {
    final List<String> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = meal['strIngredient$i'];
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add(ingredient.toString().trim());
      }
    }
    return ingredients;
  }

  List<String> _extractMeasuresFromMeal(Map<String, dynamic> meal) {
    final List<String> measures = [];
    for (int i = 1; i <= 20; i++) {
      final measure = meal['strMeasure$i'];
      if (measure != null && measure.toString().trim().isNotEmpty) {
        measures.add(measure.toString().trim());
      }
    }
    return measures;
  }
}
