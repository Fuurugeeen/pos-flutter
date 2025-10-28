import 'dart:math';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../models/customer.dart';
import '../models/enums.dart';
import 'sale_repository.dart';
import 'mock_product_repository.dart';
import 'mock_customer_repository.dart';

class MockSaleRepository implements SaleRepository {
  final List<Sale> _sales = [];
  final Random _random = Random();

  MockSaleRepository() {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    final productRepo = MockProductRepository();
    final customerRepo = MockCustomerRepository();
    
    // Generate 150 sales over the past 30 days
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 30));
    
    _generateSalesData(productRepo, customerRepo, startDate, now, 150);
  }

  void _generateSalesData(
    MockProductRepository productRepo,
    MockCustomerRepository customerRepo,
    DateTime startDate,
    DateTime endDate,
    int count,
  ) {
    // Get the sample data synchronously using the public getters
    final products = productRepo.products;
    final customers = customerRepo.customers;
    
    for (int i = 0; i < count; i++) {
      // Random date between start and end
      final daysDiff = endDate.difference(startDate).inDays;
      final randomDays = _random.nextInt(daysDiff + 1);
      final saleDate = startDate.add(Duration(days: randomDays));
      
      // Random hour between 7 AM and 9 PM
      final hour = 7 + _random.nextInt(14);
      final minute = _random.nextInt(60);
      final createdAt = DateTime(saleDate.year, saleDate.month, saleDate.day, hour, minute);
      
      // Random customer (70% chance of having a customer)
      Customer? customer;
      if (_random.nextDouble() < 0.7 && customers.isNotEmpty) {
        customer = customers[_random.nextInt(customers.length)];
      }
      
      // Generate 1-5 items
      final itemCount = 1 + _random.nextInt(5);
      final items = <SaleItem>[];
      
      for (int j = 0; j < itemCount; j++) {
        final product = products[_random.nextInt(products.length)];
        final quantity = 1 + _random.nextInt(3);
        items.add(SaleItem.fromProduct(product, quantity));
      }
      
      // Random payment method
      final paymentMethods = PaymentMethod.values;
      final paymentMethod = paymentMethods[_random.nextInt(paymentMethods.length)];
      
      // Random discount (30% chance)
      final discountAmount = _random.nextDouble() < 0.3 ? 
        (_random.nextDouble() * 200).roundToDouble() : 0.0;
      
      // Random loyalty points usage (20% chance if customer exists)
      final loyaltyPointsUsed = customer != null && _random.nextDouble() < 0.2 ?
        _random.nextInt(customer.loyaltyPoints + 1) : 0;
      
      // Calculate loyalty points earned (1 point per 100 yen)
      final totalAmount = items.fold(0.0, (sum, item) => sum + item.total);
      final loyaltyPointsEarned = customer != null ? 
        (totalAmount / 100).floor() : 0;
      
      final sale = Sale(
        id: 'sale-${i.toString().padLeft(3, '0')}',
        customerId: customer?.id,
        customerName: customer?.name,
        items: items,
        paymentMethod: paymentMethod,
        status: SaleStatus.completed,
        discountAmount: discountAmount,
        loyaltyPointsUsed: loyaltyPointsUsed,
        loyaltyPointsEarned: loyaltyPointsEarned,
        notes: _random.nextDouble() < 0.1 ? 'Special request' : null,
        createdAt: createdAt,
        updatedAt: createdAt,
      );
      
      _sales.add(sale);
    }
    
    // Sort by creation date (newest first)
    _sales.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<Sale>> getAllSales() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_sales);
  }

  @override
  Future<Sale?> getSaleById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _sales.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Sale>> getSalesByDateRange(DateTime startDate, DateTime endDate) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _sales.where((s) => 
      s.createdAt.isAfter(startDate.subtract(const Duration(days: 1))) &&
      s.createdAt.isBefore(endDate.add(const Duration(days: 1)))
    ).toList();
  }

  @override
  Future<List<Sale>> getSalesByCustomer(String customerId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _sales.where((s) => s.customerId == customerId).toList();
  }

  @override
  Future<List<Sale>> getSalesByStatus(SaleStatus status) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _sales.where((s) => s.status == status).toList();
  }

  @override
  Future<List<Sale>> getSalesByPaymentMethod(PaymentMethod paymentMethod) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _sales.where((s) => s.paymentMethod == paymentMethod).toList();
  }

  @override
  Future<List<Sale>> getTodaysSales() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _sales.where((s) => 
      s.createdAt.isAfter(startOfDay) &&
      s.createdAt.isBefore(endOfDay)
    ).toList();
  }

  @override
  Future<Sale> createSale(Sale sale) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _sales.insert(0, sale); // Add to beginning (newest first)
    return sale;
  }

  @override
  Future<Sale> updateSale(Sale sale) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _sales.indexWhere((s) => s.id == sale.id);
    if (index != -1) {
      _sales[index] = sale.copyWith(updatedAt: DateTime.now());
      return _sales[index];
    }
    throw Exception('Sale not found');
  }

  @override
  Future<Sale> completeSale(String saleId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _sales.indexWhere((s) => s.id == saleId);
    if (index != -1) {
      _sales[index] = _sales[index].copyWith(
        status: SaleStatus.completed,
        updatedAt: DateTime.now(),
      );
      return _sales[index];
    }
    throw Exception('Sale not found');
  }

  @override
  Future<Sale> cancelSale(String saleId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _sales.indexWhere((s) => s.id == saleId);
    if (index != -1) {
      _sales[index] = _sales[index].copyWith(
        status: SaleStatus.cancelled,
        updatedAt: DateTime.now(),
      );
      return _sales[index];
    }
    throw Exception('Sale not found');
  }

  @override
  Future<Sale> refundSale(String saleId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _sales.indexWhere((s) => s.id == saleId);
    if (index != -1) {
      _sales[index] = _sales[index].copyWith(
        status: SaleStatus.refunded,
        updatedAt: DateTime.now(),
      );
      return _sales[index];
    }
    throw Exception('Sale not found');
  }

  @override
  Future<double> getDailySalesTotal(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final dailySales = _sales.where((s) => 
      s.createdAt.isAfter(startOfDay) &&
      s.createdAt.isBefore(endOfDay) &&
      s.status == SaleStatus.completed
    );
    
    return dailySales.fold<double>(0.0, (sum, sale) => sum + sale.finalTotal);
  }

  @override
  Future<double> getSalesTotalByDateRange(DateTime startDate, DateTime endDate) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final salesInRange = await getSalesByDateRange(startDate, endDate);
    
    return salesInRange
      .where((s) => s.status == SaleStatus.completed)
      .fold<double>(0.0, (sum, sale) => sum + sale.finalTotal);
  }

  @override
  Future<int> getSalesCountByDateRange(DateTime startDate, DateTime endDate) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final salesInRange = await getSalesByDateRange(startDate, endDate);
    
    return salesInRange.where((s) => s.status == SaleStatus.completed).length;
  }

  @override
  Future<Map<String, int>> getTopSellingProducts(int limit, DateTime? startDate, DateTime? endDate) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    List<Sale> salesToAnalyze = _sales;
    
    if (startDate != null && endDate != null) {
      salesToAnalyze = await getSalesByDateRange(startDate, endDate);
    }
    
    final productQuantities = <String, int>{};
    
    for (final sale in salesToAnalyze) {
      if (sale.status == SaleStatus.completed) {
        for (final item in sale.items) {
          productQuantities[item.productName] = 
            (productQuantities[item.productName] ?? 0) + item.quantity;
        }
      }
    }
    
    final sortedEntries = productQuantities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sortedEntries.take(limit));
  }

  @override
  Future<Map<PaymentMethod, double>> getSalesByPaymentMethodSummary(DateTime startDate, DateTime endDate) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final salesInRange = await getSalesByDateRange(startDate, endDate);
    
    final paymentSummary = <PaymentMethod, double>{};
    
    for (final method in PaymentMethod.values) {
      paymentSummary[method] = 0.0;
    }
    
    for (final sale in salesInRange) {
      if (sale.status == SaleStatus.completed) {
        final currentValue = paymentSummary[sale.paymentMethod] ?? 0.0;
        paymentSummary[sale.paymentMethod] = currentValue + sale.finalTotal;
      }
    }
    
    return paymentSummary;
  }

  @override
  Future<Map<int, double>> getHourlySales(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final hourlySales = <int, double>{};
    
    // Initialize all hours with 0
    for (int hour = 0; hour < 24; hour++) {
      hourlySales[hour] = 0.0;
    }
    
    final dailySales = _sales.where((s) => 
      s.createdAt.isAfter(startOfDay) &&
      s.createdAt.isBefore(endOfDay) &&
      s.status == SaleStatus.completed
    );
    
    for (final sale in dailySales) {
      final hour = sale.createdAt.hour;
      final currentValue = hourlySales[hour] ?? 0.0;
      hourlySales[hour] = currentValue + sale.finalTotal;
    }
    
    return hourlySales;
  }

  @override
  Future<double> getAverageSaleAmount(DateTime? startDate, DateTime? endDate) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    List<Sale> salesToAnalyze = _sales;
    
    if (startDate != null && endDate != null) {
      salesToAnalyze = await getSalesByDateRange(startDate, endDate);
    }
    
    final completedSales = salesToAnalyze.where((s) => s.status == SaleStatus.completed);
    
    if (completedSales.isEmpty) return 0.0;
    
    final total = completedSales.fold<double>(0.0, (sum, sale) => sum + sale.finalTotal);
    return total / completedSales.length;
  }
}