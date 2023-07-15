import 'package:pantry_chef/domain/repositories/i_recipe_details_repository.dart';
import 'package:pantry_chef/domain/entities/recipe.dart';
import 'package:pantry_chef/data/api/mealdb_service.dart';
import 'package:pantry_chef/data/local/hive_database.dart';

class RecipeDetailsRepository implements IRecipeDetailsRepository {
  final MealDbService mealDbService;
  final HiveDatabase hiveDatabase;

  RecipeDetailsRepository(
      {required this.mealDbService, required this.hiveDatabase});

  @override
  Future<Recipe> getRecipeDetails(String id) async {
    final cachedRecipe = await hiveDatabase.getCachedRecipe(id);
    if (cachedRecipe != null && cachedRecipe.instructions != null) {
      return cachedRecipe;
    }

    final detailData = await mealDbService.lookupRecipeById(id);
    if (detailData['meals'] == null || detailData['meals'].isEmpty) {
      throw Exception('Recipe not found');
    }

    final meal = detailData['meals'][0];
    final recipe = Recipe(
      id: meal['idMeal'],
      name: meal['strMeal'],
      thumbnail: meal['strMealThumb'],
      ingredients: _extractIngredients(meal),
      matchCount: 0,
      matchedIngredients: [],
      instructions: meal['strInstructions'],
      category: meal['strCategory'],
      youtubeLink: meal['strYoutube'],
      measures: _extractMeasures(meal),
    );
    await hiveDatabase.cacheRecipe(recipe);
    return recipe;
  }

  List<String> _extractIngredients(Map<String, dynamic> meal) {
    final List<String> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = meal['strIngredient$i'];
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add(ingredient.toString().trim());
      }
    }
    return ingredients;
  }

  List<String> _extractMeasures(Map<String, dynamic> meal) {
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
