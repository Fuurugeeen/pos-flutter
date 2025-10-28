import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_flutter/core/providers/providers.dart';
import 'package:pos_flutter/data/models/product.dart';
import 'package:pos_flutter/data/models/customer.dart';
import 'package:pos_flutter/data/models/enums.dart';

void main() {
  group('Provider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Product Providers', () {
      test('should provide all products', () async {
        final products = await container.read(allProductsProvider.future);
        
        expect(products, isNotEmpty);
        expect(products.length, greaterThan(10));
      });

      test('should provide active products', () async {
        final products = await container.read(activeProductsProvider.future);
        
        expect(products, isNotEmpty);
        expect(products.every((p) => p.isActive), true);
      });

      test('should provide products by category', () async {
        final coffeeProducts = await container.read(productsByCategoryProvider(ProductCategory.coffee).future);
        
        expect(coffeeProducts, isNotEmpty);
        expect(coffeeProducts.every((p) => p.category == ProductCategory.coffee), true);
      });

      test('should provide empty search results for empty query', () async {
        final searchResults = await container.read(productSearchProvider('').future);
        
        expect(searchResults, isEmpty);
      });

      test('should provide search results for valid query', () async {
        final searchResults = await container.read(productSearchProvider('コーヒー').future);
        
        expect(searchResults, isNotEmpty);
      });

      test('should provide low stock products', () async {
        final lowStockProducts = await container.read(lowStockProductsProvider.future);
        
        expect(lowStockProducts.every((p) => p.isLowStock), true);
      });

      test('should provide product count by category', () async {
        final countMap = await container.read(productCountByCategoryProvider.future);
        
        expect(countMap, isNotEmpty);
        expect(countMap.containsKey(ProductCategory.coffee), true);
      });

      test('should update selected category', () {
        expect(container.read(selectedProductCategoryProvider), null);
        
        container.read(selectedProductCategoryProvider.notifier).state = ProductCategory.coffee;
        
        expect(container.read(selectedProductCategoryProvider), ProductCategory.coffee);
      });

      test('should update search query', () {
        expect(container.read(productSearchQueryProvider), '');
        
        container.read(productSearchQueryProvider.notifier).state = 'test query';
        
        expect(container.read(productSearchQueryProvider), 'test query');
      });
    });

    group('Cart Providers', () {
      test('should initialize empty cart', () {
        final cart = container.read(cartProvider);
        
        expect(cart.items, isEmpty);
        expect(cart.status, SaleStatus.pending);
        expect(cart.paymentMethod, PaymentMethod.cash);
      });

      test('should add item to cart', () {
        final cartNotifier = container.read(cartProvider.notifier);
        final product = Product.create(
          name: 'Test Product',
          description: 'Test',
          price: 100.0,
          category: ProductCategory.coffee,
        );

        cartNotifier.addItem(product, quantity: 2);
        final cart = container.read(cartProvider);

        expect(cart.items.length, 1);
        expect(cart.items.first.quantity, 2);
        expect(cart.items.first.productName, 'Test Product');
      });

      test('should combine same product items', () {
        final cartNotifier = container.read(cartProvider.notifier);
        final product = Product.create(
          name: 'Test Product',
          description: 'Test',
          price: 100.0,
          category: ProductCategory.coffee,
        );

        cartNotifier.addItem(product, quantity: 1);
        cartNotifier.addItem(product, quantity: 2);
        final cart = container.read(cartProvider);

        expect(cart.items.length, 1);
        expect(cart.items.first.quantity, 3);
      });

      test('should remove item from cart', () {
        final cartNotifier = container.read(cartProvider.notifier);
        final product = Product.create(
          name: 'Test Product',
          description: 'Test',
          price: 100.0,
          category: ProductCategory.coffee,
        );

        cartNotifier.addItem(product);
        expect(container.read(cartProvider).items.length, 1);

        cartNotifier.removeItem(product.id);
        expect(container.read(cartProvider).items.length, 0);
      });

      test('should update item quantity', () {
        final cartNotifier = container.read(cartProvider.notifier);
        final product = Product.create(
          name: 'Test Product',
          description: 'Test',
          price: 100.0,
          category: ProductCategory.coffee,
        );

        cartNotifier.addItem(product);
        cartNotifier.updateItemQuantity(product.id, 5);
        final cart = container.read(cartProvider);

        expect(cart.items.first.quantity, 5);
      });

      test('should remove item when quantity set to zero', () {
        final cartNotifier = container.read(cartProvider.notifier);
        final product = Product.create(
          name: 'Test Product',
          description: 'Test',
          price: 100.0,
          category: ProductCategory.coffee,
        );

        cartNotifier.addItem(product);
        cartNotifier.updateItemQuantity(product.id, 0);
        final cart = container.read(cartProvider);

        expect(cart.items, isEmpty);
      });

      test('should set payment method', () {
        final cartNotifier = container.read(cartProvider.notifier);
        
        cartNotifier.setPaymentMethod(PaymentMethod.creditCard);
        final cart = container.read(cartProvider);

        expect(cart.paymentMethod, PaymentMethod.creditCard);
      });

      test('should set customer', () {
        final cartNotifier = container.read(cartProvider.notifier);
        
        cartNotifier.setCustomer('customer-123', 'Test Customer');
        final cart = container.read(cartProvider);

        expect(cart.customerId, 'customer-123');
        expect(cart.customerName, 'Test Customer');
      });

      test('should apply discount', () {
        final cartNotifier = container.read(cartProvider.notifier);
        
        cartNotifier.applyDiscount(50.0);
        final cart = container.read(cartProvider);

        expect(cart.discountAmount, 50.0);
      });

      test('should use loyalty points', () {
        final cartNotifier = container.read(cartProvider.notifier);
        
        cartNotifier.useLoyaltyPoints(100);
        final cart = container.read(cartProvider);

        expect(cart.loyaltyPointsUsed, 100);
      });

      test('should clear cart', () {
        final cartNotifier = container.read(cartProvider.notifier);
        final product = Product.create(
          name: 'Test Product',
          description: 'Test',
          price: 100.0,
          category: ProductCategory.coffee,
        );

        cartNotifier.addItem(product);
        expect(container.read(cartProvider).items.length, 1);

        cartNotifier.clearCart();
        expect(container.read(cartProvider).items, isEmpty);
      });

      test('should complete sale and clear cart', () {
        final cartNotifier = container.read(cartProvider.notifier);
        final product = Product.create(
          name: 'Test Product',
          description: 'Test',
          price: 100.0,
          category: ProductCategory.coffee,
        );

        cartNotifier.addItem(product);
        final completedSale = cartNotifier.completeSale();

        expect(completedSale.status, SaleStatus.completed);
        expect(completedSale.items.length, 1);
        expect(container.read(cartProvider).items, isEmpty);
      });
    });

    group('Cart Derived Providers', () {
      test('should calculate cart item count', () {
        final cartNotifier = container.read(cartProvider.notifier);
        final product = Product.create(
          name: 'Test Product',
          description: 'Test',
          price: 100.0,
          category: ProductCategory.coffee,
        );

        expect(container.read(cartItemCountProvider), 0);

        cartNotifier.addItem(product, quantity: 3);
        expect(container.read(cartItemCountProvider), 3);
      });

      test('should calculate cart subtotal', () {
        final cartNotifier = container.read(cartProvider.notifier);
        final product = Product.create(
          name: 'Test Product',
          description: 'Test',
          price: 100.0,
          category: ProductCategory.coffee,
        );

        cartNotifier.addItem(product, quantity: 2);
        expect(container.read(cartSubtotalProvider), 200.0);
      });

      test('should detect empty cart', () {
        expect(container.read(cartIsEmptyProvider), true);

        final cartNotifier = container.read(cartProvider.notifier);
        final product = Product.create(
          name: 'Test Product',
          description: 'Test',
          price: 100.0,
          category: ProductCategory.coffee,
        );

        cartNotifier.addItem(product);
        expect(container.read(cartIsEmptyProvider), false);
      });
    });

    group('App Providers', () {
      test('should manage selected customer', () {
        expect(container.read(selectedCustomerProvider), null);

        final customer = Customer.create(name: 'Test Customer');
        container.read(selectedCustomerProvider.notifier).state = customer;

        expect(container.read(selectedCustomerProvider), customer);
      });

      test('should manage loading state', () {
        expect(container.read(isLoadingProvider), false);

        container.read(isLoadingProvider.notifier).state = true;

        expect(container.read(isLoadingProvider), true);
      });

      test('should manage error state', () {
        expect(container.read(errorProvider), null);

        container.read(errorProvider.notifier).state = 'Test error';

        expect(container.read(errorProvider), 'Test error');
      });

      test('should manage current page', () {
        expect(container.read(currentPageProvider), 0);

        container.read(currentPageProvider.notifier).state = 2;

        expect(container.read(currentPageProvider), 2);
      });
    });
  });
}