import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/sale_repository.dart';
import '../../data/repositories/mock_product_repository.dart';

// Repository providers
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return MockProductRepository();
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  // TODO: Replace with actual implementation when available
  throw UnimplementedError('CustomerRepository not yet implemented');
});

final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  // TODO: Replace with actual implementation when available
  throw UnimplementedError('SaleRepository not yet implemented');
});