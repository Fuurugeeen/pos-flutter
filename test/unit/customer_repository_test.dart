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
      final result = await repository.getAllCustomers();

      expect(result.isSuccess, true);
      final customers = result.data!;
      expect(customers, isNotEmpty);
      expect(customers.length, 20);
    });

    test('should get customer by ID', () async {
      final allResult = await repository.getAllCustomers();
      expect(allResult.isSuccess, true);
      final firstCustomer = allResult.data!.first;

      final result = await repository.getCustomerById(firstCustomer.id);

      expect(result.isSuccess, true);
      final foundCustomer = result.data;
      expect(foundCustomer, isNotNull);
      expect(foundCustomer!.id, firstCustomer.id);
      expect(foundCustomer.name, firstCustomer.name);
    });

    test('should return null for non-existent customer ID', () async {
      final result = await repository.getCustomerById('non-existent-id');

      expect(result.isSuccess, true);
      final foundCustomer = result.data;
      expect(foundCustomer, isNull);
    });

    test('should search customers by name', () async {
      final result = await repository.searchCustomers('田中');

      expect(result.isSuccess, true);
      final searchResults = result.data!;
      expect(searchResults, isNotEmpty);
      expect(searchResults.every((c) => c.name.contains('田中')), true);
    });

    test('should search customers by email', () async {
      final result = await repository.searchCustomers('tanaka@example.com');

      expect(result.isSuccess, true);
      final searchResults = result.data!;
      expect(searchResults, isNotEmpty);
      expect(searchResults.first.email, 'tanaka@example.com');
    });

    test('should search customers by phone', () async {
      final result = await repository.searchCustomers('090-1234-5678');

      expect(result.isSuccess, true);
      final searchResults = result.data!;
      expect(searchResults, isNotEmpty);
      expect(searchResults.first.phone, '090-1234-5678');
    });

    test('should search customers case insensitive', () async {
      final result = await repository.searchCustomers('TANAKA');

      expect(result.isSuccess, true);
      final searchResults = result.data!;
      expect(searchResults, isNotEmpty);
    });

    test('should get customers with minimum loyalty points', () async {
      final result = await repository.getCustomersWithPoints(200);

      expect(result.isSuccess, true);
      final highPointCustomers = result.data!;
      expect(highPointCustomers, isNotEmpty);
      expect(highPointCustomers.every((c) => c.loyaltyPoints >= 200), true);
    });

    test('should get active customers only', () async {
      final result = await repository.getActiveCustomers();

      expect(result.isSuccess, true);
      final activeCustomers = result.data!;
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

      final createResult = await repository.createCustomer(newCustomer);

      expect(createResult.isSuccess, true);
      final createdCustomer = createResult.data!;
      expect(createdCustomer.name, 'Test Customer');
      expect(createdCustomer.id, newCustomer.id);

      // Verify it's in the repository
      final findResult = await repository.getCustomerById(newCustomer.id);
      expect(findResult.isSuccess, true);
      expect(findResult.data, isNotNull);
    });

    test('should update existing customer', () async {
      final allResult = await repository.getAllCustomers();
      expect(allResult.isSuccess, true);
      final customerToUpdate = allResult.data!.first;

      final updatedCustomer = customerToUpdate.copyWith(
        name: 'Updated Name',
        loyaltyPoints: 999,
      );

      final updateResult = await repository.updateCustomer(updatedCustomer);

      expect(updateResult.isSuccess, true);
      final result = updateResult.data!;
      expect(result.name, 'Updated Name');
      expect(result.loyaltyPoints, 999);
      expect(result.updatedAt.isAfter(customerToUpdate.updatedAt), true);
    });

    test('should throw when updating non-existent customer', () async {
      final nonExistentCustomer = Customer.create(
        name: 'Non-existent',
        email: 'nonexistent@example.com',
      );

      final result = await repository.updateCustomer(nonExistentCustomer);

      expect(result.isSuccess, false);
      expect(result.error, isNotNull);
    });

    test('should soft delete customer', () async {
      final allResult = await repository.getAllCustomers();
      expect(allResult.isSuccess, true);
      final customerToDelete = allResult.data!.first;

      final deleteResult = await repository.deleteCustomer(customerToDelete.id);
      expect(deleteResult.isSuccess, true);

      final findResult = await repository.getCustomerById(customerToDelete.id);
      expect(findResult.isSuccess, true);
      expect(findResult.data!.isActive, false);
    });

    test('should add loyalty points', () async {
      final allResult = await repository.getAllCustomers();
      expect(allResult.isSuccess, true);
      final customer = allResult.data!.first;
      final originalPoints = customer.loyaltyPoints;

      final addResult = await repository.addLoyaltyPoints(customer.id, 50);

      expect(addResult.isSuccess, true);
      final updatedCustomer = addResult.data!;
      expect(updatedCustomer.loyaltyPoints, originalPoints + 50);
      expect(updatedCustomer.updatedAt.isAfter(customer.updatedAt), true);
    });

    test('should subtract loyalty points', () async {
      final allResult = await repository.getAllCustomers();
      expect(allResult.isSuccess, true);
      final customer = allResult.data!.where((c) => c.loyaltyPoints > 100).first;
      final originalPoints = customer.loyaltyPoints;

      final subtractResult = await repository.subtractLoyaltyPoints(customer.id, 50);

      expect(subtractResult.isSuccess, true);
      final updatedCustomer = subtractResult.data!;
      expect(updatedCustomer.loyaltyPoints, originalPoints - 50);
    });

    test('should not allow negative loyalty points when subtracting', () async {
      final allResult = await repository.getAllCustomers();
      expect(allResult.isSuccess, true);
      final customer = allResult.data!.first;

      final subtractResult = await repository.subtractLoyaltyPoints(customer.id, 10000);

      // The repository returns a failure when trying to subtract more points than available
      expect(subtractResult.isSuccess, false);
      expect(subtractResult.error, isNotNull);
    });

    test('should get customer by phone', () async {
      final result = await repository.getCustomerByPhone('090-1234-5678');

      expect(result.isSuccess, true);
      final customer = result.data;
      expect(customer, isNotNull);
      expect(customer!.phone, '090-1234-5678');
    });

    test('should return null for non-existent phone', () async {
      final result = await repository.getCustomerByPhone('000-0000-0000');

      expect(result.isSuccess, true);
      final customer = result.data;
      expect(customer, isNull);
    });

    test('should get customer by email', () async {
      final result = await repository.getCustomerByEmail('tanaka@example.com');

      expect(result.isSuccess, true);
      final customer = result.data;
      expect(customer, isNotNull);
      expect(customer!.email, 'tanaka@example.com');
    });

    test('should return null for non-existent email', () async {
      final result = await repository.getCustomerByEmail('nonexistent@example.com');

      expect(result.isSuccess, true);
      final customer = result.data;
      expect(customer, isNull);
    });

    test('should get total customer count', () async {
      final result = await repository.getTotalCustomerCount();

      expect(result.isSuccess, true);
      final count = result.data!;
      expect(count, greaterThan(0));
      expect(count, lessThanOrEqualTo(20));
    });

    test('should get birthday customers for current month', () async {
      final result = await repository.getBirthdayCustomers();

      expect(result.isSuccess, true);
      final birthdayCustomers = result.data!;
      final currentMonth = DateTime.now().month;
      expect(birthdayCustomers.every((c) =>
        c.dateOfBirth?.month == currentMonth
      ), true);
    });

    test('should throw when adding points to non-existent customer', () async {
      final result = await repository.addLoyaltyPoints('non-existent-id', 50);

      expect(result.isSuccess, false);
      expect(result.error, isNotNull);
    });

    test('should throw when subtracting points from non-existent customer', () async {
      final result = await repository.subtractLoyaltyPoints('non-existent-id', 50);

      expect(result.isSuccess, false);
      expect(result.error, isNotNull);
    });
  });
}