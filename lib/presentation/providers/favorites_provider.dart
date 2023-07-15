import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantry_chef/domain/entities/recipe.dart';
import 'package:pantry_chef/presentation/providers/hive_database_provider.dart';

class FavoritesNotifier extends StateNotifier<List<Recipe>> {
  FavoritesNotifier(this.ref)
      : super(ref.read(hiveDatabaseProvider).getFavorites());

  final Ref ref;

  Future<void> addFavorite(Recipe recipe) async {
    await ref.read(hiveDatabaseProvider).addFavorite(recipe);
    state = ref.read(hiveDatabaseProvider).getFavorites();
  }

  Future<void> removeFavorite(String recipeId) async {
    await ref.read(hiveDatabaseProvider).removeFavorite(recipeId);
    state = ref.read(hiveDatabaseProvider).getFavorites();
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<Recipe>>((ref) {
  return FavoritesNotifier(ref);
});
