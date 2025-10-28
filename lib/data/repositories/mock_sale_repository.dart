import 'dart:math';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../models/customer.dart';
import '../models/enums.dart';
import 'sale_repository.dart';
import 'mock_product_repository.dart';
import 'mock_customer_repository.dart';
import '../../core/error/app_error.dart';
import '../../core/utils/result.dart';
import '../../core/validation/validators.dart';

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
  Future<Result<List<Sale>>> getAllSales() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      return Result.success(List.from(_sales));
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: '売上リストの取得に失敗しました',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<Result<Sale?>> getSaleById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      final sale = _sales.where((s) => s.id == id).firstOrNull;
      return Result.success(sale);
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: '売上の取得に失敗しました',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<Result<List<Sale>>> getSalesByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final results = _sales.where((s) => 
        s.createdAt.isAfter(startDate.subtract(const Duration(days: 1))) &&
        s.createdAt.isBefore(endDate.add(const Duration(days: 1)))
      ).toList();
      return Result.success(results);
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: '期間売上の取得に失敗しました',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<Result<List<Sale>>> getSalesByCustomer(String customerId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      return Result.success(_sales.where((s) => s.customerId == customerId).toList());
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: '顧客別売上の取得に失敗しました',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<Result<List<Sale>>> getSalesByStatus(SaleStatus status) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      return Result.success(_sales.where((s) => s.status == status).toList());
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: 'ステータス別売上の取得に失敗しました',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<Result<List<Sale>>> getSalesByPaymentMethod(PaymentMethod paymentMethod) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      return Result.success(_sales.where((s) => s.paymentMethod == paymentMethod).toList());
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: '支払方法別売上の取得に失敗しました',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<Result<List<Sale>>> getTodaysSales() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final results = _sales.where((s) => 
        s.createdAt.isAfter(startOfDay) &&
        s.createdAt.isBefore(endOfDay)
      ).toList();
      return Result.success(results);
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: '今日の売上の取得に失敗しました',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<Result<Sale>> createSale(Sale sale) async {
    try {
      // バリデーション
      if (sale.items.isEmpty) {
        return Result.failure(
          ValidationError(
            message: '売上アイテムが空です',
            fieldErrors: {'items': '売上アイテムが空です'},
          ),
        );
      }
      
      if (sale.finalTotal < 0) {
        return Result.failure(
          ValidationError(
            message: '売上金額がマイナスです',
            fieldErrors: {'total': '売上金額がマイナスです'},
          ),
        );
      }
      
      await Future.delayed(const Duration(milliseconds: 200));
      _sales.insert(0, sale); // Add to beginning (newest first)
      return Result.success(sale);
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: '売上の作成に失敗しました',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<Result<Sale>> updateSale(Sale sale) async {
    try {
      // バリデーション
      if (sale.items.isEmpty) {
        return Result.failure(
          ValidationError(
            message: '売上アイテムが空です',
            fieldErrors: {'items': '売上アイテムが空です'},
          ),
        );
      }
      
      if (sale.finalTotal < 0) {
        return Result.failure(
          ValidationError(
            message: '売上金額がマイナスです',
            fieldErrors: {'total': '売上金額がマイナスです'},
          ),
        );
      }
      
      await Future.delayed(const Duration(milliseconds: 200));
      final index = _sales.indexWhere((s) => s.id == sale.id);
      if (index != -1) {
        _sales[index] = sale.copyWith(updatedAt: DateTime.now());
        return Result.success(_sales[index]);
      }
      return Result.failure(
        NotFoundError(message: '売上が見つかりません'),
      );
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: '売上の更新に失敗しました',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<Result<Sale>> completeSale(String saleId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      final index = _sales.indexWhere((s) => s.id == saleId);
      if (index != -1) {
        _sales[index] = _sales[index].copyWith(
          status: SaleStatus.completed,
          updatedAt: DateTime.now(),
        );
        return Result.success(_sales[index]);
      }
      return Result.failure(
        NotFoundError(message: '売上が見つかりません'),
      );
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: '売上の完了処理に失敗しました',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<Result<Sale>> cancelSale(String saleId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      final index = _sales.indexWhere((s) => s.id == saleId);
      if (index != -1) {
        _sales[index] = _sales[index].copyWith(
          status: SaleStatus.cancelled,
          updatedAt: DateTime.now(),
        );
        return Result.success(_sales[index]);
      }
      return Result.failure(
        NotFoundError(message: '売上が見つかりません'),
      );
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: '売上のキャンセル処理に失敗しました',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<Result<Sale>> refundSale(String saleId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      final index = _sales.indexWhere((s) => s.id == saleId);
      if (index != -1) {
        _sales[index] = _sales[index].copyWith(
          status: SaleStatus.refunded,
          updatedAt: DateTime.now(),
        );
        return Result.success(_sales[index]);
      }
      return Result.failure(
        NotFoundError(message: '売上が見つかりません'),
      );
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: '売上の返金処理に失敗しました',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<Result<double>> getDailySalesTotal(DateTime date) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final dailySales = _sales.where((s) => 
        s.createdAt.isAfter(startOfDay) &&
        s.createdAt.isBefore(endOfDay) &&
        s.status == SaleStatus.completed
      );
      
      final total = dailySales.fold<double>(0.0, (sum, sale) => sum + sale.finalTotal);
      return Result.success(total);
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: '日別売上合計の取得に失敗しました',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<Result<double>> getSalesTotalByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final salesResult = await getSalesByDateRange(startDate, endDate);
      
      return salesResult.when(
        success: (salesInRange) {
          final total = salesInRange
            .where((s) => s.status == SaleStatus.completed)
            .fold<double>(0.0, (sum, sale) => sum + sale.finalTotal);
          return Result.success(total);
        },
        failure: (error) => Result.failure(error),
      );
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: '期間売上合計の取得に失敗しました',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<Result<int>> getSalesCountByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final salesResult = await getSalesByDateRange(startDate, endDate);
      
      return salesResult.when(
        success: (salesInRange) {
          final count = salesInRange.where((s) => s.status == SaleStatus.completed).length;
          return Result.success(count);
        },
        failure: (error) => Result.failure(error),
      );
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: '期間売上件数の取得に失敗しました',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<Result<Map<String, int>>> getTopSellingProducts(int limit, DateTime? startDate, DateTime? endDate) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      List<Sale> salesToAnalyze = _sales;
      
      if (startDate != null && endDate != null) {
        final salesResult = await getSalesByDateRange(startDate, endDate);
        if (salesResult.isFailure) {
          return Result.failure(salesResult.error!);
        }
        salesToAnalyze = salesResult.data!;
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
      
      return Result.success(Map.fromEntries(sortedEntries.take(limit)));
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: '人気商品ランキングの取得に失敗しました',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<Result<Map<PaymentMethod, double>>> getSalesByPaymentMethodSummary(DateTime startDate, DateTime endDate) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final salesResult = await getSalesByDateRange(startDate, endDate);
      
      return salesResult.when(
        success: (salesInRange) {
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
          
          return Result.success(paymentSummary);
        },
        failure: (error) => Result.failure(error),
      );
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: '支払方法別売上サマリーの取得に失敗しました',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<Result<Map<int, double>>> getHourlySales(DateTime date) async {
    try {
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
      
      return Result.success(hourlySales);
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: '時間別売上の取得に失敗しました',
          originalError: error,
        ),
      );
    }
  }

  @override
  Future<Result<double>> getAverageSaleAmount(DateTime? startDate, DateTime? endDate) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      List<Sale> salesToAnalyze = _sales;
      
      if (startDate != null && endDate != null) {
        final salesResult = await getSalesByDateRange(startDate, endDate);
        if (salesResult.isFailure) {
          return Result.failure(salesResult.error!);
        }
        salesToAnalyze = salesResult.data!;
      }
      
      final completedSales = salesToAnalyze.where((s) => s.status == SaleStatus.completed);
      
      if (completedSales.isEmpty) {
        return Result.success(0.0);
      }
      
      final total = completedSales.fold<double>(0.0, (sum, sale) => sum + sale.finalTotal);
      return Result.success(total / completedSales.length);
    } catch (error) {
      return Result.failure(
        RepositoryError(
          message: '平均売上金額の取得に失敗しました',
          originalError: error,
        ),
      );
    }
  }
}