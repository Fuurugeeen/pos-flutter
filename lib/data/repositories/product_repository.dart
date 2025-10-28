import '../models/product.dart';
import '../models/enums.dart';
import '../../core/utils/result.dart';

abstract class ProductRepository {
  /// Get all products
  Future<Result<List<Product>>> getAllProducts();
  
  /// Get products by category
  Future<Result<List<Product>>> getProductsByCategory(ProductCategory category);
  
  /// Get product by ID
  Future<Result<Product?>> getProductById(String id);
  
  /// Search products by name or description
  Future<Result<List<Product>>> searchProducts(String query);
  
  /// Get active products only
  Future<Result<List<Product>>> getActiveProducts();
  
  /// Get low stock products
  Future<Result<List<Product>>> getLowStockProducts();
  
  /// Create a new product
  Future<Result<Product>> createProduct(Product product);
  
  /// Update an existing product
  Future<Result<Product>> updateProduct(Product product);
  
  /// Delete a product (soft delete - mark as inactive)
  Future<Result<void>> deleteProduct(String id);
  
  /// Update product stock quantity
  Future<Result<Product>> updateStock(String id, int newQuantity);
  
  /// Reduce stock quantity (e.g., after sale)
  Future<Result<Product>> reduceStock(String id, int quantity);
  
  /// Get products count by category
  Future<Result<Map<ProductCategory, int>>> getProductCountByCategory();
}