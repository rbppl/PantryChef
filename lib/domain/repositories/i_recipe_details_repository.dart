import 'package:pantry_chef/domain/entities/recipe.dart';

abstract class IRecipeDetailsRepository {
  Future<Recipe> getRecipeDetails(String id);
}
