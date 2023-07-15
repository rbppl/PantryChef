import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantry_chef/di/service_locator.dart';
import 'package:pantry_chef/data/local/hive_database.dart';

final ingredientsProvider =
    StateNotifierProvider<IngredientsNotifier, List<String>>((ref) {
  return IngredientsNotifier();
});

class IngredientsNotifier extends StateNotifier<List<String>> {
  IngredientsNotifier() : super([]) {
    _loadSelectedIngredients();
  }

  final hiveDatabase = getIt<HiveDatabase>();

  void toggleIngredient(String ingredient) {
    if (state.contains(ingredient)) {
      state = state.where((i) => i != ingredient).toList();
    } else {
      state = [...state, ingredient];
    }
    _saveSelectedIngredients();
  }

  void clearSelectedIngredients() {
    state = [];
    _saveSelectedIngredients();
  }

  Future<void> _saveSelectedIngredients() async {
    await hiveDatabase.saveSelectedIngredients(state);
  }

  Future<void> _loadSelectedIngredients() async {
    final savedIngredients = hiveDatabase.loadSelectedIngredients();
    state = savedIngredients;
  }
}
