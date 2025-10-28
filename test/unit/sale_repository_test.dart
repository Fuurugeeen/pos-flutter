import 'package:flutter_test/flutter_test.dart';
import 'package:pos_flutter/data/repositories/mock_sale_repository.dart';
import 'package:pos_flutter/data/repositories/sale_repository.dart';
import 'package:pos_flutter/data/models/sale.dart';
import 'package:pos_flutter/data/models/sale_item.dart';
import 'package:pos_flutter/data/models/product.dart';
import 'package:pos_flutter/data/models/enums.dart';

void main() {
  group('Sale Repository Tests', () {
    late SaleRepository repository;

    setUp(() {
      repository = MockSaleRepository();
    });

    test('should get all sales', () async {
      final sales = await repository.getAllSales();
      
      expect(sales, isNotEmpty);
      expect(sales.length, 150);
    });

    test('should get sale by ID', () async {
      final allSales = await repository.getAllSales();
      final firstSale = allSales.first;
      
      final foundSale = await repository.getSaleById(firstSale.id);
      
      expect(foundSale, isNotNull);
      expect(foundSale!.id, firstSale.id);
    });

    test('should return null for non-existent sale ID', () async {
      final foundSale = await repository.getSaleById('non-existent-id');
      
      expect(foundSale, isNull);
    });

    test('should get sales by date range', () async {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 7));
      
      final salesInRange = await repository.getSalesByDateRange(startDate, endDate);
      
      expect(salesInRange, isNotEmpty);
      expect(salesInRange.every((s) => 
        s.createdAt.isAfter(startDate.subtract(const Duration(days: 1))) &&
        s.createdAt.isBefore(endDate.add(const Duration(days: 1)))
      ), true);
    });

    test('should get sales by customer', () async {
      final allSales = await repository.getAllSales();
      final saleWithCustomer = allSales.firstWhere((s) => s.customerId != null);
      
      final customerSales = await repository.getSalesByCustomer(saleWithCustomer.customerId!);
      
      expect(customerSales, isNotEmpty);
      expect(customerSales.every((s) => s.customerId == saleWithCustomer.customerId), true);
    });

    test('should get sales by status', () async {
      final completedSales = await repository.getSalesByStatus(SaleStatus.completed);
      
      expect(completedSales, isNotEmpty);
      expect(completedSales.every((s) => s.status == SaleStatus.completed), true);
    });

    test('should get sales by payment method', () async {
      final cashSales = await repository.getSalesByPaymentMethod(PaymentMethod.cash);
      
      expect(cashSales.every((s) => s.paymentMethod == PaymentMethod.cash), true);
    });

    test('should get today\'s sales', () async {
      final todaysSales = await repository.getTodaysSales();
      
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      expect(todaysSales.every((s) => 
        s.createdAt.isAfter(startOfDay) &&
        s.createdAt.isBefore(endOfDay)
      ), true);
    });

    test('should create new sale', () async {
      final product = Product.create(
        name: 'Test Product',
        description: 'Test',
        price: 100.0,
        category: ProductCategory.coffee,
      );
      
      final saleItem = SaleItem.fromProduct(product, 1);
      final newSale = Sale.create(
        items: [saleItem],
        paymentMethod: PaymentMethod.cash,
        status: SaleStatus.pending,
      );
      
      final createdSale = await repository.createSale(newSale);
      
      expect(createdSale.id, newSale.id);
      expect(createdSale.items.length, 1);
      
      // Verify it's in the repository
      final foundSale = await repository.getSaleById(newSale.id);
      expect(foundSale, isNotNull);
    });

    test('should update existing sale', () async {
      final allSales = await repository.getAllSales();
      final saleToUpdate = allSales.first;
      
      final updatedSale = saleToUpdate.copyWith(
        notes: 'Updated notes',
        discountAmount: 50.0,
      );
      
      final result = await repository.updateSale(updatedSale);
      
      expect(result.notes, 'Updated notes');
      expect(result.discountAmount, 50.0);
      expect(result.updatedAt.isAfter(saleToUpdate.updatedAt), true);
    });

    test('should throw when updating non-existent sale', () async {
      final product = Product.create(
        name: 'Test Product',
        description: 'Test',
        price: 100.0,
        category: ProductCategory.coffee,
      );
      
      final saleItem = SaleItem.fromProduct(product, 1);
      final nonExistentSale = Sale.create(
        items: [saleItem],
        paymentMethod: PaymentMethod.cash,
      );
      
      expect(
        () => repository.updateSale(nonExistentSale),
        throwsException,
      );
    });

    test('should complete sale', () async {
      final allSales = await repository.getAllSales();
      final pendingSale = allSales.firstWhere((s) => s.status == SaleStatus.completed);
      
      final completedSale = await repository.completeSale(pendingSale.id);
      
      expect(completedSale.status, SaleStatus.completed);
    });

    test('should cancel sale', () async {
      final allSales = await repository.getAllSales();
      final sale = allSales.first;
      
      final cancelledSale = await repository.cancelSale(sale.id);
      
      expect(cancelledSale.status, SaleStatus.cancelled);
    });

    test('should refund sale', () async {
      final allSales = await repository.getAllSales();
      final sale = allSales.first;
      
      final refundedSale = await repository.refundSale(sale.id);
      
      expect(refundedSale.status, SaleStatus.refunded);
    });

    test('should get daily sales total', () async {
      final today = DateTime.now();
      final total = await repository.getDailySalesTotal(today);
      
      expect(total, greaterThanOrEqualTo(0.0));
    });

    test('should get sales total by date range', () async {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 7));
      
      final total = await repository.getSalesTotalByDateRange(startDate, endDate);
      
      expect(total, greaterThan(0.0));
    });

    test('should get sales count by date range', () async {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));
      
      final count = await repository.getSalesCountByDateRange(startDate, endDate);
      
      expect(count, greaterThan(0));
    });

    test('should get top selling products', () async {
      final topProducts = await repository.getTopSellingProducts(5, null, null);
      
      expect(topProducts, isNotEmpty);
      expect(topProducts.length, lessThanOrEqualTo(5));
      
      // Check that results are sorted by quantity (descending)
      final quantities = topProducts.values.toList();
      for (int i = 0; i < quantities.length - 1; i++) {
        expect(quantities[i], greaterThanOrEqualTo(quantities[i + 1]));
      }
    });

    test('should get top selling products with date range', () async {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 7));
      
      final topProducts = await repository.getTopSellingProducts(3, startDate, endDate);
      
      expect(topProducts.length, lessThanOrEqualTo(3));
    });

    test('should get sales by payment method summary', () async {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));
      
      final summary = await repository.getSalesByPaymentMethodSummary(startDate, endDate);
      
      expect(summary, isNotEmpty);
      expect(summary.containsKey(PaymentMethod.cash), true);
      expect(summary.containsKey(PaymentMethod.creditCard), true);
      
      // Check that all payment methods are included
      for (final method in PaymentMethod.values) {
        expect(summary.containsKey(method), true);
        expect(summary[method], greaterThanOrEqualTo(0.0));
      }
    });

    test('should get hourly sales', () async {
      final today = DateTime.now();
      final hourlySales = await repository.getHourlySales(today);
      
      expect(hourlySales, isNotEmpty);
      expect(hourlySales.length, 24); // 24 hours
      
      // Check that all hours are included
      for (int hour = 0; hour < 24; hour++) {
        expect(hourlySales.containsKey(hour), true);
        expect(hourlySales[hour], greaterThanOrEqualTo(0.0));
      }
    });

    test('should get average sale amount', () async {
      final average = await repository.getAverageSaleAmount(null, null);
      
      expect(average, greaterThan(0.0));
    });

    test('should get average sale amount with date range', () async {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 7));
      
      final average = await repository.getAverageSaleAmount(startDate, endDate);
      
      expect(average, greaterThanOrEqualTo(0.0));
    });

    test('should throw when completing non-existent sale', () async {
      expect(
        () => repository.completeSale('non-existent-id'),
        throwsException,
      );
    });

    test('should throw when cancelling non-existent sale', () async {
      expect(
        () => repository.cancelSale('non-existent-id'),
        throwsException,
      );
    });

    test('should throw when refunding non-existent sale', () async {
      expect(
        () => repository.refundSale('non-existent-id'),
        throwsException,
      );
    });
  });
}