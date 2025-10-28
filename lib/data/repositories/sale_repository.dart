import '../models/sale.dart';
import '../models/enums.dart';
import '../../core/utils/result.dart';

abstract class SaleRepository {
  /// Get all sales
  Future<Result<List<Sale>>> getAllSales();
  
  /// Get sale by ID
  Future<Result<Sale?>> getSaleById(String id);
  
  /// Get sales by date range
  Future<Result<List<Sale>>> getSalesByDateRange(DateTime startDate, DateTime endDate);
  
  /// Get sales by customer ID
  Future<Result<List<Sale>>> getSalesByCustomer(String customerId);
  
  /// Get sales by status
  Future<Result<List<Sale>>> getSalesByStatus(SaleStatus status);
  
  /// Get sales by payment method
  Future<Result<List<Sale>>> getSalesByPaymentMethod(PaymentMethod paymentMethod);
  
  /// Get today's sales
  Future<Result<List<Sale>>> getTodaysSales();
  
  /// Create a new sale
  Future<Result<Sale>> createSale(Sale sale);
  
  /// Update an existing sale
  Future<Result<Sale>> updateSale(Sale sale);
  
  /// Complete a sale (change status to completed)
  Future<Result<Sale>> completeSale(String saleId);
  
  /// Cancel a sale
  Future<Result<Sale>> cancelSale(String saleId);
  
  /// Refund a sale
  Future<Result<Sale>> refundSale(String saleId);
  
  /// Get daily sales total
  Future<Result<double>> getDailySalesTotal(DateTime date);
  
  /// Get sales total by date range
  Future<Result<double>> getSalesTotalByDateRange(DateTime startDate, DateTime endDate);
  
  /// Get sales count by date range
  Future<Result<int>> getSalesCountByDateRange(DateTime startDate, DateTime endDate);
  
  /// Get top selling products
  Future<Result<Map<String, int>>> getTopSellingProducts(int limit, DateTime? startDate, DateTime? endDate);
  
  /// Get sales by payment method summary
  Future<Result<Map<PaymentMethod, double>>> getSalesByPaymentMethodSummary(DateTime startDate, DateTime endDate);
  
  /// Get hourly sales data for a specific date
  Future<Result<Map<int, double>>> getHourlySales(DateTime date);
  
  /// Get average sale amount
  Future<Result<double>> getAverageSaleAmount(DateTime? startDate, DateTime? endDate);
}