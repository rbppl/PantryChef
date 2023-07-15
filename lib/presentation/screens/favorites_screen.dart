import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantry_chef/core/utils/constants.dart';
import 'package:pantry_chef/presentation/providers/favorites_provider.dart';
import 'package:pantry_chef/presentation/widgets/recipe_tile.dart';
import 'package:pantry_chef/presentation/providers/connectivity_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  Future<void> _refreshFavorites(WidgetRef ref) async {
    ref.refresh(favoritesProvider);
    ref.refresh(connectivityProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteRecipes = ref.watch(favoritesProvider);
    final connectivityAsync = ref.watch(connectivityProvider);

    return Scaffold(
      appBar: AppBar(title: const Center(child: Text(Constants.favorites))),
      body: connectivityAsync.when(
        data: (isConnected) => RefreshIndicator(
          onRefresh: () => _refreshFavorites(ref),
          child: favoriteRecipes.isEmpty
              ? const Center(child: Text(Constants.favoritesDescription))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                    return GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: favoriteRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = favoriteRecipes[index];
                        return RecipeTile(
                            recipe: recipe, isFavoriteScreen: true);
                      },
                    );
                  },
                ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${Constants.networkError} $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _refreshFavorites(ref),
                child: const Text(Constants.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
