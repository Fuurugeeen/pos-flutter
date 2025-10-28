import 'package:flutter_test/flutter_test.dart';
import 'package:pos_flutter/data/repositories/mock_product_repository.dart';
import 'package:pos_flutter/data/repositories/product_repository.dart';
import 'package:pos_flutter/data/models/product.dart';
import 'package:pos_flutter/data/models/enums.dart';

void main() {
  group('Product Repository Tests', () {
    late ProductRepository repository;

    setUp(() {
      repository = MockProductRepository();
    });

    test('should get all products', () async {
      final result = await repository.getAllProducts();
      
      expect(result.isSuccess, true);
      final products = result.data!;
      expect(products, isNotEmpty);
      expect(products.length, greaterThan(10));
    });

    test('should get products by category', () async {
      final result = await repository.getProductsByCategory(ProductCategory.coffee);
      
      expect(result.isSuccess, true);
      final coffeeProducts = result.data!;
      expect(coffeeProducts, isNotEmpty);
      expect(coffeeProducts.every((p) => p.category == ProductCategory.coffee), true);
    });

    test('should get product by ID', () async {
      final allProductsResult = await repository.getAllProducts();
      expect(allProductsResult.isSuccess, true);
      final allProducts = allProductsResult.data!;
      final firstProduct = allProducts.first;
      
      final foundProductResult = await repository.getProductById(firstProduct.id);
      
      expect(foundProductResult.isSuccess, true);
      final foundProduct = foundProductResult.data;
      expect(foundProduct, isNotNull);
      expect(foundProduct!.id, firstProduct.id);
    });

    test('should return null for non-existent product ID', () async {
      final result = await repository.getProductById('non-existent-id');
      
      expect(result.isSuccess, true);
      final foundProduct = result.data;
      expect(foundProduct, isNull);
    });

    test('should search products by name', () async {
      final result = await repository.searchProducts('コーヒー');
      
      expect(result.isSuccess, true);
      final searchResults = result.data!;
      expect(searchResults, isNotEmpty);
      expect(searchResults.every((p) => 
        p.name.contains('コーヒー') || p.description.contains('コーヒー')
      ), true);
    });

    test('should search products case insensitive', () async {
      final result = await repository.searchProducts('ブレンド');
      
      expect(result.isSuccess, true);
      final searchResults = result.data!;
      expect(searchResults, isNotEmpty);
      expect(searchResults.any((p) => 
        p.name.toLowerCase().contains('ブレンド'.toLowerCase())
      ), true);
    });

    test('should get active products only', () async {
      final result = await repository.getActiveProducts();
      
      expect(result.isSuccess, true);
      final activeProducts = result.data!;
      expect(activeProducts, isNotEmpty);
      expect(activeProducts.every((p) => p.isActive), true);
    });

    test('should get low stock products', () async {
      final result = await repository.getLowStockProducts();
      
      expect(result.isSuccess, true);
      final lowStockProducts = result.data!;
      expect(lowStockProducts.every((p) => p.isLowStock), true);
    });

    test('should create new product', () async {
      final newProduct = Product.create(
        name: 'Test Product',
        description: 'Test Description',
        price: 500.0,
        category: ProductCategory.other,
        stockQuantity: 10,
      );
      
      final result = await repository.createProduct(newProduct);
      
      expect(result.isSuccess, true);
      final createdProduct = result.data!;
      expect(createdProduct.name, 'Test Product');
      expect(createdProduct.id, newProduct.id);
      
      // Verify it's in the repository
      final foundResult = await repository.getProductById(newProduct.id);
      expect(foundResult.isSuccess, true);
      final foundProduct = foundResult.data;
      expect(foundProduct, isNotNull);
    });

    test('should update existing product', () async {
      final allProductsResult = await repository.getAllProducts();
      expect(allProductsResult.isSuccess, true);
      final allProducts = allProductsResult.data!;
      final productToUpdate = allProducts.first;
      
      final updatedProduct = productToUpdate.copyWith(
        name: 'Updated Name',
        price: 999.0,
      );
      
      final result = await repository.updateProduct(updatedProduct);
      
      expect(result.isSuccess, true);
      final updatedResult = result.data!;
      expect(updatedResult.name, 'Updated Name');
      expect(updatedResult.price, 999.0);
      expect(updatedResult.updatedAt.isAfter(productToUpdate.updatedAt), true);
    });

    test('should return failure when updating non-existent product', () async {
      final nonExistentProduct = Product.create(
        name: 'Non-existent',
        description: 'Test',
        price: 100.0,
        category: ProductCategory.other,
      );
      
      final result = await repository.updateProduct(nonExistentProduct);
      expect(result.isFailure, true);
    });

    test('should soft delete product', () async {
      final allProductsResult = await repository.getAllProducts();
      expect(allProductsResult.isSuccess, true);
      final allProducts = allProductsResult.data!;
      final productToDelete = allProducts.first;
      
      final deleteResult = await repository.deleteProduct(productToDelete.id);
      expect(deleteResult.isSuccess, true);
      
      final foundResult = await repository.getProductById(productToDelete.id);
      expect(foundResult.isSuccess, true);
      final foundProduct = foundResult.data;
      expect(foundProduct!.isActive, false);
    });

    test('should update stock quantity', () async {
      final allProductsResult = await repository.getAllProducts();
      expect(allProductsResult.isSuccess, true);
      final allProducts = allProductsResult.data!;
      final product = allProducts.first;
      
      final result = await repository.updateStock(product.id, 100);
      
      expect(result.isSuccess, true);
      final updatedProduct = result.data!;
      expect(updatedProduct.stockQuantity, 100);
      expect(updatedProduct.updatedAt.isAfter(product.updatedAt), true);
    });

    test('should reduce stock quantity', () async {
      final allProductsResult = await repository.getAllProducts();
      expect(allProductsResult.isSuccess, true);
      final allProducts = allProductsResult.data!;
      final product = allProducts.first;
      final originalQuantity = product.stockQuantity;
      
      final result = await repository.reduceStock(product.id, 5);
      
      expect(result.isSuccess, true);
      final updatedProduct = result.data!;
      expect(updatedProduct.stockQuantity, originalQuantity - 5);
    });

    test('should not allow negative stock', () async {
      final allProductsResult = await repository.getAllProducts();
      expect(allProductsResult.isSuccess, true);
      final allProducts = allProductsResult.data!;
      final product = allProducts.first;
      
      final result = await repository.reduceStock(product.id, 1000);
      
      // Should fail when trying to reduce more stock than available
      expect(result.isFailure, true);
    });

    test('should get product count by category', () async {
      final result = await repository.getProductCountByCategory();
      
      expect(result.isSuccess, true);
      final countMap = result.data!;
      expect(countMap, isNotEmpty);
      expect(countMap.containsKey(ProductCategory.coffee), true);
      expect(countMap[ProductCategory.coffee], greaterThan(0));
    });

    test('should return failure when updating stock of non-existent product', () async {
      final result = await repository.updateStock('non-existent-id', 100);
      expect(result.isFailure, true);
    });

    test('should return failure when reducing stock of non-existent product', () async {
      final result = await repository.reduceStock('non-existent-id', 5);
      expect(result.isFailure, true);
    });
  });
}