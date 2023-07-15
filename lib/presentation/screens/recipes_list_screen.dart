import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantry_chef/core/utils/constants.dart';
import 'package:pantry_chef/presentation/providers/recipes_provider.dart';
import 'package:pantry_chef/presentation/widgets/recipe_tile.dart';
import 'package:pantry_chef/presentation/providers/connectivity_provider.dart';
import 'package:pantry_chef/presentation/providers/ingredients_provider.dart';

class RecipesListScreen extends ConsumerStatefulWidget {
  const RecipesListScreen({super.key});

  @override
  _RecipesListScreenState createState() => _RecipesListScreenState();
}

class _RecipesListScreenState extends ConsumerState<RecipesListScreen> {
  Future<void> _refreshRecipes() async {
    ref.refresh(recipesProvider);
    ref.refresh(connectivityProvider);
  }

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(recipesProvider);
    final connectivityAsync = ref.watch(connectivityProvider);
    final ingredients = ref.watch(ingredientsProvider);

    return Scaffold(
      appBar: AppBar(title: const Center(child: Text(Constants.recipes))),
      body: connectivityAsync.when(
        data: (isConnected) => isConnected
            ? RefreshIndicator(
                onRefresh: _refreshRecipes,
                child: ingredients.isEmpty
                    ? const Center(
                        child: Text(Constants.selectAtLeastOneIngredient))
                    : recipesAsync.when(
                        data: (recipes) => LayoutBuilder(
                          builder: (context, constraints) {
                            int crossAxisCount =
                                constraints.maxWidth > 600 ? 3 : 2;
                            return GridView.builder(
                              padding: const EdgeInsets.all(8.0),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 8.0,
                                mainAxisSpacing: 8.0,
                                childAspectRatio: 0.8,
                              ),
                              itemCount: recipes.length,
                              itemBuilder: (context, index) {
                                final recipe = recipes[index];
                                return RecipeTile(recipe: recipe);
                              },
                            );
                          },
                        ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${Constants.error} $error'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _refreshRecipes,
                              child: const Text(Constants.retry),
                            ),
                          ],
                        ),
                      ),
              )
            : _buildNoInternetWidget(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${Constants.networkError} $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshRecipes,
                child: const Text(Constants.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoInternetWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(Constants.noInternetConnection),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshRecipes,
            child: const Text(Constants.retry),
          ),
        ],
      ),
    );
  }
}
