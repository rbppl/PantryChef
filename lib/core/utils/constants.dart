class Constants {
  static const String appName = "PantryChef";
  static const String mealDbBaseUrl = "https://www.themealdb.com/api/json/v1/1";

  static const String favorites = 'Favorites';
  static const String favoritesDescription =
      'Favorite recipes will be displayed here';
  static const String networkError = 'Network error:';
  static const String retry = 'Retry';
  static const String selectIngredients = 'Select ingredients';
  static const String allIngredients = 'All ingredients';
  static const String selected = 'Selected';
  static const String searchIngredient = 'Search ingredient...';
  static const String noIngredients = 'No ingredients';
  static const String loadingError = 'Loading error:';
  static const String noInternetConnection = 'No internet connection';
  static const String nothingFound = 'Nothing found';
  static const String recipeDetails = 'Recipe details';
  static const String ingredientsWithMeasures = 'Ingredients with measures:';
  static const String instruction = 'Instruction:';
  static const String noInstruction = 'No instruction';
  static const String category = 'Category';
  static const String noCategory = 'No category';
  static const String videoRecipe = 'Video recipe:';
  static const String error = 'Error:';
  static const String recipes = 'Recipes';
  static const String selectAtLeastOneIngredient =
      'Select at least 1 ingredient';
  static const String matches = 'Matches:';
  static const String matched = 'Matched:';
  static const String ingredients = 'Ingredients';
  static const String recipeFromPantryChef = 'Recipe from PantryChef';
  static const String noTitle = 'No title';
  static const String recipeLoading = 'Recipe is still loading';

  static const String shareRecipe = 'Share recipe';

  static const String couldNotLaunch = 'Could not launch';
  static const String noRecipeData = 'No recipe data';
  static const String invalidUrl = 'Invalid URL';

  static const String maxIngredientsSelected =
      'You can select up to %s ingredients only.';

  static String format(String template, [List<String>? args]) {
    String result = template;
    if (args != null) {
      for (int i = 0; i < args.length; i++) {
        result = result.replaceFirst('%s', args[i]);
      }
    }
    return result;
  }
}
