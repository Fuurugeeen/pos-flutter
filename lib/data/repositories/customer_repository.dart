import '../models/customer.dart';

abstract class CustomerRepository {
  /// Get all customers
  Future<List<Customer>> getAllCustomers();
  
  /// Get customer by ID
  Future<Customer?> getCustomerById(String id);
  
  /// Search customers by name, email, or phone
  Future<List<Customer>> searchCustomers(String query);
  
  /// Get customers with loyalty points above threshold
  Future<List<Customer>> getCustomersWithPoints(int minPoints);
  
  /// Get active customers only
  Future<List<Customer>> getActiveCustomers();
  
  /// Create a new customer
  Future<Customer> createCustomer(Customer customer);
  
  /// Update an existing customer
  Future<Customer> updateCustomer(Customer customer);
  
  /// Delete a customer (soft delete - mark as inactive)
  Future<void> deleteCustomer(String id);
  
  /// Add loyalty points to customer
  Future<Customer> addLoyaltyPoints(String customerId, int points);
  
  /// Subtract loyalty points from customer
  Future<Customer> subtractLoyaltyPoints(String customerId, int points);
  
  /// Get customer by phone number
  Future<Customer?> getCustomerByPhone(String phone);
  
  /// Get customer by email
  Future<Customer?> getCustomerByEmail(String email);
  
  /// Get total customer count
  Future<int> getTotalCustomerCount();
  
  /// Get customers with birthdays in current month
  Future<List<Customer>> getBirthdayCustomers();
}