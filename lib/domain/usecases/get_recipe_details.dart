import 'package:pantry_chef/domain/entities/recipe.dart';
import 'package:pantry_chef/domain/repositories/i_recipe_details_repository.dart';

class GetRecipeDetails {
  final IRecipeDetailsRepository repository;

  GetRecipeDetails(this.repository);
  Future<Recipe> call(String recipeId) async {
    if (recipeId.isEmpty) {
      throw ArgumentError('Recipe ID cannot be empty');
    }
    return await repository.getRecipeDetails(recipeId);
  }
}
