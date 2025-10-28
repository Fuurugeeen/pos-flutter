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
      final products = await repository.getAllProducts();
      
      expect(products, isNotEmpty);
      expect(products.length, greaterThan(10));
    });

    test('should get products by category', () async {
      final coffeeProducts = await repository.getProductsByCategory(ProductCategory.coffee);
      
      expect(coffeeProducts, isNotEmpty);
      expect(coffeeProducts.every((p) => p.category == ProductCategory.coffee), true);
    });

    test('should get product by ID', () async {
      final allProducts = await repository.getAllProducts();
      final firstProduct = allProducts.first;
      
      final foundProduct = await repository.getProductById(firstProduct.id);
      
      expect(foundProduct, isNotNull);
      expect(foundProduct!.id, firstProduct.id);
    });

    test('should return null for non-existent product ID', () async {
      final foundProduct = await repository.getProductById('non-existent-id');
      
      expect(foundProduct, isNull);
    });

    test('should search products by name', () async {
      final searchResults = await repository.searchProducts('コーヒー');
      
      expect(searchResults, isNotEmpty);
      expect(searchResults.every((p) => 
        p.name.contains('コーヒー') || p.description.contains('コーヒー')
      ), true);
    });

    test('should search products case insensitive', () async {
      final searchResults = await repository.searchProducts('ブレンド');
      
      expect(searchResults, isNotEmpty);
      expect(searchResults.any((p) => 
        p.name.toLowerCase().contains('ブレンド'.toLowerCase())
      ), true);
    });

    test('should get active products only', () async {
      final activeProducts = await repository.getActiveProducts();
      
      expect(activeProducts, isNotEmpty);
      expect(activeProducts.every((p) => p.isActive), true);
    });

    test('should get low stock products', () async {
      final lowStockProducts = await repository.getLowStockProducts();
      
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
      
      final createdProduct = await repository.createProduct(newProduct);
      
      expect(createdProduct.name, 'Test Product');
      expect(createdProduct.id, newProduct.id);
      
      // Verify it's in the repository
      final foundProduct = await repository.getProductById(newProduct.id);
      expect(foundProduct, isNotNull);
    });

    test('should update existing product', () async {
      final allProducts = await repository.getAllProducts();
      final productToUpdate = allProducts.first;
      
      final updatedProduct = productToUpdate.copyWith(
        name: 'Updated Name',
        price: 999.0,
      );
      
      final result = await repository.updateProduct(updatedProduct);
      
      expect(result.name, 'Updated Name');
      expect(result.price, 999.0);
      expect(result.updatedAt.isAfter(productToUpdate.updatedAt), true);
    });

    test('should throw when updating non-existent product', () async {
      final nonExistentProduct = Product.create(
        name: 'Non-existent',
        description: 'Test',
        price: 100.0,
        category: ProductCategory.other,
      );
      
      expect(
        () => repository.updateProduct(nonExistentProduct),
        throwsException,
      );
    });

    test('should soft delete product', () async {
      final allProducts = await repository.getAllProducts();
      final productToDelete = allProducts.first;
      
      await repository.deleteProduct(productToDelete.id);
      
      final foundProduct = await repository.getProductById(productToDelete.id);
      expect(foundProduct!.isActive, false);
    });

    test('should update stock quantity', () async {
      final allProducts = await repository.getAllProducts();
      final product = allProducts.first;
      
      final updatedProduct = await repository.updateStock(product.id, 100);
      
      expect(updatedProduct.stockQuantity, 100);
      expect(updatedProduct.updatedAt.isAfter(product.updatedAt), true);
    });

    test('should reduce stock quantity', () async {
      final allProducts = await repository.getAllProducts();
      final product = allProducts.first;
      final originalQuantity = product.stockQuantity;
      
      final updatedProduct = await repository.reduceStock(product.id, 5);
      
      expect(updatedProduct.stockQuantity, originalQuantity - 5);
    });

    test('should not allow negative stock', () async {
      final allProducts = await repository.getAllProducts();
      final product = allProducts.first;
      
      final updatedProduct = await repository.reduceStock(product.id, 1000);
      
      expect(updatedProduct.stockQuantity, 0);
    });

    test('should get product count by category', () async {
      final countMap = await repository.getProductCountByCategory();
      
      expect(countMap, isNotEmpty);
      expect(countMap.containsKey(ProductCategory.coffee), true);
      expect(countMap[ProductCategory.coffee], greaterThan(0));
    });

    test('should throw when updating stock of non-existent product', () async {
      expect(
        () => repository.updateStock('non-existent-id', 100),
        throwsException,
      );
    });

    test('should throw when reducing stock of non-existent product', () async {
      expect(
        () => repository.reduceStock('non-existent-id', 5),
        throwsException,
      );
    });
  });
}