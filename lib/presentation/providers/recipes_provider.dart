import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantry_chef/di/service_locator.dart';
import 'package:pantry_chef/domain/usecases/get_recipes_by_ingredients.dart';
import 'package:pantry_chef/presentation/providers/ingredients_provider.dart';

final recipesProvider = FutureProvider((ref) async {
  final ingredients = ref.watch(ingredientsProvider);
  final getRecipes = getIt<GetRecipesByIngredients>();
  return await getRecipes(
    ingredients,
    onlyBasicInfo: true,
  );
});
