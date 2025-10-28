import 'package:flutter_test/flutter_test.dart';
import 'package:pos_flutter/data/models/sale_item.dart';
import 'package:pos_flutter/data/models/product.dart';
import 'package:pos_flutter/data/models/enums.dart';

void main() {
  group('SaleItem Model Tests', () {
    late SaleItem testSaleItem;
    late Product testProduct;

    setUp(() {
      testProduct = Product.create(
        name: 'Test Coffee',
        description: 'A delicious test coffee',
        price: 300.0,
        category: ProductCategory.coffee,
        taxRate: TaxRate.standard,
        stockQuantity: 10,
      );

      testSaleItem = SaleItem.fromProduct(testProduct, 2, notes: 'Extra hot');
    });

    test('should create sale item from product', () {
      expect(testSaleItem.productId, testProduct.id);
      expect(testSaleItem.productName, testProduct.name);
      expect(testSaleItem.unitPrice, testProduct.price);
      expect(testSaleItem.quantity, 2);
      expect(testSaleItem.taxRate, testProduct.taxRate.rate);
      expect(testSaleItem.notes, 'Extra hot');
    });

    test('should calculate subtotal correctly', () {
      expect(testSaleItem.subtotal, 600.0); // 300 * 2
    });

    test('should calculate tax amount correctly', () {
      expect(testSaleItem.taxAmount, 60.0); // 600 * 0.10
    });

    test('should calculate total correctly', () {
      expect(testSaleItem.total, 660.0); // 600 + 60
    });

    test('should handle different tax rates', () {
      final reducedTaxProduct = testProduct.copyWith(taxRate: TaxRate.reduced);
      final reducedTaxItem = SaleItem.fromProduct(reducedTaxProduct, 1);
      
      expect(reducedTaxItem.taxAmount, 24.0); // 300 * 0.08
      expect(reducedTaxItem.total, 324.0); // 300 + 24
    });

    test('should handle tax exempt products', () {
      final exemptProduct = testProduct.copyWith(taxRate: TaxRate.exempt);
      final exemptItem = SaleItem.fromProduct(exemptProduct, 1);
      
      expect(exemptItem.taxAmount, 0.0);
      expect(exemptItem.total, 300.0);
    });

    test('should serialize to and from JSON correctly', () {
      final json = testSaleItem.toJson();
      final deserializedItem = SaleItem.fromJson(json);
      
      expect(deserializedItem, equals(testSaleItem));
    });

    test('should copy with new values correctly', () {
      final newItem = testSaleItem.copyWith(
        quantity: 3,
        notes: 'Updated notes',
      );
      
      expect(newItem.quantity, 3);
      expect(newItem.notes, 'Updated notes');
      expect(newItem.productId, testSaleItem.productId);
      expect(newItem.unitPrice, testSaleItem.unitPrice);
    });

    test('should have correct equality comparison', () {
      final json = testSaleItem.toJson();
      final sameItem = SaleItem.fromJson(json);
      final differentItem = testSaleItem.copyWith(quantity: 3);
      
      expect(testSaleItem, equals(sameItem));
      expect(testSaleItem, isNot(equals(differentItem)));
    });

    test('should create sale item without notes', () {
      final itemWithoutNotes = SaleItem.fromProduct(testProduct, 1);
      
      expect(itemWithoutNotes.notes, isNull);
      expect(itemWithoutNotes.quantity, 1);
    });

    test('should handle zero quantity correctly', () {
      final zeroQuantityItem = testSaleItem.copyWith(quantity: 0);
      
      expect(zeroQuantityItem.subtotal, 0.0);
      expect(zeroQuantityItem.taxAmount, 0.0);
      expect(zeroQuantityItem.total, 0.0);
    });
  });
}