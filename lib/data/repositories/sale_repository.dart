import '../models/sale.dart';
import '../models/enums.dart';

abstract class SaleRepository {
  /// Get all sales
  Future<List<Sale>> getAllSales();
  
  /// Get sale by ID
  Future<Sale?> getSaleById(String id);
  
  /// Get sales by date range
  Future<List<Sale>> getSalesByDateRange(DateTime startDate, DateTime endDate);
  
  /// Get sales by customer ID
  Future<List<Sale>> getSalesByCustomer(String customerId);
  
  /// Get sales by status
  Future<List<Sale>> getSalesByStatus(SaleStatus status);
  
  /// Get sales by payment method
  Future<List<Sale>> getSalesByPaymentMethod(PaymentMethod paymentMethod);
  
  /// Get today's sales
  Future<List<Sale>> getTodaysSales();
  
  /// Create a new sale
  Future<Sale> createSale(Sale sale);
  
  /// Update an existing sale
  Future<Sale> updateSale(Sale sale);
  
  /// Complete a sale (change status to completed)
  Future<Sale> completeSale(String saleId);
  
  /// Cancel a sale
  Future<Sale> cancelSale(String saleId);
  
  /// Refund a sale
  Future<Sale> refundSale(String saleId);
  
  /// Get daily sales total
  Future<double> getDailySalesTotal(DateTime date);
  
  /// Get sales total by date range
  Future<double> getSalesTotalByDateRange(DateTime startDate, DateTime endDate);
  
  /// Get sales count by date range
  Future<int> getSalesCountByDateRange(DateTime startDate, DateTime endDate);
  
  /// Get top selling products
  Future<Map<String, int>> getTopSellingProducts(int limit, DateTime? startDate, DateTime? endDate);
  
  /// Get sales by payment method summary
  Future<Map<PaymentMethod, double>> getSalesByPaymentMethodSummary(DateTime startDate, DateTime endDate);
  
  /// Get hourly sales data for a specific date
  Future<Map<int, double>> getHourlySales(DateTime date);
  
  /// Get average sale amount
  Future<double> getAverageSaleAmount(DateTime? startDate, DateTime? endDate);
}