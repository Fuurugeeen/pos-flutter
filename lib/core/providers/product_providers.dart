import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product.dart';
import '../../data/models/enums.dart';
import 'repository_providers.dart';

// All products provider
final allProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.read(productRepositoryProvider);
  return repository.getAllProducts();
});

// Active products provider
final activeProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.read(productRepositoryProvider);
  return repository.getActiveProducts();
});

// Products by category provider
final productsByCategoryProvider = FutureProvider.family<List<Product>, ProductCategory>((ref, category) async {
  final repository = ref.read(productRepositoryProvider);
  return repository.getProductsByCategory(category);
});

// Product search provider
final productSearchProvider = FutureProvider.family<List<Product>, String>((ref, query) async {
  if (query.isEmpty) {
    return [];
  }
  final repository = ref.read(productRepositoryProvider);
  return repository.searchProducts(query);
});

// Low stock products provider
final lowStockProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.read(productRepositoryProvider);
  return repository.getLowStockProducts();
});

// Product count by category provider
final productCountByCategoryProvider = FutureProvider<Map<ProductCategory, int>>((ref) async {
  final repository = ref.read(productRepositoryProvider);
  return repository.getProductCountByCategory();
});

// Selected product category provider
final selectedProductCategoryProvider = StateProvider<ProductCategory?>((ref) => null);

// Product search query provider
final productSearchQueryProvider = StateProvider<String>((ref) => '');

// Filtered products provider (combines category and search)
final filteredProductsProvider = FutureProvider<List<Product>>((ref) async {
  final category = ref.watch(selectedProductCategoryProvider);
  final searchQuery = ref.watch(productSearchQueryProvider);
  final repository = ref.read(productRepositoryProvider);

  if (searchQuery.isNotEmpty) {
    return repository.searchProducts(searchQuery);
  }

  if (category != null) {
    return repository.getProductsByCategory(category);
  }

  return repository.getActiveProducts();
});