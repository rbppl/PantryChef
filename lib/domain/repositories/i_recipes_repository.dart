import 'package:pantry_chef/domain/entities/recipe.dart';

abstract class IRecipesRepository {
  Future<List<Recipe>> getRecipesByIngredients(
      List<String> selectedIngredients, bool onlyBasicInfo);
}
