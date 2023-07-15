import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantry_chef/core/utils/constants.dart';
import 'package:pantry_chef/domain/entities/recipe.dart';
import 'package:pantry_chef/presentation/providers/favorites_provider.dart';
import 'package:pantry_chef/presentation/screens/recipe_detail_screen.dart';

class RecipeTile extends ConsumerWidget {
  final Recipe recipe;
  final bool isFavoriteScreen;
  const RecipeTile({
    super.key,
    required this.recipe,
    this.isFavoriteScreen = false,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = isFavoriteScreen ||
        ref.watch(favoritesProvider).any((fav) => fav.id == recipe.id);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                RecipeDetailScreen(recipeId: recipe.id),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final scaleTween = Tween<double>(begin: 0.9, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );
              final fadeTween = Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeIn),
              );
              final slideTween = Tween<Offset>(
                begin: const Offset(0.0, 0.2),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );
              final reverseFadeTween =
                  Tween<double>(begin: 1.0, end: 0.0).animate(
                CurvedAnimation(
                    parent: secondaryAnimation, curve: Curves.easeOut),
              );
              final reverseSlideTween = Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(0.0, -0.2),
              ).animate(
                CurvedAnimation(
                    parent: secondaryAnimation, curve: Curves.easeInCubic),
              );

              return SlideTransition(
                position: secondaryAnimation.value > 0
                    ? reverseSlideTween
                    : slideTween,
                child: FadeTransition(
                  opacity: secondaryAnimation.value > 0
                      ? reverseFadeTween
                      : fadeTween,
                  child: ScaleTransition(
                    scale: scaleTween,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.teal.withOpacity(animation.value * 0.3),
                            blurRadius: 15 * animation.value,
                            spreadRadius: 2 * animation.value,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: child,
                    ),
                  ),
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 600),
            reverseTransitionDuration: const Duration(milliseconds: 400),
            opaque: false,
          ),
        );
      },
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12.0)),
                  child: recipe.thumbnail != null
                      ? CachedNetworkImage(
                          imageUrl: recipe.thumbnail!,
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Container(
                            height: 120,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image,
                                size: 50, color: Colors.grey),
                          ),
                        )
                      : Container(
                          height: 120,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image,
                              size: 50, color: Colors.grey),
                        ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16.0)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                      child: Container(
                        color: Colors.white.withOpacity(0.1),
                        child: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.white,
                          ),
                          onPressed: () async {
                            if (isFavorite) {
                              await ref
                                  .read(favoritesProvider.notifier)
                                  .removeFavorite(recipe.id);
                            } else if (!isFavoriteScreen) {
                              await ref
                                  .read(favoritesProvider.notifier)
                                  .addFavorite(recipe);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (!isFavoriteScreen) ...[
                      Text(
                        '${Constants.matches} ${recipe.matchCount}',
                        style: const TextStyle(color: Colors.green),
                      ),
                      if (recipe.matchedIngredients.isNotEmpty)
                        Text(
                          '${Constants.matched} ${recipe.matchedIngredients.join(', ')}',
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
