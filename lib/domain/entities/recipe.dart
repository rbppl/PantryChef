class Recipe {
  final String id;
  final String name;
  final String? thumbnail;
  List<String> ingredients;
  int matchCount;
  List<String> matchedIngredients;
  String? instructions;
  String? category;
  String? youtubeLink;
  List<String>? measures;

  Recipe({
    required this.id,
    required this.name,
    this.thumbnail,
    this.matchCount = 0,
    required this.ingredients,
    List<String>? matchedIngredients,
    this.instructions,
    this.category,
    this.youtubeLink,
    this.measures,
  }) : matchedIngredients = matchedIngredients ?? [];
}
