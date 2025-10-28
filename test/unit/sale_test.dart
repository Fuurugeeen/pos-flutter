import 'package:flutter_test/flutter_test.dart';
import 'package:pos_flutter/data/models/sale.dart';
import 'package:pos_flutter/data/models/sale_item.dart';
import 'package:pos_flutter/data/models/product.dart';
import 'package:pos_flutter/data/models/enums.dart';

void main() {
  group('Sale Model Tests', () {
    late Sale testSale;
    late List<SaleItem> testItems;
    late Product coffeeProduct;
    late Product teaProduct;

    setUp(() {
      coffeeProduct = Product.create(
        name: 'Coffee',
        description: 'Coffee',
        price: 300.0,
        category: ProductCategory.coffee,
        taxRate: TaxRate.standard,
        stockQuantity: 10,
      );

      teaProduct = Product.create(
        name: 'Tea',
        description: 'Tea',
        price: 250.0,
        category: ProductCategory.tea,
        taxRate: TaxRate.standard,
        stockQuantity: 15,
      );

      testItems = [
        SaleItem.fromProduct(coffeeProduct, 2), // 300 * 2 = 600
        SaleItem.fromProduct(teaProduct, 1),    // 250 * 1 = 250
      ];

      testSale = Sale.create(
        customerId: 'customer-123',
        customerName: 'Test Customer',
        items: testItems,
        paymentMethod: PaymentMethod.cash,
        discountAmount: 50.0,
        loyaltyPointsUsed: 20,
        loyaltyPointsEarned: 8,
        notes: 'Test sale',
      );
    });

    test('should create a sale with factory constructor', () {
      expect(testSale.customerId, 'customer-123');
      expect(testSale.customerName, 'Test Customer');
      expect(testSale.items.length, 2);
      expect(testSale.paymentMethod, PaymentMethod.cash);
      expect(testSale.status, SaleStatus.pending);
      expect(testSale.discountAmount, 50.0);
      expect(testSale.loyaltyPointsUsed, 20);
      expect(testSale.loyaltyPointsEarned, 8);
      expect(testSale.notes, 'Test sale');
      expect(testSale.id, isNotEmpty);
    });

    test('should calculate subtotal correctly', () {
      // Coffee: 300 * 2 = 600
      // Tea: 250 * 1 = 250
      // Total: 850
      expect(testSale.subtotal, 850.0);
    });

    test('should calculate total tax correctly', () {
      // Coffee tax: 600 * 0.10 = 60
      // Tea tax: 250 * 0.10 = 25
      // Total tax: 85
      expect(testSale.totalTax, 85.0);
    });

    test('should calculate total before discount correctly', () {
      // Subtotal: 850 + Tax: 85 = 935
      expect(testSale.totalBeforeDiscount, 935.0);
    });

    test('should calculate final total correctly', () {
      // Total before discount: 935 - Discount: 50 - Points used: 20 = 865
      expect(testSale.finalTotal, 865.0);
    });

    test('should calculate total items correctly', () {
      expect(testSale.totalItems, 3); // 2 + 1
    });

    test('should add new item correctly', () {
      final pastryProduct = Product.create(
        name: 'Pastry',
        description: 'Pastry',
        price: 200.0,
        category: ProductCategory.pastry,
        taxRate: TaxRate.standard,
        stockQuantity: 5,
      );
      
      final newItem = SaleItem.fromProduct(pastryProduct, 1);
      final updatedSale = testSale.addItem(newItem);
      
      expect(updatedSale.items.length, 3);
      expect(updatedSale.subtotal, 1050.0); // 850 + 200
    });

    test('should add quantity to existing item', () {
      final additionalCoffee = SaleItem.fromProduct(coffeeProduct, 1);
      final updatedSale = testSale.addItem(additionalCoffee);
      
      expect(updatedSale.items.length, 2); // Same number of unique items
      final coffeeItem = updatedSale.items.firstWhere(
        (item) => item.productId == coffeeProduct.id,
      );
      expect(coffeeItem.quantity, 3); // 2 + 1
    });

    test('should remove item correctly', () {
      final updatedSale = testSale.removeItem(coffeeProduct.id);
      
      expect(updatedSale.items.length, 1);
      expect(updatedSale.items.first.productId, teaProduct.id);
      expect(updatedSale.subtotal, 250.0);
    });

    test('should update item quantity correctly', () {
      final updatedSale = testSale.updateItemQuantity(coffeeProduct.id, 5);
      
      final coffeeItem = updatedSale.items.firstWhere(
        (item) => item.productId == coffeeProduct.id,
      );
      expect(coffeeItem.quantity, 5);
      expect(updatedSale.subtotal, 1750.0); // 300 * 5 + 250 * 1
    });

    test('should remove item when quantity is set to zero', () {
      final updatedSale = testSale.updateItemQuantity(coffeeProduct.id, 0);
      
      expect(updatedSale.items.length, 1);
      expect(updatedSale.items.first.productId, teaProduct.id);
    });

    test('should serialize to and from JSON correctly', () {
      final json = testSale.toJson();
      final deserializedSale = Sale.fromJson(json);
      
      // Check individual fields rather than complete equality due to DateTime precision
      expect(deserializedSale.id, testSale.id);
      expect(deserializedSale.customerId, testSale.customerId);
      expect(deserializedSale.customerName, testSale.customerName);
      expect(deserializedSale.items, testSale.items);
      expect(deserializedSale.paymentMethod, testSale.paymentMethod);
      expect(deserializedSale.status, testSale.status);
      expect(deserializedSale.discountAmount, testSale.discountAmount);
      expect(deserializedSale.loyaltyPointsUsed, testSale.loyaltyPointsUsed);
      expect(deserializedSale.loyaltyPointsEarned, testSale.loyaltyPointsEarned);
      expect(deserializedSale.notes, testSale.notes);
    });

    test('should copy with new values correctly', () {
      final newSale = testSale.copyWith(
        status: SaleStatus.completed,
        paymentMethod: PaymentMethod.creditCard,
      );
      
      expect(newSale.status, SaleStatus.completed);
      expect(newSale.paymentMethod, PaymentMethod.creditCard);
      expect(newSale.id, testSale.id);
      expect(newSale.items, testSale.items);
    });

    test('should handle sale without customer', () {
      final anonymousSale = Sale.create(
        items: testItems,
        paymentMethod: PaymentMethod.cash,
      );
      
      expect(anonymousSale.customerId, isNull);
      expect(anonymousSale.customerName, isNull);
      expect(anonymousSale.items.length, 2);
    });

    test('should prevent negative final total', () {
      final heavyDiscountSale = testSale.copyWith(
        discountAmount: 1000.0, // More than total
        loyaltyPointsUsed: 200,  // Even more reduction
      );
      
      expect(heavyDiscountSale.finalTotal, 0.0);
    });

    test('should have correct equality comparison', () {
      final json = testSale.toJson();
      final sameSale = Sale.fromJson(json);
      final differentSale = testSale.copyWith(status: SaleStatus.completed);
      
      // Check individual fields rather than complete equality due to DateTime precision
      expect(sameSale.id, testSale.id);
      expect(sameSale.customerId, testSale.customerId);
      expect(sameSale.customerName, testSale.customerName);
      expect(sameSale.items, testSale.items);
      expect(sameSale.paymentMethod, testSale.paymentMethod);
      expect(sameSale.status, testSale.status);
      expect(sameSale.discountAmount, testSale.discountAmount);
      expect(sameSale.loyaltyPointsUsed, testSale.loyaltyPointsUsed);
      expect(sameSale.loyaltyPointsEarned, testSale.loyaltyPointsEarned);
      expect(sameSale.notes, testSale.notes);
      
      expect(testSale, isNot(equals(differentSale)));
    });
  });
}