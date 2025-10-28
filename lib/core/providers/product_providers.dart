import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product.dart';
import '../../data/models/enums.dart';
import '../../core/utils/result.dart';
import 'repository_providers.dart';

// All products provider
final allProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.read(productRepositoryProvider);
  final result = await repository.getAllProducts();
  return result.when(
    success: (products) => products,
    failure: (error) => throw error,
  );
});

// Active products provider
final activeProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.read(productRepositoryProvider);
  final result = await repository.getActiveProducts();
  return result.when(
    success: (products) => products,
    failure: (error) => throw error,
  );
});

// Products by category provider
final productsByCategoryProvider = FutureProvider.family<List<Product>, ProductCategory>((ref, category) async {
  final repository = ref.read(productRepositoryProvider);
  final result = await repository.getProductsByCategory(category);
  return result.when(
    success: (products) => products,
    failure: (error) => throw error,
  );
});

// Product search provider
final productSearchProvider = FutureProvider.family<List<Product>, String>((ref, query) async {
  if (query.isEmpty) {
    return [];
  }
  final repository = ref.read(productRepositoryProvider);
  final result = await repository.searchProducts(query);
  return result.when(
    success: (products) => products,
    failure: (error) => throw error,
  );
});

// Low stock products provider
final lowStockProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.read(productRepositoryProvider);
  final result = await repository.getLowStockProducts();
  return result.when(
    success: (products) => products,
    failure: (error) => throw error,
  );
});

// Product count by category provider
final productCountByCategoryProvider = FutureProvider<Map<ProductCategory, int>>((ref) async {
  final repository = ref.read(productRepositoryProvider);
  final result = await repository.getProductCountByCategory();
  return result.when(
    success: (counts) => counts,
    failure: (error) => throw error,
  );
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

  Result<List<Product>> result;
  if (searchQuery.isNotEmpty) {
    result = await repository.searchProducts(searchQuery);
  } else if (category != null) {
    result = await repository.getProductsByCategory(category);
  } else {
    result = await repository.getActiveProducts();
  }
  
  return result.when(
    success: (products) => products,
    failure: (error) => throw error,
  );
});