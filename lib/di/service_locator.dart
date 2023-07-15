import 'package:get_it/get_it.dart';
import 'package:pantry_chef/data/api/api_client.dart';
import 'package:pantry_chef/data/api/mealdb_service.dart';
import 'package:pantry_chef/data/api/connectivity_service.dart';
import 'package:pantry_chef/data/local/hive_database.dart';
import 'package:pantry_chef/data/repositories/recipes_repository.dart';
import 'package:pantry_chef/data/repositories/recipe_details_repository.dart';
import 'package:pantry_chef/domain/repositories/i_recipes_repository.dart';
import 'package:pantry_chef/domain/repositories/i_recipe_details_repository.dart';
import 'package:pantry_chef/domain/usecases/get_recipes_by_ingredients.dart';
import 'package:pantry_chef/domain/usecases/get_recipe_details.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  final hiveDatabase = HiveDatabase();
  await hiveDatabase.init();
  getIt.registerSingleton<HiveDatabase>(hiveDatabase);

  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<ConnectivityService>(
      () => ConnectivityService(Connectivity()));
  getIt.registerLazySingleton<MealDbService>(() => MealDbService(
        getIt<ApiClient>(),
        getIt<HiveDatabase>(),
      ));
  getIt.registerLazySingleton<IRecipesRepository>(() => RecipesRepository(
        mealDbService: getIt<MealDbService>(),
        hiveDatabase: getIt<HiveDatabase>(),
      ));
  getIt.registerLazySingleton<IRecipeDetailsRepository>(
      () => RecipeDetailsRepository(
            mealDbService: getIt<MealDbService>(),
            hiveDatabase: getIt<HiveDatabase>(),
          ));
  getIt.registerFactory(
      () => GetRecipesByIngredients(getIt<IRecipesRepository>()));
  getIt.registerFactory(
      () => GetRecipeDetails(getIt<IRecipeDetailsRepository>()));
}
