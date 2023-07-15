import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantry_chef/core/utils/constants.dart';
import 'package:pantry_chef/presentation/providers/ingredients_list_provider.dart';
import 'package:pantry_chef/presentation/providers/ingredients_provider.dart';
import 'package:pantry_chef/presentation/providers/connectivity_provider.dart';

class IngredientsScreen extends ConsumerStatefulWidget {
  const IngredientsScreen({super.key});

  @override
  ConsumerState<IngredientsScreen> createState() => _IngredientsScreenState();
}

class _IngredientsScreenState extends ConsumerState<IngredientsScreen>
    with SingleTickerProviderStateMixin {
  static const int maxSelectedIngredients = 30;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  bool isSearching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _startSearch() {
    setState(() => isSearching = true);
  }

  void _stopSearch() {
    setState(() {
      isSearching = false;
      searchQuery = '';
      _searchController.clear();
    });
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => searchQuery = value.toLowerCase());
    });
  }

  Future<void> _refreshIngredients() async {
    ref.refresh(ingredientsListProvider);
    ref.refresh(connectivityProvider);
  }

  void _clearSelectedIngredients() {
    ref.read(ingredientsProvider.notifier).clearSelectedIngredients();
  }

  void _toggleIngredient(String ingredient) {
    final notifier = ref.read(ingredientsProvider.notifier);
    final selectedIngredients = ref.read(ingredientsProvider);
    if (selectedIngredients.contains(ingredient)) {
      notifier.toggleIngredient(ingredient);
    } else if (selectedIngredients.length < maxSelectedIngredients) {
      notifier.toggleIngredient(ingredient);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Constants.format(Constants.maxIngredientsSelected,
                [maxSelectedIngredients.toString()]),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIngredients = ref.watch(ingredientsProvider);
    final ingredientsAsync = ref.watch(ingredientsListProvider);
    final connectivityAsync = ref.watch(connectivityProvider);

    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? _buildSearchField()
            : const Text(Constants.selectIngredients),
        actions: _buildAppBarActions(),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: Constants.allIngredients),
            Tab(
                text:
                    '${Constants.selected} (${selectedIngredients.length}/$maxSelectedIngredients)'),
          ],
          indicatorColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelColor: Colors.white,
        ),
      ),
      body: connectivityAsync.when(
        data: (isConnected) => isConnected
            ? RefreshIndicator(
                onRefresh: _refreshIngredients,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllIngredientsTab(
                        ingredientsAsync, selectedIngredients),
                    _buildSelectedIngredientsTab(selectedIngredients),
                  ],
                ),
              )
            : _buildNoInternetWidget(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: SelectableText('${Constants.networkError} $error')),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: Constants.searchIngredient,
        hintStyle: const TextStyle(color: Colors.white),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none),
        filled: true,
        fillColor: const Color.fromARGB(31, 0, 0, 0),
        prefixIcon: const Icon(Icons.search, color: Colors.white),
      ),
      style: const TextStyle(color: Colors.white),
      onChanged: _onSearchChanged,
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      if (isSearching)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: _stopSearch,
        )
      else
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _startSearch,
        ),
    ];
  }

  Widget _buildAllIngredientsTab(AsyncValue<List<String>> ingredientsAsync,
      List<String> selectedIngredients) {
    return ingredientsAsync.when(
      data: (allIngredients) {
        if (allIngredients.isEmpty) {
          return const Center(child: Text(Constants.noIngredients));
        }
        final filteredIngredients = allIngredients
            .where(
                (ingredient) => ingredient.toLowerCase().contains(searchQuery))
            .toList();
        return _buildIngredientsList(filteredIngredients, selectedIngredients);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorWidget(error),
    );
  }

  Widget _buildSelectedIngredientsTab(List<String> selectedIngredients) {
    final filteredIngredients = selectedIngredients
        .where((ingredient) => ingredient.toLowerCase().contains(searchQuery))
        .toList();
    return Stack(
      children: [
        _buildIngredientsList(filteredIngredients, selectedIngredients,
            isSelectedTab: true),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _clearSelectedIngredients,
            child: const Icon(Icons.delete),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(Object error) {
    return RefreshIndicator(
      onRefresh: _refreshIngredients,
      child: ListView(
        children: [
          Center(child: SelectableText('${Constants.loadingError} $error')),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: _refreshIngredients,
              child: const Text(Constants.retry),
            ),
          ),
        ],
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
            onPressed: _refreshIngredients,
            child: const Text(Constants.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsList(
      List<String> ingredients, List<String> selectedIngredients,
      {bool isSelectedTab = false}) {
    if (ingredients.isEmpty) {
      return const Center(child: Text(Constants.nothingFound));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 8.0,
        children: ingredients.map((ingredient) {
          final isSelected = selectedIngredients.contains(ingredient);
          return isSelectedTab
              ? Chip(
                  label: Text(ingredient),
                  onDeleted: () => _toggleIngredient(ingredient),
                )
              : GestureDetector(
                  onTap: () => _toggleIngredient(ingredient),
                  child: Chip(
                    label: Text(
                      ingredient,
                      style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black),
                    ),
                    backgroundColor:
                        isSelected ? Colors.blueAccent : Colors.grey[200],
                  ),
                );
        }).toList(),
      ),
    );
  }
}
