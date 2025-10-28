import 'package:flutter_test/flutter_test.dart';
import 'package:pos_flutter/data/repositories/mock_customer_repository.dart';
import 'package:pos_flutter/data/repositories/customer_repository.dart';
import 'package:pos_flutter/data/models/customer.dart';

void main() {
  group('Customer Repository Tests', () {
    late CustomerRepository repository;

    setUp(() {
      repository = MockCustomerRepository();
    });

    test('should get all customers', () async {
      final customers = await repository.getAllCustomers();
      
      expect(customers, isNotEmpty);
      expect(customers.length, 20);
    });

    test('should get customer by ID', () async {
      final allCustomers = await repository.getAllCustomers();
      final firstCustomer = allCustomers.first;
      
      final foundCustomer = await repository.getCustomerById(firstCustomer.id);
      
      expect(foundCustomer, isNotNull);
      expect(foundCustomer!.id, firstCustomer.id);
      expect(foundCustomer.name, firstCustomer.name);
    });

    test('should return null for non-existent customer ID', () async {
      final foundCustomer = await repository.getCustomerById('non-existent-id');
      
      expect(foundCustomer, isNull);
    });

    test('should search customers by name', () async {
      final searchResults = await repository.searchCustomers('田中');
      
      expect(searchResults, isNotEmpty);
      expect(searchResults.every((c) => c.name.contains('田中')), true);
    });

    test('should search customers by email', () async {
      final searchResults = await repository.searchCustomers('tanaka@example.com');
      
      expect(searchResults, isNotEmpty);
      expect(searchResults.first.email, 'tanaka@example.com');
    });

    test('should search customers by phone', () async {
      final searchResults = await repository.searchCustomers('090-1234-5678');
      
      expect(searchResults, isNotEmpty);
      expect(searchResults.first.phone, '090-1234-5678');
    });

    test('should search customers case insensitive', () async {
      final searchResults = await repository.searchCustomers('TANAKA');
      
      expect(searchResults, isNotEmpty);
    });

    test('should get customers with minimum loyalty points', () async {
      final highPointCustomers = await repository.getCustomersWithPoints(200);
      
      expect(highPointCustomers, isNotEmpty);
      expect(highPointCustomers.every((c) => c.loyaltyPoints >= 200), true);
    });

    test('should get active customers only', () async {
      final activeCustomers = await repository.getActiveCustomers();
      
      expect(activeCustomers, isNotEmpty);
      expect(activeCustomers.every((c) => c.isActive), true);
    });

    test('should create new customer', () async {
      final newCustomer = Customer.create(
        name: 'Test Customer',
        email: 'test@example.com',
        phone: '090-0000-0000',
        loyaltyPoints: 0,
      );
      
      final createdCustomer = await repository.createCustomer(newCustomer);
      
      expect(createdCustomer.name, 'Test Customer');
      expect(createdCustomer.id, newCustomer.id);
      
      // Verify it's in the repository
      final foundCustomer = await repository.getCustomerById(newCustomer.id);
      expect(foundCustomer, isNotNull);
    });

    test('should update existing customer', () async {
      final allCustomers = await repository.getAllCustomers();
      final customerToUpdate = allCustomers.first;
      
      final updatedCustomer = customerToUpdate.copyWith(
        name: 'Updated Name',
        loyaltyPoints: 999,
      );
      
      final result = await repository.updateCustomer(updatedCustomer);
      
      expect(result.name, 'Updated Name');
      expect(result.loyaltyPoints, 999);
      expect(result.updatedAt.isAfter(customerToUpdate.updatedAt), true);
    });

    test('should throw when updating non-existent customer', () async {
      final nonExistentCustomer = Customer.create(
        name: 'Non-existent',
        email: 'nonexistent@example.com',
      );
      
      expect(
        () => repository.updateCustomer(nonExistentCustomer),
        throwsException,
      );
    });

    test('should soft delete customer', () async {
      final allCustomers = await repository.getAllCustomers();
      final customerToDelete = allCustomers.first;
      
      await repository.deleteCustomer(customerToDelete.id);
      
      final foundCustomer = await repository.getCustomerById(customerToDelete.id);
      expect(foundCustomer!.isActive, false);
    });

    test('should add loyalty points', () async {
      final allCustomers = await repository.getAllCustomers();
      final customer = allCustomers.first;
      final originalPoints = customer.loyaltyPoints;
      
      final updatedCustomer = await repository.addLoyaltyPoints(customer.id, 50);
      
      expect(updatedCustomer.loyaltyPoints, originalPoints + 50);
      expect(updatedCustomer.updatedAt.isAfter(customer.updatedAt), true);
    });

    test('should subtract loyalty points', () async {
      final allCustomers = await repository.getAllCustomers();
      final customer = allCustomers.where((c) => c.loyaltyPoints > 100).first;
      final originalPoints = customer.loyaltyPoints;
      
      final updatedCustomer = await repository.subtractLoyaltyPoints(customer.id, 50);
      
      expect(updatedCustomer.loyaltyPoints, originalPoints - 50);
    });

    test('should not allow negative loyalty points when subtracting', () async {
      final allCustomers = await repository.getAllCustomers();
      final customer = allCustomers.first;
      
      final updatedCustomer = await repository.subtractLoyaltyPoints(customer.id, 10000);
      
      expect(updatedCustomer.loyaltyPoints, 0);
    });

    test('should get customer by phone', () async {
      final customer = await repository.getCustomerByPhone('090-1234-5678');
      
      expect(customer, isNotNull);
      expect(customer!.phone, '090-1234-5678');
    });

    test('should return null for non-existent phone', () async {
      final customer = await repository.getCustomerByPhone('000-0000-0000');
      
      expect(customer, isNull);
    });

    test('should get customer by email', () async {
      final customer = await repository.getCustomerByEmail('tanaka@example.com');
      
      expect(customer, isNotNull);
      expect(customer!.email, 'tanaka@example.com');
    });

    test('should return null for non-existent email', () async {
      final customer = await repository.getCustomerByEmail('nonexistent@example.com');
      
      expect(customer, isNull);
    });

    test('should get total customer count', () async {
      final count = await repository.getTotalCustomerCount();
      
      expect(count, greaterThan(0));
      expect(count, lessThanOrEqualTo(20));
    });

    test('should get birthday customers for current month', () async {
      final birthdayCustomers = await repository.getBirthdayCustomers();
      
      final currentMonth = DateTime.now().month;
      expect(birthdayCustomers.every((c) => 
        c.dateOfBirth?.month == currentMonth
      ), true);
    });

    test('should throw when adding points to non-existent customer', () async {
      expect(
        () => repository.addLoyaltyPoints('non-existent-id', 50),
        throwsException,
      );
    });

    test('should throw when subtracting points from non-existent customer', () async {
      expect(
        () => repository.subtractLoyaltyPoints('non-existent-id', 50),
        throwsException,
      );
    });
  });
}