import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantry_chef/di/service_locator.dart';
import 'package:pantry_chef/data/api/mealdb_service.dart';
import 'package:pantry_chef/data/local/hive_database.dart';

final ingredientsListProvider = FutureProvider<List<String>>((ref) async {
  final mealDbService = getIt<MealDbService>();
  final hiveDatabase = getIt<HiveDatabase>();

  List<String> cachedIngredients = await hiveDatabase.getCachedIngredients();
  if (cachedIngredients.isNotEmpty) {
    return cachedIngredients;
  }

  try {
    final ingredients = await mealDbService.getIngredients();
    await hiveDatabase.cacheIngredients(ingredients);
    return ingredients;
  } catch (e) {
    throw Exception('Failed to load ingredients: $e');
  }
});
