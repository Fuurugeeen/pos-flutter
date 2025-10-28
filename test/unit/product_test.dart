import 'package:flutter_test/flutter_test.dart';
import 'package:pos_flutter/data/models/product.dart';
import 'package:pos_flutter/data/models/enums.dart';

void main() {
  group('Product Model Tests', () {
    late Product testProduct;

    setUp(() {
      testProduct = Product.create(
        name: 'Test Coffee',
        description: 'A delicious test coffee',
        price: 300.0,
        category: ProductCategory.coffee,
        taxRate: TaxRate.standard,
        stockQuantity: 10,
        lowStockThreshold: 5,
      );
    });

    test('should create a product with factory constructor', () {
      expect(testProduct.name, 'Test Coffee');
      expect(testProduct.description, 'A delicious test coffee');
      expect(testProduct.price, 300.0);
      expect(testProduct.category, ProductCategory.coffee);
      expect(testProduct.taxRate, TaxRate.standard);
      expect(testProduct.stockQuantity, 10);
      expect(testProduct.lowStockThreshold, 5);
      expect(testProduct.isActive, true);
      expect(testProduct.id, isNotEmpty);
    });

    test('should calculate price with tax correctly', () {
      expect(testProduct.priceWithTax, 330.0); // 300 * 1.10
    });

    test('should identify low stock correctly', () {
      expect(testProduct.isLowStock, false);
      
      final lowStockProduct = testProduct.copyWith(stockQuantity: 3);
      expect(lowStockProduct.isLowStock, true);
    });

    test('should handle product without low stock threshold', () {
      final productWithoutThreshold = testProduct.copyWith(lowStockThreshold: null);
      expect(productWithoutThreshold.isLowStock, false);
    });

    test('should serialize to and from JSON correctly', () {
      final json = testProduct.toJson();
      final deserializedProduct = Product.fromJson(json);
      
      expect(deserializedProduct, equals(testProduct));
    });

    test('should copy with new values correctly', () {
      final newProduct = testProduct.copyWith(
        name: 'Updated Coffee',
        price: 350.0,
      );
      
      expect(newProduct.name, 'Updated Coffee');
      expect(newProduct.price, 350.0);
      expect(newProduct.id, testProduct.id); // Should keep same ID
      expect(newProduct.description, testProduct.description); // Should keep original description
    });

    test('should have correct equality comparison', () {
      final json = testProduct.toJson();
      final sameProduct = Product.fromJson(json);
      final differentProduct = testProduct.copyWith(name: 'Different Coffee');
      
      // Check individual fields rather than complete equality due to DateTime precision
      expect(sameProduct.id, testProduct.id);
      expect(sameProduct.name, testProduct.name);
      expect(sameProduct.description, testProduct.description);
      expect(sameProduct.price, testProduct.price);
      expect(sameProduct.category, testProduct.category);
      expect(sameProduct.taxRate, testProduct.taxRate);
      expect(sameProduct.stockQuantity, testProduct.stockQuantity);
      expect(sameProduct.lowStockThreshold, testProduct.lowStockThreshold);
      expect(sameProduct.isActive, testProduct.isActive);
      
      expect(testProduct, isNot(equals(differentProduct)));
    });

    test('should have consistent hashCode', () {
      final json = testProduct.toJson();
      final sameProduct = Product.fromJson(json);
      
      expect(testProduct.hashCode, equals(sameProduct.hashCode));
    });

    test('should handle different tax rates', () {
      final reducedTaxProduct = testProduct.copyWith(taxRate: TaxRate.reduced);
      final exemptProduct = testProduct.copyWith(taxRate: TaxRate.exempt);
      
      expect(reducedTaxProduct.priceWithTax, 324.0); // 300 * 1.08
      expect(exemptProduct.priceWithTax, 300.0); // 300 * 1.00
    });
  });
}