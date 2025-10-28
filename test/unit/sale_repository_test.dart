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
      final result = await repository.getAllSales();
      
      expect(result.isSuccess, true);
      final sales = result.data!;
      expect(sales, isNotEmpty);
      expect(sales.length, 150);
    });

    test('should get sale by ID', () async {
      final allSalesResult = await repository.getAllSales();
      expect(allSalesResult.isSuccess, true);
      final allSales = allSalesResult.data!;
      final firstSale = allSales.first;
      
      final foundSaleResult = await repository.getSaleById(firstSale.id);
      
      expect(foundSaleResult.isSuccess, true);
      final foundSale = foundSaleResult.data;
      expect(foundSale, isNotNull);
      expect(foundSale!.id, firstSale.id);
    });

    test('should return null for non-existent sale ID', () async {
      final result = await repository.getSaleById('non-existent-id');
      
      expect(result.isSuccess, true);
      final foundSale = result.data;
      expect(foundSale, isNull);
    });

    test('should get sales by date range', () async {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 7));
      
      final result = await repository.getSalesByDateRange(startDate, endDate);
      
      expect(result.isSuccess, true);
      final salesInRange = result.data!;
      expect(salesInRange, isNotEmpty);
      expect(salesInRange.every((s) => 
        s.createdAt.isAfter(startDate.subtract(const Duration(days: 1))) &&
        s.createdAt.isBefore(endDate.add(const Duration(days: 1)))
      ), true);
    });

    test('should get sales by customer', () async {
      final allSalesResult = await repository.getAllSales();
      expect(allSalesResult.isSuccess, true);
      final allSales = allSalesResult.data!;
      final saleWithCustomer = allSales.firstWhere((s) => s.customerId != null);
      
      final result = await repository.getSalesByCustomer(saleWithCustomer.customerId!);
      
      expect(result.isSuccess, true);
      final customerSales = result.data!;
      expect(customerSales, isNotEmpty);
      expect(customerSales.every((s) => s.customerId == saleWithCustomer.customerId), true);
    });

    test('should get sales by status', () async {
      final result = await repository.getSalesByStatus(SaleStatus.completed);
      
      expect(result.isSuccess, true);
      final completedSales = result.data!;
      expect(completedSales, isNotEmpty);
      expect(completedSales.every((s) => s.status == SaleStatus.completed), true);
    });

    test('should get sales by payment method', () async {
      final result = await repository.getSalesByPaymentMethod(PaymentMethod.cash);
      
      expect(result.isSuccess, true);
      final cashSales = result.data!;
      expect(cashSales.every((s) => s.paymentMethod == PaymentMethod.cash), true);
    });

    test('should get today\'s sales', () async {
      final result = await repository.getTodaysSales();
      
      expect(result.isSuccess, true);
      final todaysSales = result.data!;
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
      
      final result = await repository.createSale(newSale);
      
      expect(result.isSuccess, true);
      final createdSale = result.data!;
      expect(createdSale.id, newSale.id);
      expect(createdSale.items.length, 1);
      
      // Verify it's in the repository
      final foundResult = await repository.getSaleById(newSale.id);
      expect(foundResult.isSuccess, true);
      final foundSale = foundResult.data;
      expect(foundSale, isNotNull);
    });

    test('should update existing sale', () async {
      final allSalesResult = await repository.getAllSales();
      expect(allSalesResult.isSuccess, true);
      final allSales = allSalesResult.data!;
      final saleToUpdate = allSales.first;
      
      final updatedSale = saleToUpdate.copyWith(
        notes: 'Updated notes',
        discountAmount: 50.0,
      );
      
      final result = await repository.updateSale(updatedSale);
      
      expect(result.isSuccess, true);
      final updatedResult = result.data!;
      expect(updatedResult.notes, 'Updated notes');
      expect(updatedResult.discountAmount, 50.0);
      expect(updatedResult.updatedAt.isAfter(saleToUpdate.updatedAt), true);
    });

    test('should return failure when updating non-existent sale', () async {
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
      
      final result = await repository.updateSale(nonExistentSale);
      expect(result.isFailure, true);
    });

    test('should complete sale', () async {
      final allSalesResult = await repository.getAllSales();
      expect(allSalesResult.isSuccess, true);
      final allSales = allSalesResult.data!;
      final pendingSale = allSales.firstWhere((s) => s.status == SaleStatus.completed);
      
      final result = await repository.completeSale(pendingSale.id);
      
      expect(result.isSuccess, true);
      final completedSale = result.data!;
      expect(completedSale.status, SaleStatus.completed);
    });

    test('should cancel sale', () async {
      final allSalesResult = await repository.getAllSales();
      expect(allSalesResult.isSuccess, true);
      final allSales = allSalesResult.data!;
      final sale = allSales.first;
      
      final result = await repository.cancelSale(sale.id);
      
      expect(result.isSuccess, true);
      final cancelledSale = result.data!;
      expect(cancelledSale.status, SaleStatus.cancelled);
    });

    test('should refund sale', () async {
      final allSalesResult = await repository.getAllSales();
      expect(allSalesResult.isSuccess, true);
      final allSales = allSalesResult.data!;
      final sale = allSales.first;
      
      final result = await repository.refundSale(sale.id);
      
      expect(result.isSuccess, true);
      final refundedSale = result.data!;
      expect(refundedSale.status, SaleStatus.refunded);
    });

    test('should get daily sales total', () async {
      final today = DateTime.now();
      final result = await repository.getDailySalesTotal(today);
      
      expect(result.isSuccess, true);
      final total = result.data!;
      expect(total, greaterThanOrEqualTo(0.0));
    });

    test('should get sales total by date range', () async {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 7));
      
      final result = await repository.getSalesTotalByDateRange(startDate, endDate);
      
      expect(result.isSuccess, true);
      final total = result.data!;
      expect(total, greaterThan(0.0));
    });

    test('should get sales count by date range', () async {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));
      
      final result = await repository.getSalesCountByDateRange(startDate, endDate);
      
      expect(result.isSuccess, true);
      final count = result.data!;
      expect(count, greaterThan(0));
    });

    test('should get top selling products', () async {
      final result = await repository.getTopSellingProducts(5, null, null);
      
      expect(result.isSuccess, true);
      final topProducts = result.data!;
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
      
      final result = await repository.getTopSellingProducts(3, startDate, endDate);
      
      expect(result.isSuccess, true);
      final topProducts = result.data!;
      expect(topProducts.length, lessThanOrEqualTo(3));
    });

    test('should get sales by payment method summary', () async {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));
      
      final result = await repository.getSalesByPaymentMethodSummary(startDate, endDate);
      
      expect(result.isSuccess, true);
      final summary = result.data!;
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
      final result = await repository.getHourlySales(today);
      
      expect(result.isSuccess, true);
      final hourlySales = result.data!;
      expect(hourlySales, isNotEmpty);
      expect(hourlySales.length, 24); // 24 hours
      
      // Check that all hours are included
      for (int hour = 0; hour < 24; hour++) {
        expect(hourlySales.containsKey(hour), true);
        expect(hourlySales[hour], greaterThanOrEqualTo(0.0));
      }
    });

    test('should get average sale amount', () async {
      final result = await repository.getAverageSaleAmount(null, null);
      
      expect(result.isSuccess, true);
      final average = result.data!;
      expect(average, greaterThan(0.0));
    });

    test('should get average sale amount with date range', () async {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 7));
      
      final result = await repository.getAverageSaleAmount(startDate, endDate);
      
      expect(result.isSuccess, true);
      final average = result.data!;
      expect(average, greaterThanOrEqualTo(0.0));
    });

    test('should return failure when completing non-existent sale', () async {
      final result = await repository.completeSale('non-existent-id');
      expect(result.isFailure, true);
    });

    test('should return failure when cancelling non-existent sale', () async {
      final result = await repository.cancelSale('non-existent-id');
      expect(result.isFailure, true);
    });

    test('should return failure when refunding non-existent sale', () async {
      final result = await repository.refundSale('non-existent-id');
      expect(result.isFailure, true);
    });
  });
}