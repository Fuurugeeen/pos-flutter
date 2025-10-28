import 'package:flutter_test/flutter_test.dart';
import 'package:pos_flutter/data/models/customer.dart';

void main() {
  group('Customer Model Tests', () {
    late Customer testCustomer;

    setUp(() {
      testCustomer = Customer.create(
        name: 'Test Customer',
        email: 'test@example.com',
        phone: '090-1234-5678',
        address: 'Test Address',
        loyaltyPoints: 100,
        dateOfBirth: DateTime(1990, 1, 1),
      );
    });

    test('should create a customer with factory constructor', () {
      expect(testCustomer.name, 'Test Customer');
      expect(testCustomer.email, 'test@example.com');
      expect(testCustomer.phone, '090-1234-5678');
      expect(testCustomer.address, 'Test Address');
      expect(testCustomer.loyaltyPoints, 100);
      expect(testCustomer.dateOfBirth, DateTime(1990, 1, 1));
      expect(testCustomer.isActive, true);
      expect(testCustomer.id, isNotEmpty);
    });

    test('should create customer with minimal required fields', () {
      final minimalCustomer = Customer.create(name: 'Minimal Customer');
      
      expect(minimalCustomer.name, 'Minimal Customer');
      expect(minimalCustomer.email, isNull);
      expect(minimalCustomer.phone, isNull);
      expect(minimalCustomer.address, isNull);
      expect(minimalCustomer.loyaltyPoints, 0);
      expect(minimalCustomer.dateOfBirth, isNull);
      expect(minimalCustomer.isActive, true);
    });

    test('should add loyalty points correctly', () {
      final updatedCustomer = testCustomer.addPoints(50);
      
      expect(updatedCustomer.loyaltyPoints, 150);
      expect(updatedCustomer.id, testCustomer.id);
      expect(updatedCustomer.updatedAt.isAfter(testCustomer.updatedAt), true);
    });

    test('should subtract loyalty points correctly', () {
      final updatedCustomer = testCustomer.subtractPoints(30);
      
      expect(updatedCustomer.loyaltyPoints, 70);
      expect(updatedCustomer.id, testCustomer.id);
    });

    test('should not allow negative loyalty points', () {
      final updatedCustomer = testCustomer.subtractPoints(150);
      
      expect(updatedCustomer.loyaltyPoints, 0);
    });

    test('should serialize to and from JSON correctly', () {
      final json = testCustomer.toJson();
      final deserializedCustomer = Customer.fromJson(json);
      
      expect(deserializedCustomer, equals(testCustomer));
    });

    test('should copy with new values correctly', () {
      final newCustomer = testCustomer.copyWith(
        name: 'Updated Customer',
        loyaltyPoints: 200,
      );
      
      expect(newCustomer.name, 'Updated Customer');
      expect(newCustomer.loyaltyPoints, 200);
      expect(newCustomer.id, testCustomer.id);
      expect(newCustomer.email, testCustomer.email);
    });

    test('should have correct equality comparison', () {
      final json = testCustomer.toJson();
      final sameCustomer = Customer.fromJson(json);
      final differentCustomer = testCustomer.copyWith(name: 'Different Customer');
      
      expect(testCustomer, equals(sameCustomer));
      expect(testCustomer, isNot(equals(differentCustomer)));
    });

    test('should handle null optional fields in JSON', () {
      final customerWithNulls = Customer.create(name: 'Simple Customer');
      final json = customerWithNulls.toJson();
      final deserializedCustomer = Customer.fromJson(json);
      
      expect(deserializedCustomer, equals(customerWithNulls));
      expect(deserializedCustomer.email, isNull);
      expect(deserializedCustomer.phone, isNull);
      expect(deserializedCustomer.address, isNull);
      expect(deserializedCustomer.dateOfBirth, isNull);
    });
  });
}