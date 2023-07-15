import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantry_chef/core/utils/constants.dart';
import 'package:pantry_chef/presentation/providers/hive_database_provider.dart';
import 'package:pantry_chef/presentation/providers/recipe_detail_provider.dart';
import 'package:pantry_chef/presentation/providers/connectivity_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  Future<void> _refreshRecipeDetails(WidgetRef ref) async {
    final hiveDatabase = ref.read(hiveDatabaseProvider);
    await hiveDatabase.removeCachedRecipe(recipeId);
    ref.refresh(recipeDetailProvider(recipeId));
    ref.refresh(connectivityProvider);
  }

  Future<void> _shareRecipe(BuildContext context, WidgetRef ref) async {
    final recipeDetailAsync = ref.read(recipeDetailProvider(recipeId));
    recipeDetailAsync.when(
      data: (recipe) {
        final shareText = '''
${recipe.name ?? Constants.noTitle}

${Constants.ingredientsWithMeasures}:
${_buildShareIngredients(recipe)}

${Constants.instruction}
${recipe.instructions ?? Constants.noInstruction}

${Constants.category}: ${recipe.category ?? Constants.noCategory}

${recipe.youtubeLink != null ? "${Constants.videoRecipe}: ${recipe.youtubeLink}" : ""}
''';
        Share.share(shareText,
            subject: recipe.name ?? Constants.recipeFromPantryChef);
      },
      loading: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(Constants.recipeLoading)),
        );
      },
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(Constants.format(
                  Constants.loadingError, [error.toString()]))),
        );
      },
    );
  }

  String _buildShareIngredients(dynamic recipe) {
    if (recipe.ingredients == null || recipe.ingredients.isEmpty) {
      return Constants.noIngredients;
    }
    return recipe.ingredients.asMap().entries.map((entry) {
      final index = entry.key;
      final ingredient = entry.value;
      final measure = recipe.measures != null && recipe.measures!.length > index
          ? recipe.measures![index]
          : '';
      return '$ingredient: $measure';
    }).join('\n');
  }

  Future<void> _launchYouTubeLink(BuildContext context, String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Constants.invalidUrl)),
      );
      return;
    }

    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw '${Constants.couldNotLaunch} $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${Constants.error} $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeDetailAsync = ref.watch(recipeDetailProvider(recipeId));
    final connectivityAsync = ref.watch(connectivityProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(Constants.recipeDetails), actions: [
        IconButton(
          icon: const Icon(Icons.share),
          tooltip: Constants.shareRecipe,
          onPressed: () => _shareRecipe(context, ref),
        ),
      ]),
      body: connectivityAsync.when(
        data: (isConnected) => isConnected
            ? recipeDetailAsync.when(
                data: (recipe) {
                  return RefreshIndicator(
                    onRefresh: () => _refreshRecipeDetails(ref),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (recipe.thumbnail != null &&
                              recipe.thumbnail!.isNotEmpty)
                            Center(
                              child: CachedNetworkImage(
                                imageUrl: recipe.thumbnail!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          const SizedBox(height: 16.0),
                          SelectableText.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "${recipe.name ?? Constants.noTitle}\n",
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                const TextSpan(
                                  text:
                                      '${Constants.ingredientsWithMeasures}\n',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                if (recipe.ingredients.isNotEmpty)
                                  TextSpan(
                                    text: recipe.ingredients
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      final index = entry.key;
                                      final ingredient = entry.value;
                                      final measure = recipe.measures != null &&
                                              recipe.measures!.length > index
                                          ? recipe.measures![index]
                                          : '';
                                      return '$ingredient: $measure\n';
                                    }).join(''),
                                  )
                                else
                                  const TextSpan(
                                    text: '${Constants.noIngredients}\n',
                                  ),
                                TextSpan(
                                  text: '${Constants.instruction}\n',
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                TextSpan(
                                  text:
                                      "${recipe.instructions ?? Constants.noInstruction}\n",
                                ),
                                TextSpan(
                                  text:
                                      '${Constants.category}: ${recipe.category ?? Constants.noCategory}\n',
                                ),
                                if (recipe.youtubeLink != null &&
                                    recipe.youtubeLink!.isNotEmpty)
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: '${Constants.videoRecipe}\n',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: () => _launchYouTubeLink(
                                              context, recipe.youtubeLink!),
                                          child: Text(
                                            recipe.youtubeLink!,
                                            style: const TextStyle(
                                                color: Colors.blue),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorWidget(ref, error),
              )
            : _buildNoInternetWidget(ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildNetworkErrorWidget(ref, error),
      ),
    );
  }

  Widget _buildNoDataWidget(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(Constants.noRecipeData),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _refreshRecipeDetails(ref),
            child: const Text(Constants.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(WidgetRef ref, Object error) {
    return RefreshIndicator(
      onRefresh: () => _refreshRecipeDetails(ref),
      child: ListView(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SelectableText('${Constants.error} $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _refreshRecipeDetails(ref),
                  child: const Text(Constants.retry),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkErrorWidget(WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SelectableText('${Constants.networkError} $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _refreshRecipeDetails(ref),
            child: const Text(Constants.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildNoInternetWidget(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(Constants.noInternetConnection),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _refreshRecipeDetails(ref),
            child: const Text(Constants.retry),
          ),
        ],
      ),
    );
  }
}
