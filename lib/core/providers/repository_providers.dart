import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/sale_repository.dart';
import '../../data/repositories/mock_product_repository.dart';
import '../../data/repositories/mock_customer_repository.dart';
import '../../data/repositories/mock_sale_repository.dart';

// Repository providers
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return MockProductRepository();
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return MockCustomerRepository();
});

final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  return MockSaleRepository();
});