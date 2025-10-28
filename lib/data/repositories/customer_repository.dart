import '../models/customer.dart';
import '../../core/utils/result.dart';

abstract class CustomerRepository {
  /// Get all customers
  Future<Result<List<Customer>>> getAllCustomers();
  
  /// Get customer by ID
  Future<Result<Customer?>> getCustomerById(String id);
  
  /// Search customers by name, email, or phone
  Future<Result<List<Customer>>> searchCustomers(String query);
  
  /// Get customers with loyalty points above threshold
  Future<Result<List<Customer>>> getCustomersWithPoints(int minPoints);
  
  /// Get active customers only
  Future<Result<List<Customer>>> getActiveCustomers();
  
  /// Create a new customer
  Future<Result<Customer>> createCustomer(Customer customer);
  
  /// Update an existing customer
  Future<Result<Customer>> updateCustomer(Customer customer);
  
  /// Delete a customer (soft delete - mark as inactive)
  Future<Result<void>> deleteCustomer(String id);
  
  /// Add loyalty points to customer
  Future<Result<Customer>> addLoyaltyPoints(String customerId, int points);
  
  /// Subtract loyalty points from customer
  Future<Result<Customer>> subtractLoyaltyPoints(String customerId, int points);
  
  /// Get customer by phone number
  Future<Result<Customer?>> getCustomerByPhone(String phone);
  
  /// Get customer by email
  Future<Result<Customer?>> getCustomerByEmail(String email);
  
  /// Get total customer count
  Future<Result<int>> getTotalCustomerCount();
  
  /// Get customers with birthdays in current month
  Future<Result<List<Customer>>> getBirthdayCustomers();
}